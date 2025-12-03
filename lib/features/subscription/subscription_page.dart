import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/payment_service.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentIndex = 1; // Start with Pro (middle option)
  late AnimationController _shimmerController;
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _paymentService = PaymentService(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Successful: ${response.paymentId}"),
        backgroundColor: Colors.green,
      ),
    );
    // NOTE: Update user subscription status in backend
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet: ${response.walletName}"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _paymentService.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Free',
      'price': '₹0',
      'period': '/month',
      'description': 'Essential tools for every citizen',
      'color': const Color(0xFF4CAF50),
      'features': [
        'Basic Case Search',
        'Limited AI Queries (5/day)',
        'Community Support',
        'Standard Access',
      ],
      'isPopular': false,
      'isBestValue': false,
    },
    {
      'name': 'Pro',
      'price': '₹499',
      'period': '/month',
      'description': 'Advanced power for legal professionals',
      'color': const Color(0xFF02F1C3),
      'features': [
        'Unlimited Case Search',
        'Advanced AI Assistant',
        'Document Generator',
        'No Ads',
        'Priority Support',
      ],
      'isPopular': true,
      'isBestValue': false,
    },
    {
      'name': 'Ultra Pro',
      'price': '₹999',
      'period': '/month',
      'description': 'The ultimate legal command center',
      'color': const Color(0xFFFFD700),
      'features': [
        'All Pro Features',
        'Priority Legal Consultation',
        'Certified Copies (Fast Track)',
        'Voice Assistant (Unlimited)',
        'Exclusive Templates',
        '24/7 Dedicated Support',
      ],
      'isPopular': false,
      'isBestValue': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          'Choose Your Plan',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A032A),
              Color(0xFF1A0B4E),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Ambient Background Effects
            Positioned(
              top: -100,
              right: -100,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF02F1C3).withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7B1FA2).withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Unlock the Full Power\nof Law Genie',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      shadows: [
                        BoxShadow(
                          color: const Color(0xFF02F1C3).withValues(alpha: 0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose a plan that fits your legal needs',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Plan Carousel
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemCount: _plans.length,
                      itemBuilder: (context, index) {
                        return _buildPlanCard(index);
                      },
                    ),
                  ),

                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _plans.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? const Color(0xFF02F1C3)
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: _currentIndex == index
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF02F1C3)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  )
                                ]
                              : [],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Action Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                _plans[_currentIndex]['color'],
                                _plans[_currentIndex]['color']
                                    .withValues(alpha: 0.8),
                                _plans[_currentIndex]['color'],
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment(
                                  -1.0 + (_shimmerController.value * 2), -0.5),
                              end: Alignment(
                                  1.0 + (_shimmerController.value * 2), 0.5),
                              tileMode: TileMode.mirror,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _plans[_currentIndex]['color']
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();

                              if (_currentIndex == 0) {
                                // Free plan logic
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'You are already on the Free Plan')),
                                );
                                return;
                              }

                              final user = FirebaseAuth.instance.currentUser;
                              final email = user?.email ?? 'user@example.com';
                              final phone = user?.phoneNumber ?? '9876543210';

                              // Amount calculation (Example: Pro = 499, Ultra = 999)
                              // User requested 2000 specifically, but let's use plan price or 2000 as fallback
                              double amount = 2000.0;
                              if (_plans[_currentIndex]['price'] == '₹499') {
                                amount = 499.0;
                              }
                              if (_plans[_currentIndex]['price'] == '₹999') {
                                amount = 999.0;
                              }

                              // Override for user request if needed, but sticking to plan price is safer.
                              // User said "2000 bhi razar pay se hogya", implies maybe a specific service or just general.
                              // Let's stick to the plan price for now.

                              _paymentService.openCheckout(
                                amount: amount,
                                description:
                                    'Subscription: ${_plans[_currentIndex]['name']}',
                                contact: phone,
                                email: email,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              _currentIndex == 0
                                  ? 'Get Started'
                                  : 'Upgrade Now',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    final plan = _plans[index];
    final isSelected = _currentIndex == index;
    final color = plan['color'] as Color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: isSelected ? 0 : 30,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF19173A).withValues(alpha: 0.95),
            const Color(0xFF19173A).withValues(alpha: 0.85),
            if (isSelected)
              color.withValues(alpha: 0.15)
            else
              Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: -5,
                )
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            children: [
              if (plan['isPopular'])
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      'MOST POPULAR',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              if (plan['isBestValue'])
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      'BEST VALUE',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      plan['name'],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan['description'],
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          plan['price'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            plan['period'],
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Divider(color: Colors.white.withValues(alpha: 0.1)),
                    const SizedBox(height: 24),
                    ...List.generate((plan['features'] as List).length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check,
                                color: color,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                plan['features'][i],
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
