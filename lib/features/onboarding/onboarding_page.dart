
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/features/auth/login_page.dart';
import 'package:visibility_detector/visibility_detector.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<GlobalKey<_AnimatedOnboardingScreenState>> _keys = [
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
        description: "Chat with Law Genie – Get instant AI-powered legal advice 24/7",
      ),
      AnimatedOnboardingScreen(
        key: _keys[1],
        icon: Iconsax.document_text,
        title: "Automated Document Analysis",
        subtitle: "AI-Powered Insights",
        description: "Upload and analyze legal documents instantly for key insights.",
      ),
      AnimatedOnboardingScreen(
        key: _keys[2],
        icon: Iconsax.folder_open,
        title: "Intelligent Case Management",
        subtitle: "Smart Organization",
        description: "Organize, track, and manage your legal cases with smart assistance.",
      ),
      AnimatedOnboardingScreen(
        key: _keys[3],
        icon: Iconsax.shield_tick,
        title: "Secure Client Collaboration",
        subtitle: "Encrypted Communication",
        description: "Communicate and share documents with clients in a secure, encrypted environment.",
      ),
    ];
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
            // Ambient circles for depth
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6B3E9A).withOpacity(0.4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B3E9A).withOpacity(0.6),
                      blurRadius: 100,
                      spreadRadius: 50,
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
                  color: Colors.blue.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.5),
                      blurRadius: 150,
                      spreadRadius: 70,
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
                      },
                      itemCount: _onboardingScreens.length,
                      itemBuilder: (context, index) {
                        return VisibilityDetector(
                          key: Key('onboarding_screen_$index'),
                          onVisibilityChanged: (visibilityInfo) {
                            if (visibilityInfo.visibleFraction > 0.5) {
                              _keys[index].currentState?.startAnimation();
                            }
                          },
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
                  const Spacer(flex: 2),
                  // Glowing Next Button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < _onboardingScreens.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 72),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.blueAccent.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.7),
                            blurRadius: 25,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Text(
                        _currentPage == _onboardingScreens.length - 1 ? 'Get Started' : 'Next',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
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
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blueAccent : const Color(0xFFD8D8D8).withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}


// A reusable animated widget
class AnimatedContent extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final double start;
  final double end;

  const AnimatedContent({
    super.key,
    required this.child,
    required this.animation,
    required this.start,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Interval(start, end, curve: Curves.easeIn),
      ),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Interval(start, end, curve: Curves.easeInOutBack),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Interval(start, end, curve: Curves.easeInOutBack),
          )),
          child: child,
        ),
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
  State<AnimatedOnboardingScreen> createState() => _AnimatedOnboardingScreenState();
}

class _AnimatedOnboardingScreenState extends State<AnimatedOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void startAnimation() {
    if (mounted && !_hasAnimated) {
      _animationController.forward();
      _hasAnimated = true;
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
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glowing Icon
                    AnimatedContent(
                      animation: _animationController,
                      start: 0.0,
                      end: 0.5,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.7),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 64),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Text Content
                    AnimatedContent(
                      animation: _animationController,
                      start: 0.2,
                      end: 0.7,
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedContent(
                      animation: _animationController,
                      start: 0.4,
                      end: 0.9,
                      child: Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedContent(
                      animation: _animationController,
                      start: 0.6,
                      end: 1.0,
                      child: Text(
                        widget.description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
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
