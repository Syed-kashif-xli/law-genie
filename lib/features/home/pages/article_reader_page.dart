import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class ArticleReaderPage extends StatefulWidget {
  final String title;
  final String? content;
  final String url;

  const ArticleReaderPage({
    super.key,
    required this.title,
    required this.content,
    required this.url,
  });

  @override
  State<ArticleReaderPage> createState() => _ArticleReaderPageState();
}

class _ArticleReaderPageState extends State<ArticleReaderPage> {
  String? _fullContent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fullContent = widget.content;
    _fetchFullArticle();
  }

  Future<void> _fetchFullArticle() async {
    try {
      final response = await http.get(
        Uri.parse(widget.url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);

        dom.Element? articleBody;

        // List of common selectors for article content
        final selectors = [
          '.story-content', // Bar & Bench
          '.story_details', // LiveLaw
          '.content-text',
          'div[itemprop="articleBody"]',
          'article',
          '.post-content',
          '.entry-content',
          '#article-content',
          '.article-body',
          '.main-content',
          '.story-description',
          '.article-text',
          '.content',
          'main',
        ];

        for (final selector in selectors) {
          articleBody = document.querySelector(selector);
          if (articleBody != null && articleBody.text.trim().isNotEmpty) {
            debugPrint('Found article with selector: $selector');
            break;
          }
        }

        // Fallback: Try to find the largest text block if no selector matched
        if (articleBody == null) {
          final divs = document.querySelectorAll('div, section');
          divs.sort((a, b) => b
              .querySelectorAll('p')
              .length
              .compareTo(a.querySelectorAll('p').length));
          if (divs.isNotEmpty && divs.first.querySelectorAll('p').length > 3) {
            articleBody = divs.first;
            debugPrint('Found article using heuristic (most paragraphs)');
          }
        }

        if (articleBody != null) {
          // Remove unwanted elements
          final unwantedSelectors = [
            'script',
            'style',
            'iframe',
            'noscript',
            '.ad',
            '.advertisement',
            '.ads',
            '.related-posts',
            '.related-stories',
            '.read-more',
            '.share-buttons',
            '.social-share',
            '.share-icons',
            '.social-icons',
            '.social-bar',
            '.share-bar',
            '.floating-share',
            '.sticky-share',
            '.comment-section',
            '#comments',
            '.newsletter-signup',
            '.subscription-box',
            '.author-widget',
            '.author-box',
            '.site-footer',
            '.footer',
            'footer',
            'aside',
            '.sidebar',
            '.meta-data',
            '.copyright',
            '.follow-us',
            '.connect-with-us',
            '.breadcrumb',
            '.breadcrumbs',
            '.node-breadcrumb',
            '.field-name-field-tags',
            '.field-name-field-section',
            '.tags',
            '.category',
            '.date',
            '.author',
            '.submitted-by'
          ];

          for (final selector in unwantedSelectors) {
            articleBody
                .querySelectorAll(selector)
                .forEach((element) => element.remove());
          }

          // Aggressively remove any element containing "Follow Us" or social links
          articleBody.querySelectorAll('*').forEach((element) {
            // Strip style attributes to ensure dark theme consistency
            element.attributes.remove('style');

            final text = element.text.toLowerCase();
            if (text.contains('follow us') ||
                text.contains('subscribe') ||
                text.contains('read more')) {
              // Only remove if it's a small container
              if (element.text.length < 100) {
                element.remove();
              }
            }

            // Specific check for Bar & Bench / LiveLaw links in the body
            if (text.contains('bar & bench') ||
                text.contains('livelaw') ||
                text.contains('news')) {
              // Remove if it's a standalone link or small text block (likely breadcrumb)
              if (element.localName == 'a' || element.text.length < 30) {
                element.remove();
              }
            }
          });

          // Fix relative image URLs
          articleBody.querySelectorAll('img').forEach((img) {
            final src = img.attributes['src'];
            if (src != null && src.startsWith('/')) {
              final uri = Uri.parse(widget.url);
              img.attributes['src'] = '${uri.scheme}://${uri.host}$src';
            }
          });

          if (mounted) {
            setState(() {
              _fullContent = articleBody!.innerHtml;
              _isLoading = false;
            });
          }
        } else {
          debugPrint('Could not find article body. Using summary.');
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        debugPrint('Failed to fetch article: ${response.statusCode}');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching full article: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A032A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Article Reader',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                  child: LinearProgressIndicator(color: Color(0xFF6C63FF))),
            const SizedBox(height: 16),
            HtmlWidget(
              _fullContent ?? '<p>Could not load full content.</p>',
              textStyle: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                height: 1.6,
              ),
              onTapUrl: (url) async {
                return await _launchUrl(url);
              },
            ),
            const SizedBox(height: 32),
            const SizedBox(height: 32),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<bool> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }
}
