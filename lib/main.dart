
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
    const Color primaryColor = Color(0xFF2C55A9);
    const Color accentColor = Color(0xFF83D0F5);
    const Color backgroundColor = Color(0xFFF0F4F8);
    const Color textColor = Color(0xFF1E293B);

    final TextTheme appTextTheme = GoogleFonts.lexendTextTheme(
      Theme.of(context).textTheme,
    ).copyWith(
      displayLarge: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 57, color: textColor),
      titleLarge: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 22, color: textColor),
      bodyLarge: TextStyle(fontSize: 16, color: textColor.withAlpha(230)),
      bodyMedium: TextStyle(fontSize: 14, color: textColor.withAlpha(204)),
    );

    final ThemeData newTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: appTextTheme.titleLarge?.copyWith(fontSize: 24),
        iconTheme: const IconThemeData(color: textColor),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: textColor),
        prefixIconColor: textColor,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );

    return MaterialApp(
      title: 'Law Genie',
      theme: newTheme,
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
