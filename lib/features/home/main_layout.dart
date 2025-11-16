import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/features/auth/login_page.dart';
import 'package:myapp/features/chat/chat_page.dart';
import 'package:myapp/features/home/home_page.dart';
import 'package:myapp/screens/case_list_screen.dart';
import 'package:myapp/screens/notifications_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const AIChatPage(),
    const NotificationsScreen(),
    const CaseListScreen(),
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
            icon: Icon(Iconsax.notification),
            label: 'Notifications',
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
    final bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF19173A),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Iconsax.logout, color: Colors.white),
            title: const Text('Log Out', style: TextStyle(color: Colors.white)),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
