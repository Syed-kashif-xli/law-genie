import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/payment_service.dart';
import '../../services/firestore_service.dart';
import '../../models/order_model.dart';
import 'certified_copy_token_page.dart';
import 'dart:math';

class CertifiedCopyReviewPage extends StatefulWidget {
  final String district;
  final String dateOption;
  final String fromDate;
  final String toDate;
  final String? deedType;
  final bool searchByParty;
  final String? partyType;
  final String? partyNameEng;
  final String? partyNameHindi;
  final String? mobileNumber;
  final bool searchByProperty;
  final String? propertyType;
  final String? propertyAddressEng;
  final String? propertyAddressHindi;
  final String? propertyId;
  final bool isDigitalCopy;

  const CertifiedCopyReviewPage({
    super.key,
    required this.district,
    required this.dateOption,
    required this.fromDate,
    required this.toDate,
    this.deedType,
    required this.searchByParty,
    this.partyType,
    this.partyNameEng,
    this.partyNameHindi,
    this.mobileNumber,
    required this.searchByProperty,
    this.propertyType,
    this.propertyAddressEng,
    this.propertyAddressHindi,
    this.propertyId,
    this.isDigitalCopy = false,
  });

  @override
  State<CertifiedCopyReviewPage> createState() =>
      _CertifiedCopyReviewPageState();
}

class _CertifiedCopyReviewPageState extends State<CertifiedCopyReviewPage> {
  late PaymentService _paymentService;
  final FirestoreService _firestoreService = FirestoreService();

  String _generateToken() {
    var rng = Random();
    int randomNum = rng.nextInt(9000) + 1000;
    return 'MP-REG-2024-$randomNum';
  }

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
    final token = _generateToken();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final order = OrderModel(
        id: token, // Using token as ID for simplicity
        token: token,
        userId: user.uid,
        status: 'received',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        details: {
          'district': widget.district,
          'dateOption': widget.dateOption,
          'fromDate': widget.fromDate,
          'toDate': widget.toDate,
          'deedType': widget.deedType,
          'partyName': widget.partyNameEng,
          'propertyAddress': widget.propertyAddressEng,
          'paymentId': response.paymentId,
          'amount': 2.0,
        },
      );

      await _firestoreService.createRegistryOrder(order);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Successful: ${response.paymentId}"),
        backgroundColor: Colors.green,
      ),
    );
    // Navigate to Token Page on success
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CertifiedCopyTokenPage(token: token),
      ),
    );
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          widget.isDigitalCopy ? 'Review Digital Copy' : 'Review Registry Copy',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A032A),
              Color(0xFF1A0B4E),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 24),
                _buildPaymentPolicyCard(),
                const SizedBox(height: 40),
                _buildActionButtons(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.document_text,
                  color: Color(0xFF02F1C3), size: 24),
              const SizedBox(width: 12),
              Text(
                'Application Details',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow('State', 'Madhya Pradesh'),
          _buildDetailRow('District', widget.district),
          _buildDetailRow(
              'Date Range', '${widget.fromDate} to ${widget.toDate}'),
          if (widget.deedType != null)
            _buildDetailRow('Deed Type', widget.deedType!),
          const Divider(color: Colors.white10, height: 32),
          if (widget.searchByParty) ...[
            Text(
              'Party Details',
              style: GoogleFonts.poppins(
                color: const Color(0xFF02F1C3),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Party Type', widget.partyType ?? '-'),
            _buildDetailRow('Name (Eng)', widget.partyNameEng ?? '-'),
            _buildDetailRow('Name (Hindi)', widget.partyNameHindi ?? '-'),
            if (widget.mobileNumber != null && widget.mobileNumber!.isNotEmpty)
              _buildDetailRow('Mobile', widget.mobileNumber!),
          ],
          if (widget.searchByParty && widget.searchByProperty)
            const Divider(color: Colors.white10, height: 32),
          if (widget.searchByProperty) ...[
            Text(
              'Property Details',
              style: GoogleFonts.poppins(
                color: const Color(0xFF02F1C3),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Property Type', widget.propertyType ?? '-'),
            _buildDetailRow('Address (Eng)', widget.propertyAddressEng ?? '-'),
            _buildDetailRow(
                'Address (Hindi)', widget.propertyAddressHindi ?? '-'),
            if (widget.propertyId != null && widget.propertyId!.isNotEmpty)
              _buildDetailRow('Property ID', widget.propertyId!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPolicyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF02F1C3).withValues(alpha: 0.15),
            const Color(0xFF02F1C3).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF02F1C3).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF02F1C3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.wallet_money,
                    color: Colors.black, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                'Payment Policy',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPolicyItem(
            'Total Service Cost\n(कुल सेवा शुल्क)',
            '₹2000',
            isTotal: true,
          ),
          const Divider(color: Colors.white10, height: 32),
          _buildPolicyItem(
            'Token Payment (Pay Now)\n(टोकन भुगतान - अभी भुगतान करें)',
            '₹2',
            subtitle:
                'Non-refundable processing fee\n(गैर-वापसी योग्य प्रसंस्करण शुल्क)',
            highlight: true,
          ),
          const SizedBox(height: 24),
          _buildPolicyBullet(
            'If the registry is found, you will be required to pay the remaining balance.',
            'यदि रजिस्ट्री मिल जाती है, तो आपको शेष राशि का भुगतान करना होगा।',
          ),
          const SizedBox(height: 12),
          _buildPolicyBullet(
            'If the registry is NOT found, the ₹2 token amount will NOT be refunded.',
            'यदि रजिस्ट्री नहीं मिलती है, तो ₹2 की टोकन राशि वापस नहीं की जाएगी।',
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(String label, String amount,
      {bool isTotal = false, bool highlight = false, String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: highlight ? const Color(0xFF02F1C3) : Colors.white,
                  fontSize: isTotal ? 16 : 15,
                  fontWeight:
                      isTotal || highlight ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            color: highlight ? const Color(0xFF02F1C3) : Colors.white,
            fontSize: isTotal ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyBullet(String textEng, String textHindi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Colors.white38),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textEng,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  textHindi,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF02F1C3).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          final user = FirebaseAuth.instance.currentUser;
          final email = user?.email ?? 'user@example.com';
          final phone = user?.phoneNumber ?? '9876543210';

          _paymentService.openCheckout(
            amount: 2.0, // ₹2 Token Amount
            description: 'Registry Search Token',
            contact: phone,
            email: email,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF02F1C3),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Agree & Pay ₹2',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }
}
