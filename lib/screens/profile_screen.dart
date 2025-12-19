import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/features/auth/auth_wrapper.dart';
import 'package:myapp/screens/edit_profile_screen.dart';
import 'package:myapp/screens/language_screen.dart';
import 'package:myapp/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/ui_provider.dart';
import 'package:myapp/screens/order_history_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/screens/legal_detail_screen.dart';
import 'package:myapp/services/firestore_service.dart';

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
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF19173A),
        title: Text(l10n.deleteAccount,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n.deleteAccountConfirmation,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Delete Firestore data first (while we still have the UID and permissions)
        await FirestoreService().deleteUserData(user.uid);

        // Delete Auth Account
        await user.delete();

        // Navigate to Auth Wrapper
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthWrapper()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          if (e.code == 'requires-recent-login') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Security check: Please log out and log in again to delete your account.'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting account: ${e.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showHelpCenter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF19173A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF02F1C3).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent,
                      color: Color(0xFF02F1C3), size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  'How can we help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Our support team is always here to assist you with any questions or technical issues.',
              style:
                  TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            _buildSupportAction(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@lawgenie.co.in',
              color: Colors.blueAccent,
              onTap: () {
                Clipboard.setData(
                    const ClipboardData(text: 'support@lawgenie.co.in'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Support email copied!'),
                    backgroundColor: Colors.blueAccent,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSupportAction(
              icon: Icons.camera_alt_outlined,
              title: 'Instagram Support',
              subtitle: '@lawgenie.in',
              color: const Color(0xFFE4405F),
              onTap: () async {
                final Uri url =
                    Uri.parse('https://www.instagram.com/lawgenie.in');
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  debugPrint('Could not launch $url');
                }
              },
            ),
            const SizedBox(height: 12),
            _buildSupportAction(
              icon: Icons.qr_code_2_outlined,
              title: 'Scan QR Code',
              subtitle: 'Follow our legal journey',
              color: const Color(0xFF02F1C3),
              onTap: () {
                Navigator.pop(context);
                _showInstagramQR();
              },
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Available Mon-Sat, 10 AM - 7 PM',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  void _showInstagramQR() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF19173A),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE4405F), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  'assets/images/insta_qr.png',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Follow us on Instagram',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '@lawgenie.in',
                style: TextStyle(
                  color: Color(0xFFE4405F),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4405F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
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
                  backgroundColor: Colors.grey.shade300,
                  child: photoUrl == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
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
            // Payment Method Removed
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OrderHistoryScreen()),
                );
              },
            ),
            ProfileMenuOption(
              title: l10n.inviteFriends,
              icon: Icons.group_add_outlined,
              onTap: () {
                // ignore: deprecated_member_use
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
              title: l10n.deleteAccount,
              icon: Icons.delete_forever,
              onTap: _deleteAccount,
              showArrow: false,
              textColor: Colors.red,
              iconColor: Colors.red,
            ),
            const SizedBox(height: 20),
            // -- LEGAL SECTION
            _buildSectionHeader(l10n.legalAndPolicies),
            ProfileMenuOption(
              title: l10n.privacyPolicy,
              icon: Icons.privacy_tip_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LegalDetailScreen(
                    title: l10n.privacyPolicy,
                    assetPath: 'assets/legal/privacy_policy.md',
                  ),
                ),
              ),
            ),
            ProfileMenuOption(
              title: l10n.termsOfService,
              icon: Icons.description_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LegalDetailScreen(
                    title: l10n.termsOfService,
                    assetPath: 'assets/legal/terms_of_service.md',
                  ),
                ),
              ),
            ),
            ProfileMenuOption(
              title: l10n.refundPolicy,
              icon: Icons.assignment_return_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LegalDetailScreen(
                    title: l10n.refundPolicy,
                    assetPath: 'assets/legal/refund_policy.md',
                  ),
                ),
              ),
            ),
            ProfileMenuOption(
              title: l10n.disclaimer,
              icon: Icons.gavel_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LegalDetailScreen(
                    title: l10n.disclaimer,
                    assetPath: 'assets/legal/disclaimer.md',
                  ),
                ),
              ),
            ),
            ProfileMenuOption(
              title: l10n.helpCenter,
              icon: Icons.support_agent_outlined,
              onTap: _showHelpCenter,
              showArrow: true,
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 20),
            // Instagram Quick Link
            Center(
              child: InkWell(
                onTap: _showInstagramQR,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF833AB4),
                        Color(0xFFFD1D1D),
                        Color(0xFFFCB045),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFD1D1D).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Follow Us @lawgenie.in',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF02F1C3),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
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
    this.textColor,
    this.iconColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showArrow;
  final Color? textColor;
  final Color? iconColor;

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
                color: Colors.black.withValues(alpha: 0.3),
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
                color: iconColor ?? Colors.white, // White icon or custom
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? Colors.white, // White text or custom
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
              color: Colors.black.withValues(alpha: 0.3),
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
              activeThumbColor: const Color(0xFF2C55A9),
            ),
          ],
        ),
      ),
    );
  }
}
