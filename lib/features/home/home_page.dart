import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/features/case_timeline/timeline_provider.dart';
import 'package:myapp/features/home/app_drawer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:myapp/features/home/widgets/event_card.dart';
import 'package:myapp/features/home/widgets/feature_card.dart';
import 'package:myapp/features/home/widgets/news_card.dart';
import 'package:myapp/features/home/providers/news_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/home/pages/all_news_page.dart';
import 'package:myapp/features/home/pages/all_events_page.dart';

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
      backgroundColor: const Color(0xFF1A0B2E),
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
        actions: const [
          Icon(Iconsax.notification, size: 32, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                _StatsSection(),
                SizedBox(height: 24),
                _QuickActions(),
                SizedBox(height: 24),
                _UpcomingEvents(),
                SizedBox(height: 24),
                _AiUsage(),
                SizedBox(height: 24),
                _LegalNewsFeed(),
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
          child: Container(color: const Color(0xFF1A0B2E)),
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

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _StatCard(
          title: 'AI Queries',
          value: '247',
          change: '+23%',
          icon: Iconsax.cpu_charge,
          iconColor: Color(0xFF00BFA6),
        ),
        const SizedBox(height: 16),
        const _StatCard(
          title: 'Documents',
          value: '45',
          change: '+12%',
          icon: Iconsax.document_favorite,
          iconColor: Color(0xFF4CAF50),
        ),
        const SizedBox(height: 16),
        const _StatCard(
          title: 'Cases Tracked',
          value: '12',
          change: '+3',
          icon: Iconsax.briefcase,
          iconColor: Color(0xFFFF9800),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(51)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Iconsax.arrow_up_1,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      change,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
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
          children: const [
            FeatureCard(
              title: 'AI Chat',
              subtitle: 'Talk to Law Genie',
              icon: Iconsax.messages_2,
              route: '/aiChat',
            ),
            FeatureCard(
              title: 'Generate Doc',
              subtitle: 'Create documents',
              icon: Iconsax.document_upload,
              route: '/generateDoc',
            ),
            FeatureCard(
              title: 'Risk Check',
              subtitle: 'Assess risks',
              icon: Iconsax.shield_tick,
              route: '/riskCheck',
            ),
            FeatureCard(
              title: 'Case Timeline',
              subtitle: 'Track cases',
              icon: Iconsax.calendar_edit,
              route: '/caseTimeline',
            ),
          ],
        ),
      ],
    );
  }
}

class _UpcomingEvents extends StatelessWidget {
  const _UpcomingEvents();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Events',
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
                  MaterialPageRoute(builder: (context) => const AllEventsPage()),
                );
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.blue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<TimelineProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.timeline.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.timeline.length > 2 ? 2 : provider.timeline.length,
              itemBuilder: (context, index) {
                final event = provider.timeline[index];
                return EventCard(event: event);
              },
            );
          },
        ),
      ],
    );
  }
}

class _AiUsage extends StatelessWidget {
  const _AiUsage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B3E9A), Color(0xFF4A148C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B3E9A).withAlpha(102),
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Usage This Month',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const _UsageBar(title: 'Queries', value: 247, total: 500),
          const SizedBox(height: 16),
          const _UsageBar(title: 'Documents', value: 45, total: 100),
          const SizedBox(height: 16),
          const _UsageBar(title: 'Risk Checks', value: 23, total: 50),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              ),
              child: const Text(
                'Upgrade Plan',
                style: TextStyle(
                  color: Color(0xFF0D47A1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  final String title;
  final int value;
  final int total;

  const _UsageBar({
    required this.title,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            Text('$value/$total', style: const TextStyle(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / total,
          backgroundColor: Colors.white.withAlpha(77),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          borderRadius: BorderRadius.circular(10),
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
              style: GoogleFonts.lato(
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
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.blue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<NewsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.news.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.news.length > 3 ? 3 : provider.news.length,
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
