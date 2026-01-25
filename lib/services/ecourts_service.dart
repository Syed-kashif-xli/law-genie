import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../features/case_finder/models/legal_case.dart';
import 'ecourt_encryption_service.dart';

class EcourtsService {
  static const String _baseUrl = 'https://app.ecourts.gov.in/ecourt_mobile_DC/';
  String? _jwtToken;
  String? _sessionCookie;
  final String _pkgName = 'in.gov.ecourts.eCourtsServices';
  final String _defaultUid = '324456';

  Map<String, String> getStandardHeaders() {
    final headers = {
      'User-Agent':
          'Dalvik/2.1.0 (Linux; U; Android 11; Pixel 5 Build/RD2A.211001.002)',
    };
    if (_sessionCookie != null) {
      headers['Cookie'] = _sessionCookie!;
    }
    if (_jwtToken != null) {
      final encryptedAuthToken =
          EcourtEncryptionService.encryptRequest(_jwtToken);
      headers['Authorization'] = 'Bearer $encryptedAuthToken';
    }
    return headers;
  }

  Future<bool> _ensureAuthenticated() async {
    if (_jwtToken != null) return true;

    try {
      final appReleaseUrl = '${_baseUrl}appReleaseWebService.php';

      final authData = {"version": "3.0", "uid": "$_defaultUid:$_pkgName"};

      final encryptedPayload = EcourtEncryptionService.encryptRequest(authData);

      final response = await http.get(
        Uri.parse(
            '$appReleaseUrl?params=${Uri.encodeComponent(encryptedPayload)}'),
        headers: {
          'User-Agent':
              'Dalvik/2.1.0 (Linux; U; Android 11; Pixel 5 Build/RD2A.211001.002)',
        },
      );

      if (response.statusCode == 200) {
        if (response.headers['set-cookie'] != null) {
          _sessionCookie = response.headers['set-cookie'];
        }

        final decodedBody =
            EcourtEncryptionService.decryptResponse(response.body);

        if (decodedBody.trim().isEmpty) return false;

        try {
          final responseData = json.decode(decodedBody);
          if (responseData != null && responseData['token'] != null) {
            _jwtToken = responseData['token'];
            return true;
          }
        } catch (e) {
          debugPrint('Auth JSON Error: $e');
        }
      }
      return false;
    } catch (e) {
      debugPrint('Authentication Error: $e');
      return false;
    }
  }

