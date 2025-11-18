import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/features/auth/auth_wrapper.dart';
import 'package:myapp/screens/edit_profile_screen.dart';
import 'package:myapp/screens/language_screen.dart';
import 'package:myapp/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Fallback values if user is null
    final displayName = _user?.displayName ?? l10n.anonymous;
    final email = _user?.email ?? l10n.noEmail;
    final photoUrl = _user?.photoURL;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        title: Text(l10n.profile, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
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
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
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
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
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
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
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
                  MaterialPageRoute(builder: (context) => const LanguageScreen()),
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
             ProfileMenuOption(
              title: l10n.logout,
              icon: Icons.logout,
              onTap: _signOut,
              showArrow: false,
            ),
            ProfileMenuOption(
              title: l10n.helpCenter,
              icon: Icons.help_outline,
              onTap: () {},
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
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
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
                color: Colors.black87,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
