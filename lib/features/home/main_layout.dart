import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/features/chat/chat_page.dart';
import 'package:myapp/features/home/home_page.dart';
import 'package:myapp/screens/case_list_screen.dart';

import 'package:myapp/screens/profile_screen.dart'; // Import the new profile screen
import 'package:provider/provider.dart';
import 'package:myapp/providers/ui_provider.dart';

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
    const CaseListScreen(),
    const ProfileScreen(), // Use the new ProfileScreen
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<UIProvider>(
      builder: (context, uiProvider, child) {
        return PopScope(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            setState(() {
              _currentIndex = 0;
            });
          },
          child: Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            bottomNavigationBar: uiProvider.isNavBarVisible
                ? BottomNavigationBar(
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
                        icon: Icon(Iconsax.calendar),
                        label: 'Timeline',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Iconsax.user),
                        label: 'Profile',
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }
}
