import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import '../features/case_finder/models/legal_case.dart';

class CaseFinderService {
  // Cache for better performance
  final Map<String, List<LegalCase>> _searchCache = {};
  final Map<String, DateTime> _cacheTime = {};
  static const Duration _cacheDuration = Duration(minutes: 30);

  static const String _indianKanoonUrl = 'https://indiankanoon.org';
  static const String _barAndBenchRss = 'https://www.barandbench.com/feed';

  // Search with Date Filters
  Future<List<LegalCase>> searchCases(String query,
      {int? fromYear, int? toYear}) async {
    if (query.trim().isEmpty) {
      return getRecentJudgments();
    }

    // Construct Cache Key
    final cacheKey = '${query.toLowerCase()}_${fromYear ?? ""}_${toYear ?? ""}';
    if (_searchCache.containsKey(cacheKey)) {
      final cacheAge = DateTime.now().difference(_cacheTime[cacheKey]!);
      if (cacheAge < _cacheDuration) {
        return _searchCache[cacheKey]!;
      }
    }

    List<LegalCase> allResults = [];
    int pagesToFetch = 3; // Fetch top 30-40 results

    for (int page = 0; page < pagesToFetch; page++) {
      try {
        // Use Indian Kanoon Advanced Search
        // Format: /search/?formInput=query+doctypes:judgments&fromdate=1-1-2000&todate=31-12-2023&pagenum=0
        var searchUrl =
            '$_indianKanoonUrl/search/?formInput=${Uri.encodeComponent(query)}+doctypes:judgments&pagenum=$page';

        if (fromYear != null) {
          searchUrl += '&fromdate=1-1-$fromYear';
        }
        if (toYear != null) {
          searchUrl += '&todate=31-12-$toYear';
        }

        print('Searching Page $page: $searchUrl');

        final response = await http.get(
          Uri.parse(searchUrl),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final pageResults = _parseIndianKanoonResults(response.body);
          if (pageResults.isEmpty) break; // Stop if no more results
          allResults.addAll(pageResults);
        } else {
          break;
        }
      } catch (e) {
        print('Search failed on page $page: $e');
        break;
      }
    }

    if (allResults.isNotEmpty) {
      _searchCache[cacheKey] = allResults;
      _cacheTime[cacheKey] = DateTime.now();
    }

    return allResults;
  }

  List<LegalCase> _parseIndianKanoonResults(String html) {
    final document = html_parser.parse(html);
    final results = <LegalCase>[];

    final resultDivs = document.querySelectorAll('.result');

    for (var resultDiv in resultDivs) {
      try {
        final titleElement = resultDiv.querySelector('.result_title a');
        if (titleElement == null) continue;

        final title = titleElement.text.trim();
        final href = titleElement.attributes['href'] ?? '';
        final url = href.startsWith('http') ? href : '$_indianKanoonUrl$href';

        // Updated selector from .snippet to .headline
        final snippetElement = resultDiv.querySelector('.headline');
        final summary = snippetElement?.text.trim() ?? '';

        // Extract Date and Court from the text usually found at bottom of result
        // Example: "Supreme Court of India on 24 April, 1973"
        final docSource =
            resultDiv.querySelector('.docsource')?.text.trim() ?? '';

        String court = 'Court';
        DateTime date = DateTime.now();

        if (docSource.isNotEmpty) {
          // Parse "Court Name on Date"
          // Note: Sometimes docsource only has court name, date might be in title
          court = docSource;
        }

        // Try to find date in title first (e.g. "... on 2 March, 2007")
        try {
          if (title.contains(' on ')) {
            final datePart = title.split(' on ').last.trim();
            date = DateFormat('d MMMM, yyyy').parse(datePart);
          } else {
            // Fallback to docsource if date not in title
            // This part is tricky as docsource format varies
          }
        } catch (e) {
          // Date parsing failed, keep default
        }

        results.add(LegalCase(
          id: url.hashCode.toString(),
          title: title,
          court: court,
          caseNumber: '',
          date: date,
          summary: summary,
          url: url,
          category: _detectCategory(title + ' ' + summary),
        ));
      } catch (e) {
        print('Error parsing IK result: $e');
      }
    }
    return results;
  }

  Future<List<LegalCase>> getRecentJudgments({String? court}) async {
    // Keep Bar & Bench for "Recent" as it's good for news
    try {
      final response = await http.get(Uri.parse(_barAndBenchRss));
      if (response.statusCode == 200) {
        return _parseBarAndBenchRss(response.body, court);
      }
    } catch (e) {
      print('Error fetching RSS: $e');
    }
    return [];
  }

  List<LegalCase> _parseBarAndBenchRss(String xmlBody, String? courtFilter) {
    final document = html_parser.parse(xmlBody);
    final entries = document.querySelectorAll('entry');

    final results = <LegalCase>[];

    for (var entry in entries) {
      try {
        final title = entry.querySelector('title')?.text.trim() ?? '';
        final summary = entry.querySelector('summary')?.text.trim() ?? '';
        final link = entry.querySelector('link')?.attributes['href'] ?? '';
        final published = entry.querySelector('published')?.text ?? '';

        if (title.isEmpty) continue;

        String court = 'Legal News';
        if (title.contains('Supreme Court'))
          court = 'Supreme Court of India';
        else if (title.contains('High Court')) court = 'High Court';

        if (courtFilter != null && courtFilter != 'All Courts') {
          if (!court.contains(courtFilter.replaceAll('High Court', '')))
            continue;
        }

        results.add(LegalCase(
          id: link.hashCode.toString(),
          title: title,
          court: court,
          caseNumber: '',
          date: DateTime.tryParse(published) ?? DateTime.now(),
          summary: summary,
          url: link,
          category: _detectCategory(title + ' ' + summary),
        ));
      } catch (e) {
        print('Error parsing RSS entry: $e');
      }
    }
    return results;
  }

  String _detectCategory(String text) {
    final t = text.toLowerCase();
    if (t.contains('constitution') || t.contains('fundamental'))
      return 'Constitutional Law';
    if (t.contains('criminal') ||
        t.contains('murder') ||
        t.contains('bail') ||
        t.contains('ipc')) return 'Criminal Law';
    if (t.contains('civil') || t.contains('contract') || t.contains('property'))
      return 'Civil Law';
    if (t.contains('family') || t.contains('divorce') || t.contains('marriage'))
      return 'Family Law';
    if (t.contains('tax') || t.contains('gst') || t.contains('income'))
      return 'Tax Law';
    if (t.contains('labour') || t.contains('employee') || t.contains('workman'))
      return 'Labour Law';
    return 'Other';
  }

  Future<List<LegalCase>> getCasesByCategory(String category) async {
    return searchCases(category);
  }

  List<String> getAvailableCourts() {
    return [
      'All Courts',
      'Supreme Court of India',
      'Delhi High Court',
      'Bombay High Court',
      'Karnataka High Court',
      'Madras High Court',
      'Calcutta High Court',
    ];
  }

  List<String> getCategories() {
    return [
      'Constitutional Law',
      'Criminal Law',
      'Civil Law',
      'Family Law',
      'Property Law',
      'Labour Law',
      'Tax Law',
    ];
  }
}
