import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/features/chat/chat_page.dart';
import 'package:myapp/features/documents/document_generator_page.dart';
import 'package:myapp/features/risk_check/risk_check_page.dart';
import 'package:myapp/features/case_timeline/case_timeline_page.dart';
import 'package:myapp/features/home/home_page.dart';
import 'package:myapp/features/onboarding/onboarding_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6B3E9A);
    const Color accentColor = Colors.blueAccent;
    const Color backgroundColor = Color(0xFF1A0B2E);

    final TextTheme appTextTheme = GoogleFonts.lexendTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      displayLarge: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 57, color: Colors.white),
      titleLarge: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
    );

    final ThemeData futuristicTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
      ),
      textTheme: appTextTheme,

      // Component Themes
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor.withOpacity(0.8),
        elevation: 0,
        titleTextStyle: appTextTheme.titleLarge?.copyWith(fontSize: 24),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Glassmorphism Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),

      // Glowing Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: accentColor.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          elevation: 0, // Shadow is handled separately for the glow
        ),
      ),

      // Glassmorphism TextField Theme
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIconColor: Colors.white70,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor.withOpacity(0.8)),
        ),
      ),
    );

    return MaterialApp(
      title: 'Law Genie',
      theme: futuristicTheme,
      home: const OnboardingPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomePage(),
        '/aiChat': (context) => const AIChatPage(),
        '/generateDoc': (context) => const DocumentGeneratorPage(),
        '/riskCheck': (context) => const RiskCheckPage(),
        '/caseTimeline': (context) => const CaseTimelinePage(),
      },
    );
  }
}
