import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/features/case_timeline/timeline_provider.dart';
import 'package:myapp/features/chat/chat_page.dart';
import 'package:myapp/features/documents/document_generator_page.dart';
import 'package:myapp/features/home/providers/news_provider.dart';
import 'package:myapp/features/risk_check/risk_check_page.dart';
import 'package:myapp/features/case_timeline/case_timeline_page.dart';
import 'package:myapp/features/home/home_page.dart';
import 'package:myapp/features/onboarding/onboarding_page.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimelineProvider()),
        ChangeNotifierProvider(create: (context) => NewsProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white.withAlpha(230)),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white.withAlpha(204)),
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
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor.withAlpha(204),
        elevation: 0,
        titleTextStyle: appTextTheme.titleLarge?.copyWith(fontSize: 24),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withAlpha(25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withAlpha(51)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: accentColor.withAlpha(204),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIconColor: Colors.white70,
        filled: true,
        fillColor: Colors.white.withAlpha(25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withAlpha(51)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor.withAlpha(204)),
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
