import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UIProvider extends ChangeNotifier {
  bool _isNavBarVisible = false;
  static const String _navBarKey = 'nav_bar_visible';

  UIProvider() {
    _loadPreferences();
  }

  bool get isNavBarVisible => _isNavBarVisible;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isNavBarVisible = prefs.getBool(_navBarKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleNavBar(bool value) async {
    _isNavBarVisible = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_navBarKey, value);
  }
}
