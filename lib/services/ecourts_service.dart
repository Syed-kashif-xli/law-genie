import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import '../features/case_finder/models/legal_case.dart';

class EcourtsService {
  static const String _baseUrl =
      'https://services.ecourts.gov.in/ecourtindia_v6';

  Future<LegalCase?> getCaseStatusByCnr(String cnr) async {
    try {
      final url = '$_baseUrl/?pno=1&cnr=$cnr';
      debugPrint('Fetching case status from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        return _parseCaseStatus(response.body, cnr, url);
      } else {
        debugPrint('Failed to fetch case status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching case status: $e');
      return null;
    }
  }

  LegalCase? _parseCaseStatus(String html, String cnr, String url) {
    try {
      final document = html_parser.parse(html);

      String title = 'Case Status';
      String court = 'eCourts Service';
      String? status;
      String? nextHearingDate;
      String? petitioner;
      String? respondent;
      String? caseNumber;
      String? summary;

      // Helper to find text by label
      String? findValueByLabel(String label) {
        final elements = document.querySelectorAll('td, th, span, div, label');
        for (var element in elements) {
          if (element.text.trim().toLowerCase().contains(label.toLowerCase())) {
            // Check next sibling
            var next = element.nextElementSibling;
            if (next != null && next.text.trim().isNotEmpty) {
              return next.text.trim();
            }
            // Check parent's next sibling
            var parent = element.parent;
            if (parent != null) {
              // If label is in a td, we want the next td in the same row
              if (element.localName == 'td' || element.localName == 'th') {
                var nextTd = element.nextElementSibling;
                if (nextTd != null) return nextTd.text.trim();
              }
            }
          }
        }
        return null;
      }

      // Try to extract data using common labels
      caseNumber =
          findValueByLabel('Case Number') ?? findValueByLabel('Case No');
      status =
          findValueByLabel('Case Status') ?? findValueByLabel('Stage of Case');
      nextHearingDate = findValueByLabel('Next Hearing Date') ??
          findValueByLabel('Next Date');
      petitioner = findValueByLabel('Petitioner and Advocate') ??
          findValueByLabel('Petitioner');
      respondent = findValueByLabel('Respondent and Advocate') ??
          findValueByLabel('Respondent');

      // Fallback: Iterate rows
      final rows = document.querySelectorAll('tr');
      for (var row in rows) {
        final cells = row.querySelectorAll('td');
        if (cells.length >= 2) {
          final label = cells[0].text.trim().toLowerCase();
          final value = cells[1].text.trim();

          if (label.contains('case no')) caseNumber = value;
          if (label.contains('case status') || label.contains('stage')) {
            status = value;
          }
          if (label.contains('next hearing date')) nextHearingDate = value;
          if (label.contains('petitioner')) petitioner = value;
          if (label.contains('respondent')) respondent = value;
        }
      }

      // Construct title
      if (petitioner != null && respondent != null) {
        title = '$petitioner vs $respondent';
      } else if (petitioner != null) {
        title = 'Case: $petitioner';
      }

      return LegalCase(
        id: cnr,
        title: title,
        court: court,
        caseNumber: caseNumber ?? cnr,
        date: DateTime.now(),
        summary: summary ?? 'Status: ${status ?? "Unknown"}',
        url: url,
        category: 'Case Status',
        cnrNumber: cnr,
        status: status,
        nextHearingDate: nextHearingDate,
        petitioner: petitioner,
        respondent: respondent,
      );
    } catch (e) {
      debugPrint('Error parsing case status HTML: $e');
      return null;
    }
  }
}
