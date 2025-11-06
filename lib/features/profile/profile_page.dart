import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF8A52F3),
                            Color(0xFF6430D9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Iconsax.user,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      userProvider.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8A52F3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Pro Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingsCard(
                context,
                [
                  _buildSettingsItem(
                    icon: Iconsax.user_edit,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () => Navigator.pushNamed(context, '/editProfile'),
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.direct,
                    title: 'Email',
                    subtitle: userProvider.email,
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.key,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    onTap: () => Navigator.pushNamed(context, '/changePassword'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingsCard(
                context,
                [
                  _buildSettingsItem(
                      icon: Iconsax.moon,
                      title: 'Dark Mode',
                      subtitle: themeProvider.themeMode == ThemeMode.dark
                          ? 'Enabled'
                          : 'Disabled',
                      trailing: Switch(
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                        activeColor: const Color(0xFF6430D9),
                      )),
                  _buildSettingsItem(
                    icon: Iconsax.notification,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                  ),
                  _buildSettingsItem(
                    icon: Iconsax.global,
                    title: 'Language',
                    subtitle: 'English (US)',
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final authProvider = context.read<AuthProvider>();
                    authProvider.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  },
                  icon: const Icon(Iconsax.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EAFE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF6430D9), size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}
