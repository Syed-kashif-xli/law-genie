import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/features/home/providers/news_provider.dart';
import 'package:myapp/features/home/widgets/news_card.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../services/ad_service.dart';

class AllNewsPage extends StatefulWidget {
  const AllNewsPage({super.key});

  @override
  State<AllNewsPage> createState() => _AllNewsPageState();
}

class _AllNewsPageState extends State<AllNewsPage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Legal News',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<NewsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.news.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Calculate total items: news items + 1 for ad (if loaded and we have at least 1 news)
            final showAd =
                _isAdLoaded && _bannerAd != null && provider.news.isNotEmpty;
            final itemCount = provider.news.length + (showAd ? 1 : 0);

            return ListView.builder(
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (showAd && index == 1) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    height: _bannerAd!.size.height.toDouble(),
                    width: _bannerAd!.size.width.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  );
                }

                // Adjust index for news items if ad is shown
                final newsIndex = (showAd && index > 1) ? index - 1 : index;
                final item = provider.news[newsIndex];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: NewsCard(news: item),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
