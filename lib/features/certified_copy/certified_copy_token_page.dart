import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import 'package:timeline_tile/timeline_tile.dart';

class CertifiedCopyTokenPage extends StatelessWidget {
  final String token;
  const CertifiedCopyTokenPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A032A),
              Color(0xFF1A0B4E),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF02F1C3).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.verify,
                    color: Color(0xFF02F1C3),
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Request Submitted!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your certified copy request has been successfully submitted. Track your status below.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF02F1C3).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Token Number',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        token,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF02F1C3),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildTimeline(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    child: Text(
                      'Back to Home',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildTimelineTile(
            isFirst: true,
            isLast: false,
            isPast: true,
            title: 'Request Received',
            subtitle: 'Token generated & payment verified',
            icon: Iconsax.receipt_item,
          ),
          _buildTimelineTile(
            isFirst: false,
            isLast: false,
            isPast: true, // Mark as "current/active" visually
            isPulse: true,
            title: 'Searching Records',
            subtitle: 'Our team is searching for the registry',
            icon: Iconsax.search_status,
          ),
          _buildTimelineTile(
            isFirst: false,
            isLast: true,
            isPast: false,
            title: 'Registry Status',
            subtitle: 'Found / Not Found (Pending)',
            icon: Iconsax.document_text,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile({
    required bool isFirst,
    required bool isLast,
    required bool isPast,
    bool isPulse = false,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(
        color: isPast ? const Color(0xFF02F1C3) : Colors.white24,
        thickness: 2,
      ),
      indicatorStyle: IndicatorStyle(
        width: 40,
        height: 40,
        indicator: Container(
          decoration: BoxDecoration(
            color: isPast
                ? const Color(0xFF02F1C3).withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: isPast ? const Color(0xFF02F1C3) : Colors.white24,
              width: 2,
            ),
            boxShadow: isPulse
                ? [
                    BoxShadow(
                      color: const Color(0xFF02F1C3).withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              icon,
              color: isPast ? const Color(0xFF02F1C3) : Colors.white54,
              size: 20,
            ),
          ),
        ),
      ),
      endChild: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 24, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isPast ? Colors.white : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: isPast ? Colors.white70 : Colors.white38,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
