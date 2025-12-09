import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/generated/app_localizations.dart';

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
  int? _resendToken;
  bool _isSignUp = false;

  // Timer for Resend OTP
  Timer? _timer;
  int _start = 30;
  bool _canResendOtp = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    // Always reset to 30 seconds
    _start = 30;
    _canResendOtp = false;
    _timer?.cancel();
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _canResendOtp = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  // ... existing code ...

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
    final l10n = AppLocalizations.of(context)!;

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null && mounted) {
        final user = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email,
          createdAt: DateTime.now(), // New user always has createdAt
          lastLoginAt: null, // FirestoreService will set this
        );
        await _firestoreService.createOrUpdateUser(user);
        _navigateToHome(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = e.code == 'weak-password'
          ? l10n.weakPassword
          : e.code == 'email-already-in-use'
              ? l10n.emailAlreadyInUse
              : l10n.errorOccurred;
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
    final l10n = AppLocalizations.of(context)!;

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null && mounted) {
        final user = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email,
          lastLoginAt: null, // FirestoreService will set this
        );
        await _firestoreService.createOrUpdateUser(user);
        _navigateToHome(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = e.code == 'user-not-found'
          ? l10n.userNotFound
          : e.code == 'wrong-password'
              ? l10n.wrongPassword
              : l10n.errorOccurred;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    final TextEditingController resetEmailController = TextEditingController();
    // Pre-fill if the user has typed something in the main email field
    if (_isEmailLogin && _emailController.text.isNotEmpty) {
      resetEmailController.text = _emailController.text;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A0B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address to receive a password reset link.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withAlpha(26),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter an email address')),
                );
                return;
              }
              Navigator.pop(dialogContext); // Close dialog

              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Password reset link sent to $email'),
                        backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPhoneNumber({bool isResend = false}) async {
    final l10n = AppLocalizations.of(context)!;
    if (_fullPhoneNumber.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterValidPhone)),
      );
      return;
    }
    setState(() => _isLoading = true);
    debugPrint('Starting phone verification for: $_fullPhoneNumber');

    // Only start timer if it's a new request or resend
    _startTimer();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _fullPhoneNumber,
      forceResendingToken: isResend ? _resendToken : null,
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint(
            'Verification completed automatically: ${credential.smsCode}');
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        if (mounted) {
          final isNewUser =
              userCredential.additionalUserInfo?.isNewUser ?? false;
          debugPrint(
              'Phone Auth - User is ${isNewUser ? "NEW" : "EXISTING"}: ${userCredential.user!.uid}');

          final user = UserModel(
            uid: userCredential.user!.uid,
            phoneNumber: userCredential.user!.phoneNumber,
            // Only set createdAt for NEW users
            createdAt: isNewUser ? DateTime.now() : null,
            // lastLoginAt will be set by FirestoreService
            lastLoginAt: null,
          );
          await _firestoreService.createOrUpdateUser(user);
          setState(() => _isLoading = false);
          _navigateToHome(userCredential.user!);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('Verification Failed: code=${e.code}, message=${e.message}');
        if (mounted) {
          setState(() => _isLoading = false);

          String errorMessage = 'Verification Failed: ${e.message}';
          if (e.code == 'too-many-requests') {
            errorMessage =
                'Too many attempts. Please wait a while or use a test number.';
          } else if (e.code == 'invalid-phone-number') {
            errorMessage = 'The phone number entered is invalid.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        debugPrint('Code Sent. Verification ID: $verificationId');
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isLoading = false;
            _codeSent = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully')),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('Auto retrieval timeout. Verification ID: $verificationId');
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
          });
        }
      },
    );
  }

  Future<void> _signInWithOTP() async {
    final l10n = AppLocalizations.of(context)!;
    debugPrint(
        'Signing in with OTP. Verification ID: $_verificationId, User Input: ${_otpController.text}');

    if (_verificationId == null || _otpController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterOtp)),
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
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        debugPrint(
            'Phone OTP Sign in successful. User is ${isNewUser ? "NEW" : "EXISTING"}: ${userCredential.user!.uid}');

        final user = UserModel(
          uid: userCredential.user!.uid,
          phoneNumber: userCredential.user!.phoneNumber,
          // Only set createdAt for NEW users
          createdAt: isNewUser ? DateTime.now() : null,
          // lastLoginAt will be set by FirestoreService
          lastLoginAt: null,
        );
        await _firestoreService.createOrUpdateUser(user);
        _navigateToHome(userCredential.user!);
      }
    } catch (e) {
      debugPrint('Sign in failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final l10n = AppLocalizations.of(context)!;
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
          final isNewUser =
              userCredential.additionalUserInfo?.isNewUser ?? false;
          debugPrint(
              'Google Sign in - User is ${isNewUser ? "NEW" : "EXISTING"}: ${userCredential.user!.uid}');

          final user = UserModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email,
            displayName: userCredential.user!.displayName,
            photoUrl: userCredential.user!.photoURL,
            createdAt: isNewUser ? DateTime.now() : null,
            lastLoginAt: null, // FirestoreService will set this
          );
          await _firestoreService.createOrUpdateUser(user);
          _navigateToHome(userCredential.user!);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      debugPrint("Google Sign-In Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.googleSignInFailed)));
    }
  }

  void _navigateToHome(User user) async {
    if (widget.agreedToTerms) {
      await _firestoreService.saveTermsAcceptance(user.uid);
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/permissions');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Stack(
        children: [
          // 1. Background Gradient (Fills entire screen)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0B2E), Color(0xFF42218E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. Ambient Lights (Behind content)
          Positioned(
              top: -100,
              left: -100,
              child: _buildAmbientLight(const Color(0xFF6B3E9A), 250, 100, 50)),
          Positioned(
              bottom: -150,
              right: -150,
              child: _buildAmbientLight(Colors.blue, 350, 150, 70)),

          // 3. Main Content (Transparent Scaffold)
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset:
                true, // Allow content to adjust for keyboard
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.user, color: Colors.white, size: 50),
                      const SizedBox(height: 16),
                      Text(_isSignUp ? l10n.createAccount : l10n.welcomeBack,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                          _isSignUp
                              ? l10n.createNewAccount
                              : l10n.signInToAccount,
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
                              _buildTextField(l10n.email, Iconsax.sms,
                                  controller: _emailController, isEmail: true),
                              const SizedBox(height: 16),
                              _buildTextField(l10n.password, Iconsax.lock_1,
                                  controller: _passwordController,
                                  isPassword: true),
                            ] else if (_codeSent) ...[
                              Pinput(
                                length: 6,
                                controller: _otpController,
                                onCompleted: (pin) => _signInWithOTP(),
                                // Android will auto-detect OTP from SMS
                                autofillHints: const [
                                  AutofillHints.oneTimeCode
                                ],
                                defaultPinTheme: PinTheme(
                                  width: 45,
                                  height: 55,
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(26),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white.withAlpha(51)),
                                  ),
                                ),
                                focusedPinTheme: PinTheme(
                                  width: 45,
                                  height: 55,
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(40),
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.blueAccent),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueAccent
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: _canResendOtp
                                        ? () {
                                            _verifyPhoneNumber(isResend: true);
                                          }
                                        : null,
                                    child: Text(
                                      _canResendOtp
                                          ? 'Resend OTP'
                                          : 'Resend in ${_start}s',
                                      style: TextStyle(
                                        color: _canResendOtp
                                            ? Colors.blueAccent
                                            : Colors.white54,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _codeSent = false;
                                      _otpController.clear();
                                      _verificationId = null;
                                      _timer?.cancel();
                                    }),
                                    child: Text(l10n.changeNumber,
                                        style: const TextStyle(
                                            color: Colors.white70)),
                                  ),
                                ],
                              )
                            ] else ...[
                              _buildPhoneField(),
                            ],
                            const SizedBox(height: 16),
                            if (_isEmailLogin)
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: _sendPasswordResetEmail,
                                  child: Text(
                                    l10n.forgotPassword,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildGlowingButton(),
                      const SizedBox(height: 32),
                      Text(l10n.orContinueWith,
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                              FontAwesomeIcons.google, _signInWithGoogle),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              _isSignUp
                                  ? l10n.alreadyHaveAccount
                                  : l10n.dontHaveAccount,
                              style: const TextStyle(color: Colors.white70)),
                          GestureDetector(
                            onTap: () => setState(() => _isSignUp = !_isSignUp),
                            child: Text(_isSignUp ? l10n.signIn : l10n.signUp,
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
          ),
        ],
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(51),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildToggleItem(l10n.email, _isEmailLogin, () {
            if (!_isEmailLogin) {
              setState(() {
                _isEmailLogin = true;
                _codeSent = false;
                _otpController.clear();
                _verificationId = null;
                _timer?.cancel();
              });
            }
          }),
          _buildToggleItem(l10n.phone, !_isEmailLogin, () {
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
    final l10n = AppLocalizations.of(context)!;
    return IntlPhoneField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: l10n.phoneNumber,
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
    final l10n = AppLocalizations.of(context)!;
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
                      ? (_isSignUp ? l10n.signUp : l10n.continue_)
                      : (_codeSent ? l10n.verifyOtp : l10n.sendOtp),
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
