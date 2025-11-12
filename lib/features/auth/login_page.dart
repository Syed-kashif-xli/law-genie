import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:myapp/features/home/main_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/services/firestore_service.dart';

class LoginPage extends StatefulWidget {
  final bool agreedToTerms;
  const LoginPage({super.key, this.agreedToTerms = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _fullPhoneNumber = '';

  bool _isEmailLogin = true;
  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;
  bool _isSignUp = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _handleAuthAction() async {
    if (_isEmailLogin) {
      if (_isSignUp) {
        _signUpWithEmailAndPassword();
      } else {
        _signInWithEmailAndPassword();
      }
    } else {
      if (_codeSent) {
        _signInWithOTP();
      } else {
        _verifyPhoneNumber();
      }
    }
  }

  Future<void> _signUpWithEmailAndPassword() async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null && mounted) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': userCredential.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _navigateToHome(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = e.code == 'weak-password'
          ? 'The password provided is too weak.'
          : e.code == 'email-already-in-use'
              ? 'An account already exists for that email.'
              : 'An error occurred. Please try again.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null && mounted) {
        _navigateToHome(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = e.code == 'user-not-found'
          ? 'No user found for that email.'
          : e.code == 'wrong-password'
              ? 'Wrong password provided for that user.'
              : 'An error occurred. Please try again.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyPhoneNumber() async {
    if (_fullPhoneNumber.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid phone number.")),
      );
      return;
    }
    setState(() => _isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _fullPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        if (mounted) {
          if (userCredential.additionalUserInfo?.isNewUser ?? false) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'phoneNumber': userCredential.user!.phoneNumber,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
          setState(() => _isLoading = false);
          _navigateToHome(userCredential.user!);
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

  Future<void> _signInWithOTP() async {
    if (_verificationId == null || _otpController.text.isEmpty) {
      if (!mounted) return;
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
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null && mounted) {
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'phoneNumber': userCredential.user!.phoneNumber,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        _navigateToHome(userCredential.user!);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign in: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null && mounted) {
          if (userCredential.additionalUserInfo?.isNewUser ?? false) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'email': userCredential.user!.email,
              'displayName': userCredential.user!.displayName,
              'photoURL': userCredential.user!.photoURL,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
          _navigateToHome(userCredential.user!);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("Google Sign-In Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Google Sign-In Failed. Please try again.")));
    }
  }

  void _navigateToHome(User user) async {
    if (widget.agreedToTerms) {
      await _firestoreService.saveTermsAcceptance(user.uid);
    }
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
            Positioned(
                top: -100,
                left: -100,
                child:
                    _buildAmbientLight(const Color(0xFF6B3E9A), 250, 100, 50)),
            Positioned(
                bottom: -150,
                right: -150,
                child: _buildAmbientLight(Colors.blue, 350, 150, 70)),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      const Icon(Iconsax.user, color: Colors.white, size: 50),
                      const SizedBox(height: 16),
                      Text(_isSignUp ? 'Create Account' : 'Welcome Back',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                          _isSignUp
                              ? 'Create a new Law Genie account'
                              : 'Sign in to your Law Genie account',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.white70)),
                      const SizedBox(height: 32),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildLoginTypeToggle(),
                            const SizedBox(height: 24),
                            if (_isEmailLogin) ...[
                              _buildTextField('Email', Iconsax.sms,
                                  controller: _emailController, isEmail: true),
                              const SizedBox(height: 16),
                              _buildTextField('Password', Iconsax.lock_1,
                                  controller: _passwordController,
                                  isPassword: true),
                            ] else if (_codeSent) ...[
                              _buildTextField('OTP', Iconsax.password_check,
                                  controller: _otpController),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => setState(() {
                                    _codeSent = false;
                                    _otpController.clear();
                                    _verificationId = null;
                                  }),
                                  child: const Text('Change Number',
                                      style: TextStyle(color: Colors.white70)),
                                ),
                              )
                            ] else ...[
                              _buildPhoneField(),
                            ],
                            const SizedBox(height: 16),
                            if (_isEmailLogin)
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Text('Forgot password?',
                                    style: TextStyle(color: Colors.white70)),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildGlowingButton(),
                      const SizedBox(height: 32),
                      const Text('Or continue with',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                              FontAwesomeIcons.google, _signInWithGoogle),
                          const SizedBox(width: 24),
                          _buildSocialButton(FontAwesomeIcons.apple, () {}),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              _isSignUp
                                  ? "Already have an account? "
                                  : "Don't have an account? ",
                              style: const TextStyle(color: Colors.white70)),
                          GestureDetector(
                            onTap: () => setState(() => _isSignUp = !_isSignUp),
                            child: Text(_isSignUp ? 'Sign In' : 'Sign Up',
                                style: TextStyle(
                                    color: Colors.blue.shade300,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientLight(
      Color color, double size, double blurRadius, double spreadRadius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(76),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(128),
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
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(51)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLoginTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(51),
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
            color: isSelected
                ? Colors.blueAccent.withAlpha(179)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.blueAccent.withAlpha(128),
                        blurRadius: 15,
                        spreadRadius: 1)
                  ]
                : [],
          ),
          child: Center(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon,
      {bool isPassword = false,
      bool isEmail = false,
      required TextEditingController controller}) {
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
        fillColor: Colors.white.withAlpha(26),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withAlpha(51))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blueAccent.withAlpha(204))),
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
        fillColor: Colors.white.withAlpha(26),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withAlpha(51))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blueAccent.withAlpha(204))),
      ),
      initialCountryCode: 'IN',
      onChanged: (phone) {
        _fullPhoneNumber = phone.completeNumber;
      },
    );
  }

  Widget _buildGlowingButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleAuthAction,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.blueAccent.withAlpha(204),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withAlpha(179),
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
                  _isEmailLogin
                      ? (_isSignUp ? 'Sign Up' : 'Continue')
                      : (_codeSent ? 'Verify OTP' : 'Send OTP'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(51)),
            ),
            child: FaIcon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
