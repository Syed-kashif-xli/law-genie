import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:myapp/features/home/main_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _fullPhoneNumber = '';

  bool _isEmailLogin = true;
  bool _agreedToTerms = true; // Set to true by default
  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;

  // Email & Password Sign-in
  Future<void> _signInWithEmailAndPassword() async {
    if (!_agreedToTerms) {
      // Should not happen with _agreedToTerms = true, but keep for safety
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null && mounted) {
        _navigateToHome();
      }
    } on FirebaseAuthException catch (e) {
      String message = e.code == 'user-not-found'
          ? 'No user found for that email.'
          : e.code == 'wrong-password'
              ? 'Wrong password provided for that user.'
              : 'An error occurred. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Phone Number Verification
  Future<void> _verifyPhoneNumber() async {
    if (!_agreedToTerms) {
      // Should not happen with _agreedToTerms = true, but keep for safety
      return;
    }
    if (_fullPhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid phone number.")),
      );
      return;
    }
    setState(() => _isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _fullPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (mounted) {
          setState(() => _isLoading = false);
          _navigateToHome();
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}")),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
            _codeSent = true;
          });
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
          });
        }
      },
    );
  }

  // OTP Sign-in
  Future<void> _signInWithOTP() async {
    if (_verificationId == null || _otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the OTP.")),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null && mounted) {
        _navigateToHome();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign in: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // Google Sign-in
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null && mounted) {
          _navigateToHome();
        }
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google Sign-In Failed. Please try again."))
      );
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainLayout()),
    );
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0B2E), Color(0xFF42218E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Ambient light effects
            Positioned( top: -100, left: -100, child: _buildAmbientLight(const Color(0xFF6B3E9A), 250, 100, 50)),
            Positioned( bottom: -150, right: -150, child: _buildAmbientLight(Colors.blue, 350, 150, 70)),
            // Main Content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    const Icon(Iconsax.user, color: Colors.white, size: 50),
                    const SizedBox(height: 16),
                    Text('Welcome Back', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Sign in to your Law Genie account', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 32),
                    _buildGlassCard(
                      child: Column(
                        children: [
                          _buildLoginTypeToggle(),
                          const SizedBox(height: 24),
                          
                          if (_isEmailLogin) ...[
                            _buildTextField('Email', Iconsax.sms, controller: _emailController, isEmail: true),
                            const SizedBox(height: 16),
                            _buildTextField('Password', Iconsax.lock_1, controller: _passwordController, isPassword: true),
                          ] else if (_codeSent) ...[
                            _buildTextField('OTP', Iconsax.password_check, controller: _otpController),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => setState(() {
                                  _codeSent = false;
                                  _otpController.clear();
                                  _verificationId = null;
                                }),
                                child: const Text('Change Number', style: TextStyle(color: Colors.white70)),
                              ),
                            )
                          ] else ...[
                            _buildPhoneField(),
                          ],
                          
                          const SizedBox(height: 16),
                          if (_isEmailLogin)
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text('Forgot password?', style: TextStyle(color: Colors.white70)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Removed _buildTermsAndConditions(),
                    const SizedBox(height: 24),
                    _buildGlowingButton(),
                    const SizedBox(height: 32),
                    const Text('Or continue with', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(FontAwesomeIcons.google),
                        const SizedBox(width: 24),
                        _buildSocialButton(FontAwesomeIcons.apple),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                        Text('Sign Up', style: TextStyle(color: Colors.blue.shade300, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientLight(Color color, double size, double blurRadius, double spreadRadius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLoginTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildToggleItem('Email', _isEmailLogin, () {
            if (!_isEmailLogin) {
              setState(() {
                _isEmailLogin = true;
                _codeSent = false;
                _otpController.clear();
                _verificationId = null;
              });
            }
          }),
          _buildToggleItem('Phone', !_isEmailLogin, () {
            if (_isEmailLogin) {
              setState(() => _isEmailLogin = false);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent.withOpacity(0.7) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 15, spreadRadius: 1)]
                : [],
          ),
          child: Center(
            child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isPassword = false, bool isEmail = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.8))),
      ),
    );
  }

  Widget _buildPhoneField() {
    return IntlPhoneField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Phone Number',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.8))),
      ),
      initialCountryCode: 'IN',
      onChanged: (phone) {
          _fullPhoneNumber = phone.completeNumber;
      },
    );
  }

  Widget _buildGlowingButton() {
    return GestureDetector(
      onTap: _isLoading ? null : () {
        if (_isEmailLogin) {
          _signInWithEmailAndPassword();
        } else {
          _codeSent ? _signInWithOTP() : _verifyPhoneNumber();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.blueAccent.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.7),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  _isEmailLogin ? 'Continue' : (_codeSent ? 'Verify OTP' : 'Send OTP'),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return GestureDetector(
      onTap: () {
        if (icon == FontAwesomeIcons.google) {
          _signInWithGoogle();
        }
        // TODO: Implement Apple Sign In
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: FaIcon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}