  Future<LegalCase?> getCaseStatusByCnr(String cnr,
      {bool isRetry = false}) async {
    try {
      if (!await _ensureAuthenticated()) return null;

      final encryptedAuthToken =
          EcourtEncryptionService.encryptRequest(_jwtToken);
      final Map<String, String> authHeader = {
        'Authorization': 'Bearer $encryptedAuthToken'
      };

      if (_sessionCookie != null) {
        authHeader['Cookie'] = _sessionCookie!;
      }

      final userAgent = {
        'User-Agent':
            'Dalvik/2.1.0 (Linux; U; Android 11; Pixel 5 Build/RD2A.211001.002)'
      };

      final Map<String, dynamic> searchParams = {
        "cino": cnr,
        "version_number": "3.0",
        "language_flag": "english",
        "bilingual_flag": "0"
      };

      if (isRetry) {
        searchParams["uid"] = "$_defaultUid:$_pkgName";
      }

      final encryptedPayload =
          EcourtEncryptionService.encryptRequest(searchParams);
      final encodedPayload = Uri.encodeComponent(encryptedPayload);

      final checkUrl =
          '${_baseUrl}listOfCasesWebService.php?params=$encodedPayload';

      final checkResponse = await http.get(
        Uri.parse(checkUrl),
        headers: {...userAgent, ...authHeader},
      );

      if (checkResponse.statusCode != 200) return null;

      final decryptedBody =
          EcourtEncryptionService.decryptResponse(checkResponse.body);

      if (decryptedBody.trim().isEmpty) return null;

      try {
        final responseData = json.decode(decryptedBody);

        if (responseData['token'] != null) {
          _jwtToken = responseData['token'];
        }

        if (responseData['status_code'] == '401' && !isRetry) {
          return getCaseStatusByCnr(cnr, isRetry: true);
        }

        if (responseData['status'] == 'fail' || responseData['status'] == 'N') {
          return null;
        }

        return _fetchCaseHistory(cnr, userAgent, authHeader);
      } catch (e) {
        debugPrint('Search JSON Error: $e');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching case status: $e');
      return null;
    }
  }

  Future<LegalCase?> _fetchCaseHistory(String cnr,
      Map<String, String> userAgent, Map<String, String> authHeader) async {
    final historyParams = {
      "cinum": cnr,
      "language_flag": "english",
      "bilingual_flag": "0"
    };

    final encryptedHistoryPayload =
        EcourtEncryptionService.encryptRequest(historyParams);
    final encodedHistoryPayload = Uri.encodeComponent(encryptedHistoryPayload);
    final historyUrl =
        '${_baseUrl}caseHistoryWebService.php?params=$encodedHistoryPayload';

    final historyResponse = await http.get(
      Uri.parse(historyUrl),
      headers: {...userAgent, ...authHeader},
    );

    if (historyResponse.statusCode == 200) {
      final historyDecrypted =
          EcourtEncryptionService.decryptResponse(historyResponse.body);

      if (historyDecrypted.trim().isNotEmpty) {
        final historyData = json.decode(historyDecrypted);
        if (historyData != null && historyData['history'] != null) {
          return _parseOfficialResponse(historyData['history'], cnr);
        }
      }
    }
    return null;
  }

  LegalCase? _parseOfficialResponse(Map<String, dynamic> history, String cnr) {
    try {
      String petitioner = history['pet_name'] ?? 'Unknown';
      String respondent = history['res_name'] ?? 'Unknown';
      String title = '$petitioner vs $respondent';

      String regNo = '${history['reg_no']}/${history['reg_year']}';
      String dtRegis = history['dt_regis'] ?? 'N/A';
      String dateFirstList = history['date_first_list'] ?? 'N/A';
      String dateNextList = history['date_next_list'] ?? 'Not Scheduled';
      String purposeName = history['purpose_name'] ?? 'N/A';
      String courtName = history['court_name'] ?? 'eCourts';
      String caseNo = history['case_no'] ?? cnr;
      String caseType = history['type_name'] ?? 'N/A';
      String petAdv = history['pet_adv'] ?? '';
      String resAdv = history['res_adv'] ?? '';

      // --- HTML Parsing for Extra Details ---

      // Parse Acts
      String actsText = '';
      if (history['act'] != null) {
        actsText = stripHtml(history['act']);
      }

      // Parse Extra Respondents
      List<String> extraRespondents = [];
      if (history['str_error1'] != null) {
        extraRespondents = _parseHtmlList(history['str_error1']);
      }

      // Parse Extra Petitioners
      List<String> extraPetitioners = [];
      if (history['str_error'] != null) {
        extraPetitioners = _parseHtmlList(history['str_error']);
      } else if (history['petNameAdd'] != null) {
        // Sometimes petNameAdd contains list starting with 1)
        // But main petitioner is usually 1, so we might check for 2) etc
        // For now, let's rely on str_error being the standard 'extra' list
        // logic from official app might differ, but str_error1 was definitely extra respondents
      }

      return LegalCase(
        id: cnr,
        title: title,
        court: courtName,
        caseNumber: caseNo,
        date: DateTime.now(),
        summary: 'Status: $purposeName',
        url: 'https://services.ecourts.gov.in/',
        category: 'Case Status',
        cnrNumber: cnr,
        status: purposeName,
        nextHearingDate: dateNextList,
        petitioner: petitioner,
        respondent: respondent,
        caseType: caseType,
        registrationNumber: regNo,
        registrationDate: dtRegis,
        firstHearingDate: dateFirstList,
        caseStage: purposeName,
        petitionerAdvocate: petAdv,
        respondentAdvocate: resAdv,
        acts: actsText.isNotEmpty ? actsText : null,
        extraRespondents: extraRespondents,
        extraPetitioners: extraPetitioners,
        hearingHistory: history['historyOfCaseHearing'] != null
            ? _parseHearingHistory(history['historyOfCaseHearing'])
            : null,
        interimOrders: history['interimOrder'] != null
            ? _parseOrders(history['interimOrder'])
            : null,
        finalOrders: history['finalOrder'] != null
            ? _parseOrders(history['finalOrder'])
            : null,
        transfers: history['transfer'] != null
            ? _parseTransfers(history['transfer'])
            : null,
      );
    } catch (e) {
      debugPrint('Error parsing response: $e');
      return null;
    }
  }

  String stripHtml(String htmlString) {
    // Basic regex to remove Act table headers and keep content
    // This is approximate; for 'act' it usually contains simple table
    // Removing tags:
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<String> _parseHtmlList(String htmlString) {
    // Parses strings like "<br />2)  Aasif Ali<br>..." into ["2) Aasif Ali", ...]
    List<String> results = [];
    // Split by <br> or <br />
    final parts = htmlString.split(RegExp(r'<br\s*\/?>', caseSensitive: false));

    for (var part in parts) {
      // Clean up tags and entities
      var clean = part
          .replaceAll(RegExp(r'<[^>]*>'), '') // Remove remaining tags
          .replaceAll('&nbsp;', ' ')
          .trim();

      if (clean.isNotEmpty && (clean.contains(')') || clean.contains('.'))) {
        results.add(clean);
      }
    }
    return results;
  }

  List<HearingRecord> _parseHearingHistory(String html) {
    List<HearingRecord> records = [];
    final rows = html.split(RegExp(r'<tr>|<\/tr>'));
    for (var row in rows) {
      if (!row.contains('<td>') && !row.contains('<td')) continue;
      final cols = row.split(RegExp(r'<td>|<\/td>|<td[^>]*>'));
      final cleanCols = cols
          .map((e) => stripHtml(e))
          .where((e) => e.trim().isNotEmpty)
          .toList();

      if (cleanCols.length >= 4) {
        records.add(HearingRecord(
          judge: cleanCols[0],
          businessOnDate: cleanCols[1],
          hearingDate: cleanCols[2],
          purpose: cleanCols[3],
        ));
      }
    }
    return records;
  }

  List<OrderRecord> _parseOrders(String html) {
    List<OrderRecord> records = [];
    final rows = html.split(RegExp(r'<tr>|<\/tr>'));
    for (var row in rows) {
      if (!row.contains('<td>') && !row.contains('<td')) continue;

      // Extract PDF URL if exists
      String? pdfUrl;
      final hrefMatch = RegExp(r"href\s*=\s*'([^']+)'").firstMatch(row);
      if (hrefMatch != null) {
        pdfUrl = hrefMatch.group(1);
        if (pdfUrl != null && !pdfUrl.startsWith('http')) {
          pdfUrl = 'https://app.ecourts.gov.in/ecourt_mobile_DC/$pdfUrl';
        }
      }

      final cols = row.split(RegExp(r'<td>|<\/td>|<td[^>]*>'));
      final cleanCols = cols
          .map((e) => stripHtml(e))
          .where((e) => e.trim().isNotEmpty)
          .toList();

      if (cleanCols.length >= 3) {
        records.add(OrderRecord(
          orderNumber: cleanCols[0],
          orderDate: cleanCols[1],
          orderDetails: cleanCols[2],
          pdfUrl: pdfUrl,
        ));
      }
    }
    return records;
  }

  List<TransferRecord> _parseTransfers(String html) {
    List<TransferRecord> records = [];
    final rows = html.split(RegExp(r'<tr>|<\/tr>'));
    for (var row in rows) {
      if (!row.contains('<td>') && !row.contains('<td')) continue;
      final cols = row.split(RegExp(r'<td>|<\/td>|<td[^>]*>'));
      final cleanCols = cols
          .map((e) => stripHtml(e))
          .where((e) => e.trim().isNotEmpty)
          .toList();

      if (cleanCols.length >= 3) {
        records.add(TransferRecord(
          transferDate: cleanCols[0],
          fromCourt: cleanCols[1],
          toCourt: cleanCols[2],
        ));
      }
    }
    return records;
  }
}
