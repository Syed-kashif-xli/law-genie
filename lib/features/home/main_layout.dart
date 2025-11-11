import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/features/auth/login_page.dart';
import 'package:myapp/features/chat/chat_page.dart';
import 'package:myapp/features/home/home_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const AIChatPage(), // Use AIChatPage
    const Center(child: Text('Library Page')),
    const Center(child: Text('Timeline Page')),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A0B2E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withAlpha(128),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.message),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.folder_open),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.calendar),
            label: 'Timeline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1A0B2E),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signOut(context),
          child: const Text('Log Out'),
        ),
      ),
    );
  }
}
