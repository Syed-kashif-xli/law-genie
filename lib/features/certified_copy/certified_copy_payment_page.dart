import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/payment_service.dart';
import '../../services/firestore_service.dart';
import '../../models/order_model.dart';

class CertifiedCopyPaymentPage extends StatefulWidget {
  final OrderModel order;

  const CertifiedCopyPaymentPage({super.key, required this.order});

  @override
  State<CertifiedCopyPaymentPage> createState() =>
      _CertifiedCopyPaymentPageState();
}

class _CertifiedCopyPaymentPageState extends State<CertifiedCopyPaymentPage> {
  late PaymentService _paymentService;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = true);

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'unknown@example.com';
    // Try to get phone from order details first, then auth, then default
    final phone =
        widget.order.details['mobileNumber'] ?? user?.phoneNumber ?? 'unknown';

    // Update order with final payment details
    await _firestoreService.updateOrderFinalPayment(
      orderId: widget.order.id,
      amount: 2000.0,
      paymentId: response.paymentId ?? 'unknown',
      email: email,
      phone: phone,
    );

    // Also update preview status to correct if not already
    if (widget.order.previewStatus != 'correct') {
      await _firestoreService.updateOrderPreviewStatus(
          widget.order.id, 'correct');
    }

    if (!mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Successful: ${response.paymentId}"),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to home or show success screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet: ${response.walletName}"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Final Payment',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A032A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A032A), Color(0xFF1A0B4E)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: const Color(0xFF02F1C3).withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Iconsax.wallet_money,
                        color: Color(0xFF02F1C3), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Total Amount Due',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹2000',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Complete your payment to receive the certified copy.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF02F1C3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF02F1C3).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.clock,
                        color: Color(0xFF02F1C3), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Document will be provided within 5 hours after payment.',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing
                      ? null
                      : () {
                          final user = FirebaseAuth.instance.currentUser;
                          final email = user?.email ?? 'user@example.com';
                          // Try to get phone from order details first, then auth, then default
                          final phone = widget.order.details['mobileNumber'] ??
                              user?.phoneNumber ??
                              '9876543210';

                          _paymentService.openCheckout(
                            amount: 2000.0,
                            description: 'Certified Copy Final Payment',
                            contact: phone,
                            email: email,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02F1C3),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          'Pay ₹2000',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
