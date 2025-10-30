import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/features/home/app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 32, color: Colors.white), // Changed to standard menu icon
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        flexibleSpace: Stack(
          children: [
            Positioned.fill(
              child: Container(color: const Color(0xFF1A0B2E)),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 72, bottom: 12),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Welcome back, Alex ',
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text('👋', style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Iconsax.notification, size: 32, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildUpcomingEvents(),
              const SizedBox(height: 24),
              _buildAiUsage(),
              const SizedBox(height: 24),
              _buildLegalNewsFeed(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      children: [
        _buildStatCard('AI Queries', '247', '+23%', Iconsax.cpu_charge, const Color(0xFF00BFA6)),
        const SizedBox(height: 16),
        _buildStatCard('Documents', '45', '+12%', Iconsax.document_favorite, const Color(0xFF4CAF50)),
        const SizedBox(height: 16),
        _buildStatCard('Cases Tracked', '12', '+3', Iconsax.briefcase, const Color(0xFFFF9800)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String change, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 8),
                Text(value, style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Iconsax.arrow_up_1, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(change, style: const TextStyle(color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildQuickActionCard(context, 'AI Chat', 'Talk to Law Genie', Iconsax.messages_2, '/aiChat'),
            _buildQuickActionCard(context, 'Generate Doc', 'Create documents', Iconsax.document_upload, '/generateDoc'),
            _buildQuickActionCard(context, 'Risk Check', 'Assess risks', Iconsax.shield_tick, '/riskCheck'),
            _buildQuickActionCard(context, 'Case Timeline', 'Track cases', Iconsax.calendar_edit, '/caseTimeline'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, String subtitle, IconData icon, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF00BFA6)),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Flexible(
              child: Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upcoming Events', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('View All', style: GoogleFonts.poppins(fontSize: 16, color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 16),
        _buildEventCard('Contract Review Deadline', 'Tomorrow - 2:00 PM', 'deadline'),
        const SizedBox(height: 16),
        _buildEventCard('Court Hearing - Smith v. Johnson', 'Oct 25 - 10:00 AM', 'hearing'),
      ],
    );
  }

  Widget _buildEventCard(String title, String time, String type) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.calendar_1, color: Color(0xFF00BFA6)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(time, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: type == 'deadline' ? Colors.orange.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              type,
              style: TextStyle(color: type == 'deadline' ? Colors.orange : Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiUsage() {
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
            color: const Color(0xFF6B3E9A).withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Usage This Month', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          _buildUsageBar('Queries', 247, 500),
          const SizedBox(height: 16),
          _buildUsageBar('Documents', 45, 100),
          const SizedBox(height: 16),
          _buildUsageBar('Risk Checks', 23, 50),
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
              child: const Text('Upgrade Plan', style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBar(String title, int value, int total) {
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
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _buildLegalNewsFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Legal News Feed', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('View All', style: GoogleFonts.poppins(fontSize: 16, color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 16),
        _buildNewsCard('Privacy Law', 'New Data Privacy Regulations', 'Legal Gazette', '2h ago'),
        const SizedBox(height: 16),
        _buildNewsCard('IP Law', 'Supreme Court Ruling on IP Rights', 'Law Journal', '5h ago'),
      ],
    );
  }

  Widget _buildNewsCard(String category, String title, String source, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(category, style: const TextStyle(color: Color(0xFF00BFA6), fontWeight: FontWeight.bold)),
              ),
              Text(time, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(source, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
