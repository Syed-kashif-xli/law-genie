
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/chat_model.dart';
import 'package:myapp/features/case_timeline/timeline_provider.dart';
import 'package:myapp/providers/chat_provider.dart';
import 'package:myapp/screens/chat_history_screen.dart';
import 'package:myapp/features/chat/chat_page.dart';
import 'package:myapp/features/documents/document_generator_page.dart';
import 'package:myapp/features/home/providers/news_provider.dart';
import 'package:myapp/features/case_timeline/case_timeline_page.dart';
import 'package:myapp/features/home/home_page.dart';
import 'package:myapp/features/onboarding/onboarding_page.dart';
import 'package:myapp/features/onboarding/splash_screen.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  await Hive.initFlutter();
  Hive.registerAdapter(ChatSessionAdapter());
  Hive.registerAdapter(ChatMessageAdapter());


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimelineProvider()),
        ChangeNotifierProvider(create: (context) => NewsProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
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
    const Color accentColor = Color(0xFF02F1C3);
    const Color backgroundColor = Color(0xFF0A032A);

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
        backgroundColor: const Color(0xFF19173A),
        elevation: 0,
        titleTextStyle: appTextTheme.titleLarge?.copyWith(fontSize: 24),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF19173A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color(0xFF0A032A),
          backgroundColor: accentColor,
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
        fillColor: const Color(0xFF19173A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentColor),
        ),
      ),
    );

    return MaterialApp(
      title: 'Law Genie',
      theme: futuristicTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomePage(),
        '/aiChat': (context) => const AIChatPage(),
        '/generateDoc': (context) => const DocumentGeneratorPage(),
        '/caseTimeline': (context) => const CaseTimelinePage(),
        '/chatHistory': (context) => const ChatHistoryScreen(),
        '/onboarding': (context) => const OnboardingPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/aiChat') {
          final args = settings.arguments as ChatSession?;
          return MaterialPageRoute(
            builder: (context) {
              return AIChatPage(chatSession: args);
            },
          );
        }
        return null;
      },
    );
  }
}
