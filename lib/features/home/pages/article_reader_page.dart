import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../services/ad_service.dart';

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
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _fullContent = widget.content;
    _fetchFullArticle();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdService.createBannerAd(
      onAdLoaded: (ad) {
        setState(() {
          _isAdLoaded = true;
        });
      },
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
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
          // Remove H1 tags to prevent double headings (since we show title in AppBar/Body)
          articleBody
              .querySelectorAll('h1')
              .forEach((element) => element.remove());

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
            '.submitted-by',
            '.join-group',
            '.telegram-widget',
            '.whatsapp-widget'
          ];

          for (final selector in unwantedSelectors) {
            articleBody
                .querySelectorAll(selector)
                .forEach((element) => element.remove());
          }

          // Aggressively remove any element containing "Follow Us" or social links
          // But CAREFULLY preserve PDF downloads
          articleBody.querySelectorAll('*').forEach((element) {
            // Strip style attributes to ensure dark theme consistency
            element.attributes.remove('style');

            final text = element.text.toLowerCase();

            // Check for promotional text
            bool isPromotional = text.contains('follow us') ||
                text.contains('subscribe') ||
                text.contains('read more') ||
                text.contains('join our') ||
                text.contains('join whatsapp') ||
                text.contains('join telegram') ||
                text.contains('follow bar and bench') ||
                text.contains('follow livelaw');

            // Check if it might be a valid download link
            bool isDownload = text.contains('download') || text.contains('pdf');

            // Remove if it's promotional AND (not a download link OR the promotional text is very specific)
            if (isPromotional) {
              // If it's a small container, it's likely a footer/button
              if (element.text.length < 200) {
                // Special case: If it says "Download PDF", we might want to keep it
                // But often "Join our WhatsApp to get PDF" is spam.
                // Let's assume if it says "Join" or "Follow", it's spam even if it mentions PDF.
                element.remove();
              }
            }

            // Specific check for Bar & Bench / LiveLaw links in the body if they look like clutter
            if (text.contains('bar & bench') ||
                text.contains('livelaw') ||
                text.contains('news')) {
              // Remove if it's a standalone link or small text block (likely breadcrumb or source citation)
              if ((element.localName == 'a' || element.text.length < 50) &&
                  !isDownload) {
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
            if (_isAdLoaded && _bannerAd != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
              const SizedBox(height: 24),
            ],
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
