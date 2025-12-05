import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'providers/usage_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: ClipRRect(
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A032A).withValues(alpha: 0.85),
                border: Border(
                  right: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildProPlanCard(context),
                  _buildMenuList(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 20, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2575FC).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Icon(Iconsax.judge, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Law Genie',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'AI Legal Assistant',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          Material(
            color: Colors.white.withValues(alpha: 0.2),
            shape: const CircleBorder(),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close, size: 20, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProPlanCard(BuildContext context) {
    final usageProvider = Provider.of<UsageProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2575FC).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Free Plan',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'UPGRADE',
                  style: GoogleFonts.poppins(
                      color: Colors.purple,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value:
                  usageProvider.aiQueriesUsage / usageProvider.aiQueriesLimit,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${usageProvider.aiQueriesUsage}/${usageProvider.aiQueriesLimit} queries used',
            style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        children: [
          _buildMenuItem(context, Iconsax.home_2, 'Dashboard', '/home'),
          _buildMenuItem(context, Iconsax.message, 'AI Chatbot', '/aiChat'),
          _buildMenuItem(
              context, Iconsax.document, 'Document Generator', '/generateDoc'),
          _buildMenuItem(
              context, Iconsax.search_favorite, 'Case Finder', '/caseFinder'),
          _buildMenuItem(context, Iconsax.book_1, 'Bare Acts', '/bareActs'),
          _buildMenuItem(
              context, Iconsax.translate, 'Translator', '/translator'),
          _buildMenuItem(context, Iconsax.microphone_2, 'AI Voice', '/aiVoice'),
          _buildMenuItem(context, Iconsax.document_text, 'Order Reader',
              '/courtOrderReader'),
          _buildMenuItem(
              context, Iconsax.archive_book, 'Chat History', '/chatHistory'),
          _buildMenuItem(
              context, Iconsax.calendar_1, 'Case Timeline', '/caseList'),
          _buildMenuItem(context, Iconsax.user, 'Profile', '/profile'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, String route,
      {bool isNew = false,
      bool isSelected = false,
      int notificationCount = 0}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('New',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            if (notificationCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$notificationCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
