import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _name = 'Guest';
  String _email = 'No email';

  String get name => _name;
  String get email => _email;

  UserProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _name = user.displayName ?? user.email?.split('@').first ?? 'User';
        _email = user.email ?? 'No email provided';
      } else {
        _name = 'Guest';
        _email = 'No email';
      }
      notifyListeners();
    });
  }

  void updateUser({required String name, required String email}) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      // Updating email is a sensitive operation that requires re-authentication.
      // For now, we'll update it locally.
      _name = name;
      _email = email;
      notifyListeners();
    }
  }
}
