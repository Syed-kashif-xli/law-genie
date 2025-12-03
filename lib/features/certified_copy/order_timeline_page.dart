import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../services/firestore_service.dart';
import '../../models/order_model.dart';

class OrderTimelinePage extends StatefulWidget {
  final String token;

  const OrderTimelinePage({super.key, required this.token});

  @override
  State<OrderTimelinePage> createState() => _OrderTimelinePageState();
}

class _OrderTimelinePageState extends State<OrderTimelinePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Order Status',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
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
          child: StreamBuilder<OrderModel?>(
            stream: firestoreService.streamOrder(widget.token),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF02F1C3)));
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading order',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.close_circle,
                          color: Colors.redAccent, size: 64),
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
                        'Please check the token number and try again.',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    ],
                  ),
                );
              }

              final order = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildAnimatedTokenCard(order),
                    const SizedBox(height: 32),
                    _buildTimeline(order),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTokenCard(OrderModel order) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF02F1C3).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF02F1C3).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
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
              order.token,
              style: GoogleFonts.poppins(
                color: const Color(0xFF02F1C3),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(OrderModel order) {
    // Determine step states based on order.status
    // Statuses: 'received', 'searching', 'found', 'not_found'

    bool isReceivedCompleted = true;
    bool isSearchingCompleted = ['found', 'not_found'].contains(order.status);
    bool isSearchingActive = order.status == 'searching';
    bool isResultCompleted = ['found', 'not_found'].contains(order.status);

    String resultTitle = 'Registry Status';
    String resultSubtitle = 'Pending';
    IconData resultIcon = Iconsax.document_text;
    Color resultColor = const Color(0xFF02F1C3);

    if (order.status == 'found') {
      resultTitle = 'Registry Found';
      resultSubtitle = 'Please pay the remaining amount';
      resultIcon = Iconsax.tick_circle;
    } else if (order.status == 'not_found') {
      resultTitle = 'Registry Not Found';
      resultSubtitle = 'We could not locate the registry';
      resultIcon = Iconsax.close_circle;
      resultColor = Colors.redAccent;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            _buildTimelineTile(
              isFirst: true,
              isLast: false,
              isPast: isReceivedCompleted,
              title: 'Request Received',
              subtitle: 'Token generated & payment verified',
              icon: Iconsax.receipt_item,
            ),
            _buildTimelineTile(
              isFirst: false,
              isLast: false,
              isPast: isSearchingCompleted || isSearchingActive,
              isPulse: isSearchingActive,
              title: 'Searching Records',
              subtitle: 'Our team is searching for the registry',
              icon: Iconsax.search_status,
            ),
            _buildTimelineTile(
              isFirst: false,
              isLast: true,
              isPast: isResultCompleted,
              title: resultTitle,
              subtitle: resultSubtitle,
              icon: resultIcon,
              customColor: ['found', 'not_found'].contains(order.status)
                  ? resultColor
                  : null,
            ),
          ],
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
    Color? customColor,
  }) {
    final color = customColor ?? const Color(0xFF02F1C3);

    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(
        color: isPast ? color : Colors.white24,
        thickness: 2,
      ),
      indicatorStyle: IndicatorStyle(
        width: 40,
        height: 40,
        indicator: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isPulse ? _pulseAnimation.value : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: isPast
                      ? color.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPast ? color : Colors.white24,
                    width: 2,
                  ),
                  boxShadow: isPulse
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 10 * _pulseAnimation.value,
                            spreadRadius: 2 * _pulseAnimation.value,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: isPast ? color : Colors.white54,
                    size: 20,
                  ),
                ),
              ),
            );
          },
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
