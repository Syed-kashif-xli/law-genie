import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:myapp/features/home/models/news_article.dart';

class NewsService {
  final List<String> rssUrls = [
    'https://www.barandbench.com/feed',
    'https://www.livelaw.in/rss/articles.xml',
  ];

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
      final List<Future<List<NewsArticle>>> futures = rssUrls.map((url) async {
        try {
          final response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            var items = <dynamic>[];
            try {
              final atomFeed = AtomFeed.parse(response.body);
              items = atomFeed.items ?? [];
            } catch (_) {
              try {
                final rssFeed = RssFeed.parse(response.body);
                items = rssFeed.items ?? [];
              } catch (e) {
                developer.log('Error parsing feed $url: $e',
                    name: 'NewsService');
                return <NewsArticle>[];
              }
            }

            if (items.isEmpty) return <NewsArticle>[];

            final articles = await Future.wait(items.map((item) async {
              String? title;
              String? description;
              String? link;
              String? pubDate;
              String? content;

              if (item is AtomItem) {
                title = item.title;
                description = item.summary ?? item.content;
                link = item.links?.isNotEmpty == true
                    ? item.links!.first.href
                    : null;
                pubDate = item.updated?.toIso8601String();
                content = item.content;
              } else if (item is RssItem) {
                title = item.title;
                description = item.description;
                link = item.link;
                pubDate = item.pubDate?.toIso8601String();
                content = item.content?.value ?? item.description;
              }

              String? imageUrl = _getImageUrlFromContent(content);

              // If no image in content, try to fetch OG image
              if (imageUrl == null && link != null) {
                imageUrl = await _fetchOgImage(link);
              }

              return NewsArticle(
                title: title ?? 'No Title',
                description: description ?? 'No Description',
                url: link ?? '',
                source: 'Law Genie', // Rebranded as requested
                publishedAt: pubDate ?? '',
                imageUrl: imageUrl,
                content: content,
              );
            }));

            return articles;
          } else {
            developer.log('Failed to load feed $url: ${response.statusCode}',
                name: 'NewsService');
            return <NewsArticle>[];
          }
        } catch (e) {
          developer.log('Error fetching news from $url: $e',
              name: 'NewsService');
          return <NewsArticle>[];
        }
      }).toList();

      final List<List<NewsArticle>> results = await Future.wait(futures);
      final List<NewsArticle> allNews = results.expand((x) => x).toList();

      // Sort by date descending
      allNews.sort((a, b) {
        if (a.publishedAt.isEmpty) return 1;
        if (b.publishedAt.isEmpty) return -1;
        return b.publishedAt.compareTo(a.publishedAt);
      });

      return allNews;
    } catch (e) {
      developer.log('Error fetching news: $e', name: 'NewsService');
      throw Exception('Error fetching news: $e');
    }
  }
}
