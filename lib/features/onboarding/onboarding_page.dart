import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/features/auth/login_page.dart';
import 'package:myapp/features/onboarding/terms_and_conditions_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _agreedToTerms = false;
  final List<GlobalKey<_AnimatedOnboardingScreenState>> _keys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  late final List<Widget> _onboardingScreens;

  @override
  void initState() {
    super.initState();
    _onboardingScreens = [
      AnimatedOnboardingScreen(
        key: _keys[0],
        icon: Iconsax.message_question5,
        title: "Law Genie",
        subtitle: "Your AI Legal Partner",
        description:
            "Chat with Law Genie – Get instant AI-powered legal advice 24/7",
      ),
      AnimatedOnboardingScreen(
        key: _keys[1],
        icon: Iconsax.document_text,
        title: "Automated Document Analysis",
        subtitle: "AI-Powered Insights",
        description:
            "Upload and analyze legal documents instantly for key insights.",
      ),
      AnimatedOnboardingScreen(
        key: _keys[2],
        icon: Iconsax.folder_open,
        title: "Intelligent Case Management",
        subtitle: "Smart Organization",
        description:
            "Organize, track, and manage your legal cases with smart assistance.",
      ),
      AnimatedOnboardingScreen(
        key: _keys[3],
        icon: Iconsax.shield_tick,
        title: "Secure Client Collaboration",
        subtitle: "Encrypted Communication",
        description:
            "Communicate and share documents with clients in a secure, encrypted environment.",
      ),
      AnimatedOnboardingScreen(
        key: _keys[4],
        icon: Iconsax.document,
        title: "Terms and Conditions",
        subtitle: "Usage Agreement",
        description:
            "By using this app, you agree to our terms and conditions.",
      ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keys[0].currentState?.startAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0B2E), Color(0xFF42218E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Ambient circles for depth (Optimized)
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6B3E9A).withAlpha(60),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B3E9A).withAlpha(80),
                      blurRadius: 40, // Reduced for performance
                      spreadRadius: 20, // Reduced for performance
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -150,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withAlpha(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withAlpha(80),
                      blurRadius: 60, // Reduced for performance
                      spreadRadius: 30, // Reduced for performance
                    ),
                  ],
                ),
              ),
            ),
            // Main Content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  Expanded(
                    flex: 12,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                        _keys[page].currentState?.startAnimation();
                      },
                      itemCount: _onboardingScreens.length,
                      itemBuilder: (context, index) {
                        return RepaintBoundary(
                          child: _onboardingScreens[index],
                        );
                      },
                    ),
                  ),
                  const Spacer(flex: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingScreens.length,
                      (index) => buildDot(index: index),
                    ),
                  ),
                  if (_currentPage == _onboardingScreens.length - 1)
                    const Spacer(),
                  if (_currentPage == _onboardingScreens.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Theme(
                            data: ThemeData(
                                unselectedWidgetColor: Colors.white70),
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: (bool? value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                              activeColor: Colors.blueAccent,
                              checkColor: Colors.white,
                            ),
                          ),
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                text: 'I agree to the ',
                                style: GoogleFonts.lato(
                                    color: Colors.white, fontSize: 14),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Terms and Conditions',
                                      style: GoogleFonts.lato(
                                        color: Colors.blueAccent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        decoration:
                                            TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const TermsAndConditionsPage(),
                                            ),
                                          );
                                        }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(flex: 2),
                  // Glowing Next Button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < _onboardingScreens.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.fastOutSlowIn, // Smoother curve
                        );
                      } else {
                        if (_agreedToTerms) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  const LoginPage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please agree to the Terms and Conditions to continue.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 64),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.blueAccent.withAlpha(180),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withAlpha(120),
                            blurRadius: 15, // Reduced for performance
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Text(
                        _currentPage == _onboardingScreens.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Colors.blueAccent
            : const Color(0xFFD8D8D8).withAlpha(100),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class AnimatedContent extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final double start;

  const AnimatedContent({
    super.key,
    required this.child,
    required this.animation,
    required this.start,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Interval(start, 1.0, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Interval(start, 1.0, curve: Curves.easeOut),
        )),
        child: child,
      ),
    );
  }
}

class AnimatedOnboardingScreen extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  const AnimatedOnboardingScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  State<AnimatedOnboardingScreen> createState() =>
      _AnimatedOnboardingScreenState();
}

class _AnimatedOnboardingScreenState extends State<AnimatedOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450), // Fast animation
    );
  }

  void startAnimation() {
    if (mounted) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withAlpha(35)),
            ),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContent(
                      animation: _animationController,
                      start: 0.0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withAlpha(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withAlpha(100),
                              blurRadius: 18, // Reduced for performance
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 60),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedContent(
                      animation: _animationController,
                      start: 0.2,
                      child: Text(widget.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 12),
                    AnimatedContent(
                      animation: _animationController,
                      start: 0.3,
                      child: Text(widget.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              color: Colors.white.withAlpha(220),
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                    ),
                    const SizedBox(height: 16),
                    AnimatedContent(
                      animation: _animationController,
                      start: 0.4,
                      child: Text(widget.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              color: Colors.white.withAlpha(200),
                              fontSize: 15,
                              height: 1.4)),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
