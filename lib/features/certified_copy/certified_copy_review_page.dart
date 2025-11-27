import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'certified_copy_token_page.dart';

class CertifiedCopyReviewPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          isDigitalCopy ? 'Review Digital Copy' : 'Review Registry Copy',
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
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
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
          _buildDetailRow('District', district),
          _buildDetailRow('Date Range', '$fromDate to $toDate'),
          if (deedType != null) _buildDetailRow('Deed Type', deedType!),
          const Divider(color: Colors.white10, height: 32),
          if (searchByParty) ...[
            Text(
              'Party Details',
              style: GoogleFonts.poppins(
                color: const Color(0xFF02F1C3),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Party Type', partyType ?? '-'),
            _buildDetailRow('Name (Eng)', partyNameEng ?? '-'),
            _buildDetailRow('Name (Hindi)', partyNameHindi ?? '-'),
            if (mobileNumber != null && mobileNumber!.isNotEmpty)
              _buildDetailRow('Mobile', mobileNumber!),
          ],
          if (searchByParty && searchByProperty)
            const Divider(color: Colors.white10, height: 32),
          if (searchByProperty) ...[
            Text(
              'Property Details',
              style: GoogleFonts.poppins(
                color: const Color(0xFF02F1C3),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Property Type', propertyType ?? '-'),
            _buildDetailRow('Address (Eng)', propertyAddressEng ?? '-'),
            _buildDetailRow('Address (Hindi)', propertyAddressHindi ?? '-'),
            if (propertyId != null && propertyId!.isNotEmpty)
              _buildDetailRow('Property ID', propertyId!),
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
            const Color(0xFF02F1C3).withOpacity(0.15),
            const Color(0xFF02F1C3).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF02F1C3).withOpacity(0.3),
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
            color: const Color(0xFF02F1C3).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CertifiedCopyTokenPage(),
            ),
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
              'Agree & Continue',
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
