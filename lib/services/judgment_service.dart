import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:myapp/models/judgment_model.dart';

class JudgmentService {
  static const String baseUrl = 'https://indiankanoon.org';

  // Custom headers to avoid basic bot detection
  final Map<String, String> _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept-Language': 'en-US,en;q=0.9',
  };

  Future<List<JudgmentCategory>> fetchCategories() async {
    try {
      final uri = Uri.https('indiankanoon.org', '/browse/');
      final response = await http.get(uri, headers: _headers);
      debugPrint(
          'JudgmentService: fetchCategories status: ${response.statusCode}');
      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        // Using common selector for links that start with /browse/
        var links = document.querySelectorAll('a[href^="/browse/"]');
        debugPrint(
            'JudgmentService: Found ${links.length} potential category links');

        List<JudgmentCategory> categories = [];
        for (var link in links) {
          final name = link.text.trim();
          final path = link.attributes['href'] ?? '';

          // Improved filtering: keep courts and tribunals, filter out debates
          if (path.isNotEmpty &&
              path.startsWith('/browse/') &&
              !name.contains('Debates') &&
              !name.contains('Lok Sabha') &&
              !name.contains('Rajya Sabha') &&
              name.length > 3) {
            // Reformat some names for better UI
            String cleanName = name;
            if (name.contains(' (Pre-Telangana)')) {
              cleanName = name.split(' (Pre-Telangana)')[0];
            }

            categories.add(JudgmentCategory(name: cleanName, path: path));
          }
        }

        // Sort alphabetically to help user find specific courts
        categories.sort((a, b) => a.name.compareTo(b.name));

        // Ensure Supreme Court is at the top as it's most common
        final scIndex =
            categories.indexWhere((c) => c.name.contains('Supreme Court'));
        if (scIndex != -1) {
          final sc = categories.removeAt(scIndex);
          categories.insert(0, sc);
        }
        return categories;
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
    return [];
  }

  Future<List<Judgment>> searchJudgments(String query, {int page = 0}) async {
    int retryCount = 0;
    const int maxRetries = 2;
    int delayMs = 1000;

    while (retryCount <= maxRetries) {
      try {
        final uri = Uri.https('indiankanoon.org', '/search/', {
          'formInput': query,
          'pagenum': page.toString(),
        });
        debugPrint('JudgmentService: searchJudgments URL: $uri');
        final response = await http.get(uri, headers: _headers);
        debugPrint(
            'JudgmentService: searchJudgments status: ${response.statusCode}');

        if (response.statusCode == 200) {
          var document = parser.parse(response.body);

          // Try multiple selectors for results
          var results = document.querySelectorAll('.result');
          if (results.isEmpty) {
            results = document.querySelectorAll('.result_title');
          }

          debugPrint('JudgmentService: Found ${results.length} search results');

          List<Judgment> judgments = [];
          for (var result in results) {
            final titleElement = result.querySelector('a') ??
                result.querySelector('.result_title a');

            final snippetElement =
                result.querySelector('.headline') ?? result.nextElementSibling;

            if (titleElement != null) {
              final href = titleElement.attributes['href'] ?? '';
              // Include both direct docs and fragments
              if (!href.contains('/doc/') && !href.contains('/docfragment/')) {
                continue;
              }

              final title = titleElement.text.trim();
              // Extract ID from the path segment, removing query params if present
              final path = Uri.parse(href).path;
              final id = path.split('/').where((s) => s.isNotEmpty).last;

              judgments.add(Judgment(
                id: id,
                title: title,
                snippet: (snippetElement?.classes.contains('headline') ?? false)
                    ? snippetElement?.text.trim()
                    : null,
                url: '$baseUrl$href',
              ));
            }
          }
          return judgments;
        } else if (response.statusCode == 520 || response.statusCode == 524) {
          debugPrint(
              'JudgmentService: searchJudgments Cloudflare error ${response.statusCode}. Retrying ($retryCount)...');
        } else {
          debugPrint(
              'JudgmentService: searchJudgments FAILED. Status: ${response.statusCode}');
          break; // Don't retry for other errors
        }
      } catch (e) {
        debugPrint('JudgmentService: searchJudgments EXCEPTION: $e');
      }

      retryCount++;
      if (retryCount <= maxRetries) {
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
      }
    }
    return [];
  }

  Future<Judgment?> fetchJudgmentDetail(String id) async {
    int retryCount = 0;
    const int maxRetries = 2;
    int delayMs = 1000;

    while (retryCount <= maxRetries) {
      try {
        final uri = Uri.https('indiankanoon.org', '/doc/$id/');
        debugPrint('JudgmentService: fetchJudgmentDetail URL: $uri');
        final response = await http.get(uri, headers: _headers);
        debugPrint(
            'JudgmentService: fetchJudgmentDetail status: ${response.statusCode}');

        if (response.statusCode == 200) {
          // Use compute to parse HTML in a background isolate
          final judgment = await compute(_parseJudgmentHtml, {
            'html': response.body,
            'id': id,
            'url': uri.toString(),
          });
          return judgment;
        } else if (response.statusCode == 520 || response.statusCode == 524) {
          debugPrint(
              'JudgmentService: Cloudflare error ${response.statusCode}. Retrying ($retryCount)...');
        } else {
          debugPrint(
              'JudgmentService: fetchJudgmentDetail FAILED. Status: ${response.statusCode}');
          break; // Don't retry for other errors like 404
        }
      } catch (e) {
        debugPrint('JudgmentService: fetchJudgmentDetail EXCEPTION: $e');
      }

      retryCount++;
      if (retryCount <= maxRetries) {
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2; // Exponential backoff
      }
    }
    return null;
  }
}

/// Helper function for compute to parse judgment HTML in background
Judgment? _parseJudgmentHtml(Map<String, String> data) {
  try {
    final html = data['html']!;
    final id = data['id']!;
    final url = data['url']!;

    final document = parser.parse(html);

    final title =
        document.querySelector('.doc_title')?.text.trim() ?? 'Judgment';
    final author = document.querySelector('.doc_author')?.text.trim();
    final bench = document.querySelector('.doc_bench')?.text.trim();

    // Extract main content - excluding ads and sidebars
    var contentElement = document.querySelector('.maindoc') ??
        document.querySelector('.judgments') ??
        document.querySelector('.akoma-ntoso') ??
        document.querySelector('.doc_source');
    var content = contentElement?.text.trim();

    if (content == null || content.isEmpty) {
      // Try a broad fallback to find any large text container
      var possibleContent = document.querySelectorAll('div');
      for (var div in possibleContent) {
        if (div.text.trim().length > 1000 &&
            !div.classes.contains('header-container')) {
          content = div.text.trim();
          break;
        }
      }
    }

    return Judgment(
      id: id,
      title: title,
      author: author?.replaceFirst('Author:', '').trim(),
      bench: bench?.replaceFirst('Bench:', '').trim(),
      content: content,
      url: url,
    );
  } catch (e) {
    debugPrint('Background Parsing Error: $e');
    return null;
  }
}
