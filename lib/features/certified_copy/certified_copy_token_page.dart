import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../services/firestore_service.dart';
import '../../models/order_model.dart';
import 'certified_copy_preview_page.dart';
import 'track_order_page.dart';

class CertifiedCopyTokenPage extends StatelessWidget {
  final String token;
  final FirestoreService _firestoreService = FirestoreService();

  CertifiedCopyTokenPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const TrackOrderPage()));
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TrackOrderPage()));
              },
            ),
          ),
          title: Text(
            'Track Order',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A032A),
                Color(0xFF1A0B4E),
                Color(0xFF2D1B69),
              ],
            ),
          ),
          child: SafeArea(
            child: StreamBuilder<OrderModel?>(
              stream: _firestoreService.streamOrder(token.trim()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final order = snapshot.data;

                if (order == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.close_circle,
                            color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'Order Not Found',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please check the token number.',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final status = order.status;
                final previewAvailable = order.previewUrl != null;
                final isCompleted =
                    status == 'completed' || order.finalFileUrl != null;

                // Helper to check if a step is active/past
                bool isStepActive(int stepIndex) {
                  if (stepIndex == 0) return true;
                  if (stepIndex == 1) {
                    return ['searching', 'found', 'not_found', 'completed']
                        .contains(status);
                  }
                  if (stepIndex == 2) {
                    return ['found', 'not_found', 'completed']
                            .contains(status) ||
                        previewAvailable;
                  }
                  return false;
                }

                // Helper to check if a step is currently in progress (pulsing)
                bool isStepPulsing(int stepIndex) {
                  if (stepIndex == 1) return status == 'searching';
                  if (stepIndex == 2) {
                    return (previewAvailable && !isCompleted) ||
                        status == 'found';
                  }
                  return false;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Token Card with Glassmorphism
                      _buildGlassCard(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF02F1C3)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.ticket,
                                color: Color(0xFF02F1C3),
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Order Token',
                              style: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              token,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Timeline
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildTimelineTile(
                              isFirst: true,
                              isLast: false,
                              isPast: isStepActive(0),
                              title: 'Request Received',
                              subtitle: 'Token generated & payment verified',
                              icon: Iconsax.receipt_item,
                            ),
                            _buildTimelineTile(
                              isFirst: false,
                              isLast: false,
                              isPast: isStepActive(1),
                              isPulse: isStepPulsing(1),
                              title: 'Searching Records',
                              subtitle:
                                  'Our team is searching for the registry',
                              icon: Iconsax.search_status,
                            ),
                            _buildTimelineTile(
                              isFirst: false,
                              isLast: true,
                              isPast: isStepActive(2),
                              isPulse: isStepPulsing(2),
                              title: 'Registry Status',
                              subtitle: isCompleted
                                  ? 'File will be provided within 5 hours'
                                  : previewAvailable
                                      ? 'Preview Available'
                                      : 'Pending',
                              icon: Iconsax.document_text,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (previewAvailable && !isCompleted)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF02F1C3)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CertifiedCopyPreviewPage(
                                                order: order),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF02F1C3),
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Iconsax.eye, size: 24),
                                      const SizedBox(width: 12),
                                      Text(
                                        'View Preview',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      if (isCompleted && order.finalFileUrl != null)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF02F1C3)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CertifiedCopyPreviewPage(
                                          order: order,
                                          isFinalFile: true,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF02F1C3),
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Iconsax.document_download,
                                          size: 24),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Download Certified Copy',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: child,
        ),
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
        color: isPast ? const Color(0xFF02F1C3) : Colors.white12,
        thickness: 2,
      ),
      indicatorStyle: IndicatorStyle(
        width: 50,
        height: 50,
        indicator: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A032A),
            shape: BoxShape.circle,
            border: Border.all(
              color: isPast ? const Color(0xFF02F1C3) : Colors.white12,
              width: 2,
            ),
            boxShadow: isPast
                ? [
                    BoxShadow(
                      color: const Color(0xFF02F1C3).withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Icon(
              icon,
              color: isPast ? const Color(0xFF02F1C3) : Colors.white38,
              size: 24,
            ),
          ),
        ),
      ),
      endChild: Container(
        margin: const EdgeInsets.only(left: 20, bottom: 40, top: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPast
              ? const Color(0xFF02F1C3).withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPast
                ? const Color(0xFF02F1C3).withValues(alpha: 0.1)
                : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isPast ? Colors.white : Colors.white60,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: isPast ? Colors.white70 : Colors.white38,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
