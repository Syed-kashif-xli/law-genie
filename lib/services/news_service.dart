import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:myapp/features/home/models/news_article.dart';

class NewsService {
  final String rssUrl = 'https://www.barandbench.com/feed';

  String? _getImageUrlFromContent(String? content) {
    if (content == null) return null;
    final RegExp imgRegExp = RegExp(r'<img[^>]+src="([^">]+)"\s*[^>]*>');
    final Match? imgMatch = imgRegExp.firstMatch(content);
    if (imgMatch != null && imgMatch.groupCount >= 1) {
      return imgMatch.group(1);
    }
    return null;
  }

  Future<String?> _fetchOgImage(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        final document = response.body;
        final RegExp ogImageRegExp =
            RegExp(r'<meta\s+property="og:image"\s+content="([^"]+)"');
        final Match? match = ogImageRegExp.firstMatch(document);
        if (match != null && match.groupCount >= 1) {
          return match.group(1);
        }
      }
    } catch (e) {
      developer.log('Error fetching OG image for $url: $e',
          name: 'NewsService');
    }
    return null;
  }

  Future<List<NewsArticle>> fetchLegalNews() async {
    try {
      final response = await http.get(Uri.parse(rssUrl));

      if (response.statusCode == 200) {
        try {
          final atomFeed = AtomFeed.parse(response.body);
          if (atomFeed.items == null) return [];

          final articles = await Future.wait(atomFeed.items!.map((item) async {
            String? imageUrl = _getImageUrlFromContent(item.content);
            if (imageUrl == null &&
                item.links != null &&
                item.links!.isNotEmpty) {
              // If no image in content, try to fetch OG image from the article URL
              // Limit to first link which is usually the article link
              final link = item.links!.first.href;
              if (link != null) {
                imageUrl = await _fetchOgImage(link);
              }
            }

            return NewsArticle(
              title: item.title ?? 'No Title',
              description: item.summary ?? item.content ?? 'No Description',
              url: item.links?.first.href ?? '',
              source: 'Bar & Bench',
              publishedAt: item.updated?.toIso8601String() ?? '',
              imageUrl: imageUrl,
            );
          }));

          return articles;
        } catch (e) {
          developer.log('Error parsing Atom feed: $e', name: 'NewsService');
          return [];
        }
      } else {
        developer.log('Failed to load feed: ${response.statusCode}',
            name: 'NewsService');
        throw Exception('Failed to load feed');
      }
    } catch (e) {
      developer.log('Error fetching news: $e', name: 'NewsService');
      throw Exception('Error fetching news: $e');
    }
  }
}
