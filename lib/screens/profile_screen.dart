import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/features/auth/auth_wrapper.dart';
import 'package:myapp/screens/edit_profile_screen.dart';
import 'package:myapp/screens/language_screen.dart';
import 'package:myapp/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/ui_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  // Function to refresh user data
  void _updateUser() {
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
      (Route<dynamic> route) => false,
    );
  }

  void _showHelpCenter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF19173A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.support_agent, color: Color(0xFF02F1C3), size: 28),
            SizedBox(width: 12),
            Text(
              'Help Center',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need help? Contact us at:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A032A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF02F1C3).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email, color: Color(0xFF02F1C3), size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SelectableText(
                        'lawgenieoffical@gmail.com',
                        style: TextStyle(
                          color: Color(0xFF02F1C3),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy,
                        color: Color(0xFF02F1C3), size: 18),
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(
                          text: 'lawgenieoffical@gmail.com'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email copied to clipboard!'),
                          backgroundColor: Color(0xFF02F1C3),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We\'ll get back to you as soon as possible!',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF02F1C3)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Fallback values if user is null
    final displayName = _user?.displayName ?? l10n.anonymous;
    final email = _user?.email ?? l10n.noEmail;
    final photoUrl = _user?.photoURL;

    return Scaffold(
      backgroundColor: const Color(0xFF0A032A), // Dark background
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        title: Text(l10n.profile, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, // Transparent to match body
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A032A), // Match body background
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // -- PROFILE IMAGE
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                  backgroundColor: Colors.grey.shade300,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text for visibility
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70, // Light text for visibility
              ),
            ),
            const SizedBox(height: 30),

            // -- MENU OPTIONS
            ProfileMenuOption(
              title: l10n.editProfile,
              icon: Icons.person_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfileScreen()),
                ).then((value) {
                  if (value == true) {
                    _updateUser();
                  }
                });
              },
            ),
            ProfileMenuOption(
              title: l10n.paymentMethod,
              icon: Icons.credit_card,
              onTap: () {},
            ),
            ProfileMenuOption(
              title: l10n.language,
              icon: Icons.language_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LanguageScreen()),
                );
              },
            ),
            ProfileMenuOption(
              title: l10n.orderHistory,
              icon: Icons.history_outlined,
              onTap: () {},
            ),
            ProfileMenuOption(
              title: l10n.inviteFriends,
              icon: Icons.group_add_outlined,
              onTap: () {
                Share.share('Check out Law Genie, your AI Legal Partner!');
              },
            ),
            // Navigation Bar Toggle
            Consumer<UIProvider>(
              builder: (context, uiProvider, child) {
                return ProfileMenuOptionWithSwitch(
                  title: 'Show Navigation Bar',
                  icon: Icons.navigation_outlined,
                  value: uiProvider.isNavBarVisible,
                  onChanged: (value) {
                    uiProvider.toggleNavBar(value);
                  },
                );
              },
            ),
            ProfileMenuOption(
              title: l10n.logout,
              icon: Icons.logout,
              onTap: _signOut,
              showArrow: false,
            ),
            ProfileMenuOption(
              title: l10n.helpCenter,
              icon: Icons.help_outline,
              onTap: _showHelpCenter,
              showArrow: false,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenuOption extends StatelessWidget {
  const ProfileMenuOption({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.showArrow = true,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF19173A), // Dark theme
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: Colors.white, // White icon
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white, // White text for visibility
                  ),
                ),
              ),
              if (showArrow)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuOptionWithSwitch extends StatelessWidget {
  const ProfileMenuOptionWithSwitch({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF19173A), // Dark theme
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.white, // White icon
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white, // White text
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF2C55A9),
            ),
          ],
        ),
      ),
    );
  }
}
