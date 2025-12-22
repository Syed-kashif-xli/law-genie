import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../features/home/providers/usage_provider.dart';

class UsageDetailsScreen extends StatelessWidget {
  const UsageDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usageProvider = Provider.of<UsageProvider>(context);
    final isPremium = usageProvider.isPremium;

    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Plan & Usage',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Plan Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2575FC).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Icon(
                      isPremium ? Iconsax.crown1 : Iconsax.star,
                      color: isPremium ? const Color(0xFFFFD700) : Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPremium ? 'Premium Plan' : 'Free Plan',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isPremium && usageProvider.premiumExpiry != null)
                        Text(
                          'Expires: ${usageProvider.premiumExpiry!.day}/${usageProvider.premiumExpiry!.month}/${usageProvider.premiumExpiry!.year} (${usageProvider.premiumExpiry!.difference(DateTime.now()).inDays} days left)',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        Text(
                          isPremium
                              ? 'Active Subscription'
                              : 'Upgrade to Unlock',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Feature Usage',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Usage List
            _buildUsageCard(
                'Legal AI Chat',
                usageProvider.aiQueriesUsage,
                usageProvider.aiQueriesLimit,
                Iconsax.magic_star,
                const Color(0xFF02F1C3),
                isPremium),
            _buildUsageCard(
                'Case Search',
                usageProvider.caseFinderUsage,
                usageProvider.caseFinderLimit,
                Iconsax.search_status,
                const Color(0xFF9C27B0),
                isPremium),
            _buildUsageCard(
                'Document Scanner',
                usageProvider.scanToPdfUsage,
                usageProvider.scanToPdfLimit,
                Iconsax.scanner,
                const Color(0xFFE040FB),
                isPremium),
            _buildUsageCard(
                'Document Generator',
                usageProvider.documentsUsage,
                usageProvider.documentsLimit,
                Iconsax.document_favorite,
                const Color(0xFFFF5722),
                isPremium),
            _buildUsageCard(
                'Risk Analyzer',
                usageProvider.riskAnalysisUsage,
                usageProvider.riskAnalysisLimit,
                Iconsax.security_safe,
                const Color(0xFFFFD700),
                isPremium),
            _buildUsageCard(
                'Court Orders',
                usageProvider.courtOrdersUsage,
                usageProvider.courtOrdersLimit,
                Iconsax.judge,
                const Color(0xFF00BCD4),
                isPremium),
            _buildUsageCard(
                'Translator',
                usageProvider.translatorUsage,
                usageProvider.translatorLimit,
                Iconsax.language_square,
                const Color(0xFF4CAF50),
                isPremium),

            _buildUsageCard(
                'Legal Diary',
                usageProvider.diaryUsage,
                usageProvider.diaryLimit,
                Iconsax.personalcard,
                const Color(0xFF00E5FF),
                isPremium),
            _buildUsageCard(
                'My Cases',
                usageProvider.casesUsage,
                usageProvider.casesLimit,
                Iconsax.folder_favorite,
                const Color(0xFF2C55A9),
                isPremium),
            _buildUsageCard(
                'Chat History',
                usageProvider.chatHistoryUsage,
                usageProvider.chatHistoryLimit,
                Iconsax.archive_book,
                const Color(0xFF607D8B),
                isPremium),
            _buildUsageCard(
                'Bare Acts',
                usageProvider.bareActsUsage,
                usageProvider.bareActsLimit,
                Iconsax.book_1,
                const Color(0xFFFF9800),
                isPremium),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageCard(String title, int used, int limit, IconData icon,
      Color color, bool isPremium) {
    double progress = (limit > 0) ? (used / limit).clamp(0.0, 1.0) : 0.0;
    int remaining = (limit - used).clamp(0, limit);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF19173A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$used used of $limit limit',
                      style: GoogleFonts.poppins(
                          color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$remaining',
                    style: GoogleFonts.poppins(
                      color: remaining == 0 ? Colors.redAccent : color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Left',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
