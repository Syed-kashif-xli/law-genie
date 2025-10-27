
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/features/home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isEmailLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade800,
              Colors.purple.shade800,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to your Law Genie account',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              // Email/Phone Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isEmailLogin = true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: isEmailLogin
                              ? BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(30),
                                )
                              : null,
                          child: const Center(
                            child: Text('Email', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isEmailLogin = false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: !isEmailLogin
                              ? BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(30),
                                )
                              : null,
                          child: const Center(
                            child: Text('Phone', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Form Fields
              if (isEmailLogin) ...[
                _buildTextField('Email', Icons.email_outlined),
                const SizedBox(height: 16),
                _buildTextField('Password', Icons.lock_outline, obscureText: true),
              ] else ...[
                _buildTextField('Phone', Icons.phone_outlined),
              ],
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('Forgot password?', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 24),
              // Terms and Conditions
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
                    checkColor: Colors.deepPurple,
                    fillColor: MaterialStateProperty.all(Colors.white),
                  ),
                  const Flexible(
                    child: Text(
                      'I accept the Terms and Conditions and Privacy Policy.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Continue Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Continue'),
              ),
              const SizedBox(height: 24),
              const Text('Or continue with', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              // Social Logins
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(FontAwesomeIcons.google, 'Google'),
                  const SizedBox(width: 16),
                  _buildSocialButton(FontAwesomeIcons.apple, 'Apple'),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                  Text('Sign Up', style: TextStyle(color: Colors.deepPurple.shade300, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: FaIcon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
