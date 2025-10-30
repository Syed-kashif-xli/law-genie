import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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
    const Center(child: Text('Profile Page')),
  ];

  void _onTap(int index) {
    // Updated to navigate to the correct pages
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/aiChat');
        break;
      case 2:
        // Placeholder for Library Page
        break;
      case 3:
        Navigator.pushNamed(context, '/caseTimeline');
        break;
      case 4:
        // Placeholder for Profile Page
        break;
    }
  }

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
          _onTap(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A0B2E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.5),
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
