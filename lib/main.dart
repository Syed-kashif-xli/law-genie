import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/features/ai_voice/ai_voice_page.dart';
import 'package:myapp/features/court_order_reader/court_order_reader_page.dart';
import 'package:myapp/features/home/main_layout.dart';
import 'package:myapp/models/chat_model.dart';
import 'package:myapp/features/case_timeline/timeline_provider.dart';
import 'package:myapp/providers/case_provider.dart';
import 'package:myapp/providers/chat_provider.dart';
import 'package:myapp/screens/case_list_screen.dart';
import 'package:myapp/screens/chat_history_screen.dart';
import 'package:myapp/features/chat/chat_page.dart';
import 'package:myapp/features/documents/document_generator_page.dart';
import 'package:myapp/features/home/providers/news_provider.dart';
import 'package:myapp/features/home/home_page.dart';
import 'package:myapp/features/onboarding/onboarding_page.dart';
import 'package:myapp/features/onboarding/splash_screen.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/screens/notifications_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/services/speech_to_text_service.dart';
import 'package:myapp/services/tts_service.dart';
import 'package:myapp/features/case_finder/case_finder_page.dart';
import 'package:myapp/features/bare_acts/bare_acts_page.dart';
import 'package:myapp/features/translator/translator_page.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:myapp/generated/app_localizations.dart';
import 'package:myapp/providers/locale_provider.dart';
import 'package:myapp/providers/ui_provider.dart';

import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize App Check with Debug Provider
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  await NotificationService().init();
  tz.initializeTimeZones();
  await Hive.initFlutter();
  Hive.registerAdapter(ChatSessionAdapter());
  Hive.registerAdapter(ChatMessageAdapter());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => TimelineProvider()),
        ChangeNotifierProvider(create: (context) => NewsProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => CaseProvider()),
        Provider(create: (context) => TtsService()),
        ChangeNotifierProvider(
            create: (context) => SpeechToTextService()..initialize()),
        ChangeNotifierProvider(create: (context) => UIProvider()),
      ],
      child: MyApp(currentUser: FirebaseAuth.instance.currentUser),
    ),
  );
}

class MyApp extends StatelessWidget {
  final User? currentUser;
  const MyApp({super.key, this.currentUser});

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

    return Consumer<LocaleProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'Law Genie',
          theme: newTheme,
          locale: provider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: currentUser == null ? const SplashScreen() : const MainLayout(),
          debugShowCheckedModeBanner: false,
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
          ],
          routes: {
            '/home': (context) => const HomePage(),
            '/generateDoc': (context) => const DocumentGeneratorPage(),
            '/caseList': (context) => const CaseListScreen(),
            '/chatHistory': (context) => const ChatHistoryScreen(),
            '/onboarding': (context) => const OnboardingPage(),
            '/notifications': (context) => const NotificationsScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/courtOrderReader': (context) => const CourtOrderReaderPage(),
            '/aiVoice': (context) => const AiVoicePage(),
            '/caseFinder': (context) => const CaseFinderPage(),
            '/bareActs': (context) => const BareActsPage(),
            '/translator': (context) => const TranslatorPage(),
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
      },
    );
  }
}
