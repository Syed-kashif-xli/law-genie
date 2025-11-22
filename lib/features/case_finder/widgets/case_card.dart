import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/legal_case.dart';

class CaseCard extends StatelessWidget {
  final LegalCase legalCase;
  final VoidCallback? onTap;

  const CaseCard({
    super.key,
    required this.legalCase,
    this.onTap,
  });

  Future<void> _launchURL() async {
    if (legalCase.url != null) {
      final Uri url = Uri.parse(legalCase.url!);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch ${legalCase.url}');
      }
    }
  }

  Color _getCategoryColor() {
    switch (legalCase.category) {
      case 'Constitutional Law':
        return const Color(0xFF02F1C3);
      case 'Criminal Law':
        return const Color(0xFFFF6B6B);
      case 'Civil Law':
        return const Color(0xFF4ECDC4);
      case 'Family Law':
        return const Color(0xFFFFBE0B);
      case 'Labour Law':
        return const Color(0xFF95E1D3);
      case 'Tax Law':
        return const Color(0xFFF38181);
      case 'Property Law':
        return const Color(0xFFAA96DA);
      default:
        return const Color(0xFF02F1C3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1832),
            const Color(0xFF151028),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getCategoryColor().withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor().withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Court Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        legalCase.courtShortName,
                        style: GoogleFonts.poppins(
                          color: _getCategoryColor(),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Date
                    Text(
                      legalCase.formattedDate,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    // Category Badge
                    if (legalCase.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          legalCase.category!,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Case Title
                Text(
                  legalCase.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Case Number
                Text(
                  legalCase.caseNumber,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF02F1C3).withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (legalCase.summary != null) ...[
                  const SizedBox(height: 12),
                  // Summary
                  Text(
                    legalCase.summary!,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                // Footer Row
                Row(
                  children: [
                    if (legalCase.judgeName != null) ...[
                      Icon(
                        Icons.gavel_rounded,
                        size: 14,
                        color: Colors.white38,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          legalCase.judgeName!,
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Download PDF Button
                    if (legalCase.url != null)
                      InkWell(
                        onTap: _launchURL,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.download_rounded,
                                size: 14,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'PDF',
                                style: GoogleFonts.poppins(
                                  color: Colors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (legalCase.url != null) const SizedBox(width: 8),
                    // View Full Judgment Button
                    if (legalCase.url != null)
                      InkWell(
                        onTap: _launchURL,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getCategoryColor().withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View',
                                style: GoogleFonts.poppins(
                                  color: _getCategoryColor(),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 12,
                                color: _getCategoryColor(),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
