import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';

import '../../features/home/app_drawer.dart';
import '../../features/home/widgets/news_card.dart';
import '../../features/home/widgets/feature_card.dart';
import '../../features/home/providers/news_provider.dart';
import '../../features/home/pages/all_news_page.dart';
import '../../screens/notifications_screen.dart';
import '../../features/ai_voice/ai_voice_page.dart';
import '../../features/chat/chat_page.dart';
import '../../screens/case_list_screen.dart';
import '../../features/translator/translator_page.dart';
import '../../features/case_finder/case_finder_page.dart';
import '../../features/bare_acts/bare_acts_page.dart';
import '../../features/risk_analysis/risk_analysis_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initial fetch of news and events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).fetchNews();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      Provider.of<NewsProvider>(context, listen: false).fetchNews(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 32, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        flexibleSpace: const _WelcomeMessage(),
        actions: [
          IconButton(
            icon:
                const Icon(Iconsax.notification, size: 32, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                _QuickActions(),
                const SizedBox(height: 24),
                const _LegalNewsFeed(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: const Color(0xFF0A032A)),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 72, bottom: 12),
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Welcome back',
                  textStyle: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Feature',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            FeatureCard(
              title: 'AI Chat',
              subtitle: 'Talk to Law Genie',
              icon: Iconsax.messages_2,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIChatPage()),
                );
              },
            ),
            FeatureCard(
              title: 'Generate Doc',
              subtitle: 'Create documents',
              icon: Iconsax.document_upload,
              onTap: () {
                Navigator.pushNamed(context, '/generateDoc');
              },
            ),
            FeatureCard(
              title: 'Chat History',
              subtitle: 'View past chats',
              icon: Iconsax.archive_book,
              onTap: () {
                Navigator.pushNamed(context, '/chatHistory');
              },
            ),
            FeatureCard(
              title: 'Case Timeline',
              subtitle: 'Track cases',
              icon: Iconsax.calendar_edit,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CaseListScreen()),
                );
              },
            ),
            FeatureCard(
              title: 'Court Order Reader',
              subtitle: 'Summarize orders',
              icon: Iconsax.document_text,
              onTap: () {
                Navigator.pushNamed(context, '/courtOrderReader');
              },
            ),
            FeatureCard(
              title: 'AI Voice',
              subtitle: 'Read text aloud',
              icon: Iconsax.microphone_2,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AiVoicePage()));
              },
            ),
            FeatureCard(
              title: 'Translator',
              subtitle: 'Text & Docs',
              icon: Iconsax.translate,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TranslatorPage()));
              },
            ),
            FeatureCard(
              title: 'Case Finder',
              subtitle: 'Legal Judgments',
              icon: Iconsax.search_favorite,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CaseFinderPage()));
              },
            ),
            FeatureCard(
              title: 'Bare Acts',
              subtitle: 'PDFs of Acts',
              icon: Iconsax.book_1,
              color: const Color(0xFFFF5722),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BareActsPage()));
              },
            ),
            FeatureCard(
              title: 'Risk Analysis',
              subtitle: 'Win Chance & Cost',
              icon: Iconsax.chart_square,
              color: const Color(0xFFFFD700),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RiskAnalysisPage()));
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _LegalNewsFeed extends StatelessWidget {
  const _LegalNewsFeed();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Legal News Feed',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllNewsPage()),
                );
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 4, 238, 203),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<NewsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.news.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  children: [
                    Text(
                      'Error: ${provider.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => provider.fetchNews(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (provider.news.isEmpty) {
              return const Center(
                child: Text(
                  'No news articles found.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.news.length > 5 ? 5 : provider.news.length,
              itemBuilder: (context, index) {
                final item = provider.news[index];
                return NewsCard(news: item);
              },
            );
          },
        ),
      ],
    );
  }
}
