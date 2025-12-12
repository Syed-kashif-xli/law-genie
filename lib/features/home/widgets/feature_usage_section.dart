import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import 'package:myapp/features/risk_analysis/risk_analysis_page.dart';
import 'package:myapp/features/case_finder/case_finder_page.dart';
import 'package:myapp/screens/case_list_screen.dart';
import 'package:myapp/features/chat/chat_page.dart';
import 'package:myapp/features/scanner/scanner_page.dart';
import '../providers/usage_provider.dart';
import 'package:myapp/features/translator/translator_page.dart';
import 'package:myapp/features/bare_acts/bare_acts_page.dart';

import 'package:myapp/features/certified_copy/certified_copy_state_selection_page.dart';

import 'package:myapp/features/diary/diary_page.dart';
import 'package:myapp/features/home/pages/all_news_page.dart';

class FeatureUsageSection extends StatelessWidget {
  const FeatureUsageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UsageProvider>(
      builder: (context, usageProvider, child) {
        final isPremium = usageProvider.isPremium;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI Feature Usage',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF19173A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isPremium
                            ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                            : const Color(0xFF2C55A9).withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: isPremium
                            ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                            : const Color(0xFF2C55A9).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (isPremium) ...[
                        const Icon(Iconsax.crown1,
                            color: Color(0xFFFFD700), size: 16),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        isPremium ? 'Premium Plan' : 'Free Plan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isPremium
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF02F1C3),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Builder(
              builder: (context) {
                final cards = [
                  FeatureUsageCard(
                    title: 'AI Chat',
                    count: usageProvider.aiQueriesUsage,
                    limit: usageProvider.aiQueriesLimit,
                    icon: Iconsax.messages_2,
                    color: const Color(0xFF02F1C3),
                    isPremium: isPremium,
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
                    count: usageProvider.casesUsage,
                    limit: usageProvider.casesLimit,
                    icon: Iconsax.briefcase,
                    color: const Color(0xFF2C55A9),
                    isPremium: isPremium,
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
                    count: usageProvider.scanToPdfUsage,
                    limit: usageProvider.scanToPdfLimit,
                    icon: Iconsax.scan,
                    color: const Color(0xFFE040FB),
                    isPremium: isPremium,
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
                    count: usageProvider.documentsUsage,
                    limit: usageProvider.documentsLimit,
                    icon: Iconsax.document_text,
                    color: const Color(0xFFFF5722),
                    isPremium: isPremium,
                    onTap: () {
                      Navigator.pushNamed(context, '/generateDoc');
                    },
                  ),
                  FeatureUsageCard(
                    title: 'Risk Analysis',
                    count: usageProvider.riskAnalysisUsage,
                    limit: usageProvider.riskAnalysisLimit,
                    icon: Iconsax.chart_square,
                    color: const Color(0xFFFFD700),
                    isPremium: isPremium,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RiskAnalysisPage()),
                      );
                    },
                  ),
                  FeatureUsageCard(
                    title: 'Case Finder',
                    count: usageProvider.caseFinderUsage,
                    limit: usageProvider.caseFinderLimit,
                    icon: Iconsax.search_favorite,
                    color: const Color(0xFF9C27B0),
                    isPremium: isPremium,
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
                    count: usageProvider.courtOrdersUsage,
                    limit: usageProvider.courtOrdersLimit,
                    icon: Iconsax.document_text_1,
                    color: const Color(0xFF00BCD4),
                    isPremium: isPremium,
                    onTap: () {
                      Navigator.pushNamed(context, '/courtOrderReader');
                    },
                  ),
                  FeatureUsageCard(
                    title: 'Translator',
                    count: usageProvider.translatorUsage,
                    limit: usageProvider.translatorLimit,
                    icon: Iconsax.translate,
                    color: const Color(0xFF4CAF50),
                    isPremium: isPremium,
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
                    count: usageProvider.bareActsUsage,
                    limit: usageProvider.bareActsLimit,
                    icon: Iconsax.book_1,
                    color: const Color(0xFFFF9800),
                    isPremium: isPremium,
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
                    count: usageProvider.chatHistoryUsage,
                    limit: usageProvider.chatHistoryLimit,
                    icon: Iconsax.archive_book,
                    color: const Color(0xFF607D8B),
                    isPremium: isPremium,
                    onTap: () {
                      Navigator.pushNamed(context, '/chatHistory');
                    },
                  ),
                  FeatureUsageCard(
                    title: 'Certified Copy',
                    count: usageProvider.certifiedCopyUsage,
                    limit: usageProvider.certifiedCopyLimit,
                    icon: Iconsax.document_copy,
                    color: const Color(0xFFE91E63),
                    isPremium: isPremium,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CertifiedCopyStateSelectionPage()),
                      );
                    },
                  ),
                  FeatureUsageCard(
                    title: 'AI Legal Diary',
                    count: usageProvider.diaryUsage,
                    limit: usageProvider.diaryLimit,
                    icon: Iconsax.note_1,
                    color: const Color(0xFF00E5FF), // Cyan/Blue
                    isPremium: isPremium,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DiaryPage()),
                      );
                    },
                  ),
                ];

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: cards.map((card) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate width for 2 columns with spacing
                        // Screen width - padding (40) - spacing (16) = W - 56
                        // Using 60 to be safe
                        final width =
                            (MediaQuery.of(context).size.width - 60) / 2;
                        return SizedBox(
                          width: width,
                          height: width, // Square aspect ratio
                          child: card,
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
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
  final bool isPremium;

  const FeatureUsageCard({
    super.key,
    required this.title,
    required this.count,
    required this.limit,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPremium = false,
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
      duration: const Duration(seconds: 3), // Slower for less CPU
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
    // If premium, always show 100% full bar or specific indicator?
    // Actually, for Premium, we might not want to show a progress bar at all or a full gold one.
    // Let's show a full bar but maybe different color logic if desired.
    // For now, if premium, percentage is 1.0 logic-wise for display if we want 'full access',
    // but calculation-wise: count / limit (999999) is nearly 0.
    // So force it to 1.0 or hide it?
    // Let's hide the progress bar and "of Limit" text for Premium.

    final double percentage = widget.isPremium
        ? 1.0 // Full bar for premium? Or just hide it. Let's keep it full to look "active"
        : (widget.count / widget.limit).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF19173A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isPremium
                ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                : widget.color.withValues(alpha: 0.15),
            width: widget.isPremium ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: widget.isPremium
                  ? const Color(0xFFFFD700).withValues(alpha: 0.1)
                  : widget.color.withValues(alpha: 0.05),
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
              const Color(0xFF19173A).withValues(alpha: 0.8),
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
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.isPremium ? '∞' : widget.count.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    if (!widget.isPremium)
                      Text(
                        'of ${widget.limit}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      Text(
                        'Unlimited',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFFFFD700),
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

            // Progress Bar (Only for Free Users)
            if (!widget.isPremium) ...[
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  RepaintBoundary(
                    child: AnimatedBuilder(
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
                                      widget.color.withValues(alpha: 0.7),
                                      widget.color,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          widget.color.withValues(alpha: 0.5),
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
                                          Colors.white.withValues(alpha: 0.5),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                      ).createShader(rect);
                                    },
                                    blendMode: BlendMode.srcATop,
                                    child: Container(
                                      height: 8,
                                      color:
                                          Colors.white.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
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
            ] else ...[
              // Premium Indicator
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.5),
                            blurRadius: 6,
                          )
                        ]),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Active',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
