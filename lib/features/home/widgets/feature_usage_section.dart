import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/chat_provider.dart';
import 'package:myapp/providers/case_provider.dart';
import 'package:myapp/features/ai_voice/ai_voice_page.dart';

import 'package:myapp/features/risk_analysis/risk_analysis_page.dart';
import 'package:myapp/features/case_finder/case_finder_page.dart';
import 'package:myapp/screens/case_list_screen.dart';
import 'package:myapp/features/chat/chat_page.dart';
import 'package:myapp/features/translator/translator_page.dart';
import 'package:myapp/features/bare_acts/bare_acts_page.dart';
import 'package:myapp/features/scanner/scanner_page.dart';

class FeatureUsageSection extends StatelessWidget {
  const FeatureUsageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AI Feature',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF19173A),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: const Color(0xFF2C55A9).withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2C55A9).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Free Plan',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF02F1C3),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Consumer2<ChatProvider, CaseProvider>(
          builder: (context, chatProvider, caseProvider, child) {
            // Calculate total messages
            int totalMessages = 0;
            for (var session in chatProvider.chatSessions) {
              totalMessages += session.messages.length;
            }

            final casesCount = caseProvider.cases.length;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                FeatureUsageCard(
                  title: 'AI Queries',
                  count: totalMessages,
                  limit: 500,
                  icon: Iconsax.messages_2,
                  color: const Color(0xFF02F1C3),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AIChatPage()),
                    );
                  },
                ),
                FeatureUsageCard(
                  title: 'Cases',
                  count: casesCount,
                  limit: 50,
                  icon: Iconsax.briefcase,
                  color: const Color(0xFF2C55A9),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CaseListScreen()),
                    );
                  },
                ),
                FeatureUsageCard(
                  title: 'Scan to PDF',
                  count: 0, // Placeholder
                  limit: 50,
                  icon: Iconsax.scan,
                  color: const Color(0xFFE040FB),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ScannerPage()),
                    );
                  },
                ),
                FeatureUsageCard(
                  title: 'Documents',
                  count: 0, // Placeholder
                  limit: 20,
                  icon: Iconsax.document_text,
                  color: const Color(0xFFFF5722),
                  onTap: () {
                    Navigator.pushNamed(context, '/generateDoc');
                  },
                ),
                FeatureUsageCard(
                  title: 'Risk Analysis',
                  count: 0, // Placeholder
                  limit: 10,
                  icon: Iconsax.chart_square,
                  color: const Color(0xFFFFD700),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RiskAnalysisPage()),
                    );
                  },
                ),
                FeatureUsageCard(
                  title: 'AI Voice',
                  count: 0, // Placeholder
                  limit: 100,
                  icon: Iconsax.microphone_2,
                  color: const Color(0xFFE91E63),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AiVoicePage()),
                    );
                  },
                ),
                FeatureUsageCard(
                  title: 'Case Finder',
                  count: 0, // Placeholder
                  limit: 50,
                  icon: Iconsax.search_favorite,
                  color: const Color(0xFF9C27B0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CaseFinderPage()),
                    );
                  },
                ),
                FeatureUsageCard(
                  title: 'Court Orders',
                  count: 0, // Placeholder
                  limit: 30,
                  icon: Iconsax.document_text_1,
                  color: const Color(0xFF00BCD4),
                  onTap: () {
                    Navigator.pushNamed(context, '/courtOrderReader');
                  },
                ),
                FeatureUsageCard(
                  title: 'Translator',
                  count: 0, // Placeholder
                  limit: 100,
                  icon: Iconsax.translate,
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TranslatorPage()),
                    );
                  },
                ),
                FeatureUsageCard(
                  title: 'Bare Acts',
                  count: 0, // Placeholder
                  limit: 1000,
                  icon: Iconsax.book_1,
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BareActsPage()),
                    );
                  },
                ),
                FeatureUsageCard(
                  title: 'Chat History',
                  count: chatProvider.chatSessions.length,
                  limit: 100,
                  icon: Iconsax.archive_book,
                  color: const Color(0xFF607D8B),
                  onTap: () {
                    Navigator.pushNamed(context, '/chatHistory');
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class FeatureUsageCard extends StatefulWidget {
  final String title;
  final int count;
  final int limit;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const FeatureUsageCard({
    super.key,
    required this.title,
    required this.count,
    required this.limit,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<FeatureUsageCard> createState() => _FeatureUsageCardState();
}

class _FeatureUsageCardState extends State<FeatureUsageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = (widget.count / widget.limit).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF19173A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.color.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: widget.color.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF19173A),
              const Color(0xFF19173A).withOpacity(0.8),
              const Color(0xFF0A032A),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: widget.color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.count.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    Text(
                      'of ${widget.limit}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      widthFactor: percentage,
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.color.withOpacity(0.7),
                                  widget.color,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.color.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                          if (percentage > 0)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ShaderMask(
                                shaderCallback: (rect) {
                                  return LinearGradient(
                                    begin: Alignment(
                                        -1.0 + (_controller.value * 3), 0),
                                    end: Alignment(
                                        1.0 + (_controller.value * 3), 0),
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ).createShader(rect);
                                },
                                blendMode: BlendMode.srcATop,
                                child: Container(
                                  height: 8,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(percentage * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: widget.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
