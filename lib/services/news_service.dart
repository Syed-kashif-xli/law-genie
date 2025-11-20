import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:myapp/features/home/models/news_article.dart';

class NewsService {
  final String rssUrl = 'https://www.barandbench.com/feed';

  // A more robust helper function to extract image from HTML content
  String? _getImageUrlFromContent(String? content) {
    if (content == null) return null;
    
    // Look for <img> tags
    final RegExp imgRegExp = RegExp(r'<img[^>]+src="([^">]+)"\s*[^>]*>');
    final Match? imgMatch = imgRegExp.firstMatch(content);
    if (imgMatch != null && imgMatch.groupCount >= 1) {
      return imgMatch.group(1);
    }

    // As a fallback, look for a background image style
    final RegExp styleRegExp = RegExp(r'background-image:\s*url\(([^)]+)\)');
    final Match? styleMatch = styleRegExp.firstMatch(content);
    if (styleMatch != null && styleMatch.groupCount >= 1) {
      return styleMatch.group(1)?.replaceAll("'", "").replaceAll("\"", ""); // Clean up quotes
    }
    
    return null;
  }

  Future<List<NewsArticle>> fetchLegalNews() async {
    try {
      final response = await http.get(Uri.parse(rssUrl));

      if (response.statusCode == 200) {
        try {
          // First, try parsing as an Atom feed
          final atomFeed = AtomFeed.parse(response.body);
          if (atomFeed.items == null) {
            developer.log('Atom feed items are null.', name: 'NewsService');
            return [];
          }
          final articles = atomFeed.items!.map((item) {
            return NewsArticle(
              title: item.title ?? 'No Title',
              description: item.summary ?? item.content ?? 'No Description',
              url: item.links?.first.href ?? '',
              source: 'Bar & Bench',
              publishedAt: item.updated?.toIso8601String() ?? '',
              imageUrl: _getImageUrlFromContent(item.content),
            );
          }).toList();
          developer.log('Successfully parsed ${articles.length} articles from Atom feed.', name: 'NewsService');
          return articles;
        } catch (e) {
          developer.log('Failed to parse as Atom, trying RSS. Error: $e', name: 'NewsService');
          // If Atom parsing fails, fall back to RSS parsing
          final rssFeed = RssFeed.parse(response.body);
          if (rssFeed.items == null) {
            developer.log('RSS feed items are null.', name: 'NewsService');
            return [];
          }
          final articles = rssFeed.items!.map((item) {
            String? imageUrl;
            if (item.media?.contents != null && item.media!.contents!.isNotEmpty) {
              imageUrl = item.media!.contents!.first.url;
            } else if (item.enclosure != null) {
              imageUrl = item.enclosure!.url;
            }
            return NewsArticle(
              title: item.title ?? 'No Title',
              description: item.description ?? 'No Description',
              url: item.link ?? '',
              source: 'Bar & Bench',
              publishedAt: item.pubDate?.toIso8601String() ?? '',
              imageUrl: imageUrl,
            );
          }).toList();
          developer.log('Successfully parsed ${articles.length} articles from RSS feed.', name: 'NewsService');
          return articles;
        }
      } else {
        developer.log('Failed to load feed. Status code: ${response.statusCode}', name: 'NewsService');
        throw Exception('Failed to load feed');
      }
    } catch (e, s) {
      developer.log('An error occurred while fetching news', name: 'NewsService', error: e, stackTrace: s);
      throw Exception('Error fetching news: $e');
    }
  }
}
