import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/home/app_drawer.dart';
import '../../features/home/widgets/news_card.dart';
import '../../features/home/widgets/feature_usage_section.dart';
import '../../features/home/providers/news_provider.dart';
import '../../features/home/pages/all_news_page.dart';
import '../../features/subscription/subscription_page.dart';
import '../../screens/notifications_screen.dart';
import '../../features/chat/chat_page.dart';
import '../../features/scanner/scanner_page.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_service.dart';
import 'widgets/inline_banner_ad_widget.dart';
import '../../services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // Initial fetch of news and events
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<NewsProvider>(context, listen: false).fetchNews();
      await NotificationService().requestNotificationPermissions();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        NotificationService().monitorUserOrders(user.uid);
      }
    });

    // Load Banner Ad
    _bannerAd = AdService.createBannerAd(
      onAdLoaded: (ad) {
        setState(() {
          _isAdLoaded = true;
        });
      },
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await Future.wait([
      Provider.of<NewsProvider>(context, listen: false)
          .fetchNews(forceRefresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Iconsax.menu_1, size: 24, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Iconsax.crown1,
                  size: 24, color: Color(0xFFFFD700)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SubscriptionPage()),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Iconsax.notification,
                  size: 24, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const AppDrawer(),
      body: RepaintBoundary(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: const Color(0xFF2C55A9),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const _HomeHeader(),
                          const SizedBox(height: 24),
                          const _StatsSection(),
                          const SizedBox(height: 24),
                          const _QuickActionsSection(),
                          const SizedBox(height: 24),
                          const FeatureUsageSection(),
                          const SizedBox(height: 30),
                          const _LegalNewsHeader(), // Extracted Header
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  const _NewsListSliver(), // Lazy loaded list
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          if (_isAdLoaded && _bannerAd != null) ...[
                            const SizedBox(height: 24),
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: _bannerAd!.size.width.toDouble(),
                                  height: _bannerAd!.size.height.toDouble(),
                                  child: AdWidget(ad: _bannerAd!),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            label: 'AI Chat',
            value: '5',
            icon: Iconsax.message_question,
            color: const Color(0xFF02F1C3),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            label: 'Documents',
            value: '12',
            icon: Iconsax.document_text,
            color: const Color(0xFFC5CAE9),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            label: 'Saved Cases',
            value: '8',
            icon: Iconsax.bookmark,
            color: const Color(0xFFF48FB1),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF19173A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              context,
              icon: Iconsax.message_add,
              label: 'New Chat',
              color: const Color(0xFF02F1C3),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIChatPage()),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Iconsax.scan,
              label: 'Scan',
              color: const Color(0xFFFFD700),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScannerPage()),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Iconsax.judge,
              label: 'Lawyer',
              color: const Color(0xFFFF6B6B),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Lawyer directory coming soon!'),
                      backgroundColor: Color(0xFF19173A)),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Welcome back,',
                        textStyle: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                  Text(
                    'Your Personal AI Legal Assistant',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegalNewsHeader extends StatelessWidget {
  const _LegalNewsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1DE9B6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Iconsax.global,
                  color: Color(0xFF1DE9B6), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Legal News',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AllNewsPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Iconsax.arrow_right_3,
                    color: Colors.white, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsListSliver extends StatelessWidget {
  const _NewsListSliver();

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.news.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF1DE9B6)),
              ),
            ),
          );
        } else if (provider.errorMessage != null) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Unable to load news',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => provider.fetchNews(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (provider.news.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No news articles found.',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ),
            ),
          );
        }

        final int displayNewsCount =
            provider.news.length > 10 ? 10 : provider.news.length;
        final int itemCount = displayNewsCount * 2;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index.isEven) {
                  // News Item
                  final newsIndex = index ~/ 2;
                  final item = provider.news[newsIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: NewsCard(news: item),
                  );
                } else {
                  // Ad Item
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: InlineBannerAdWidget(),
                  );
                }
              },
              childCount: itemCount,
            ),
          ),
        );
      },
    );
  }
}
