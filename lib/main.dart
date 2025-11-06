import 'package:flutter/material.dart';
import 'package:myapp/features/auth/login_page.dart';
import 'package:myapp/features/case_timeline/case_timeline_page.dart';
import 'package:myapp/features/chat/chat_page.dart';
import 'package:myapp/features/home/main_layout.dart';
import 'package:myapp/features/onboarding/onboarding_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/features/profile/change_password_page.dart';
import 'package:myapp/features/profile/edit_profile_page.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'LawGenie',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Poppins',
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Poppins',
              brightness: Brightness.dark,
            ),
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const OnboardingPage(),
              '/login': (context) => const LoginPage(),
              '/home': (context) => const MainLayout(),
              '/aiChat': (context) => const AIChatPage(),
              '/caseTimeline': (context) => const CaseTimelinePage(),
              '/editProfile': (context) => const EditProfilePage(),
              '/changePassword': (context) => const ChangePasswordPage(),
            },
          );
        },
      ),
    );
  }
}
