
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/features/auth/login_page.dart';
import 'package:myapp/features/onboarding/onboarding_screen.dart';
import 'package:myapp/features/onboarding/onboarding_view_model.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: Consumer<OnboardingViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade800,
                    Colors.purple.shade800,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: viewModel.pageController,
                      onPageChanged: viewModel.onPageChanged,
                      children: const [
                        OnboardingScreen(
                          icon: Iconsax.message_question,
                          title: 'Chat with Law Genie',
                          description:
                              'Get instant AI-powered legal advice and answers to your questions 24/7.',
                        ),
                        OnboardingScreen(
                          icon: Iconsax.document_text,
                          title: 'Generate Legal Docs',
                          description:
                              'Create professional contracts, NDAs, and more with AI assistance.',
                        ),
                        OnboardingScreen(
                          icon: Iconsax.shield_tick,
                          title: 'Assess Legal Risks',
                          description:
                              'Analyze potential legal risks and get AI-powered recommendations.',
                        ),
                        OnboardingScreen(
                          icon: Iconsax.calendar_1,
                          title: 'Track Your Case Timeline',
                          description:
                              'Manage deadlines, hearings, and case milestones all in one place.',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        SmoothPageIndicator(
                          controller: viewModel.pageController,
                          count: 4,
                          effect: ExpandingDotsEffect(
                            activeDotColor: Colors.white,
                            dotColor: Color(0x80FFFFFF),
                            dotHeight: 10,
                            dotWidth: 10,
                            expansionFactor: 4,
                            spacing: 8,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
                                );
                              },
                              child: const Text(
                                'Skip',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (viewModel.currentPage == 3) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginPage()),
                                  );
                                } else {
                                  viewModel.nextPage();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.deepPurple,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                viewModel.currentPage == 3 ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
