import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../services/ecourts_service.dart';
import '../case_finder/models/legal_case.dart';

class CaseStatusPage extends StatefulWidget {
  const CaseStatusPage({super.key});

  @override
  State<CaseStatusPage> createState() => _CaseStatusPageState();
}

class _CaseStatusPageState extends State<CaseStatusPage> {
  final EcourtsService _ecourtsService = EcourtsService();
  final TextEditingController _cnrController = TextEditingController();
  bool _isLoading = false;
  LegalCase? _result;

  @override
  void dispose() {
    _cnrController.dispose();
    super.dispose();
  }

  Future<void> _searchByCnr() async {
    final cnr = _cnrController.text.trim();
    if (cnr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a CNR number')),
      );
      return;
    }

    if (cnr.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CNR number must be 16 characters')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    final result = await _ecourtsService.getCaseStatusByCnr(cnr);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _result = result;
    });

    if (result == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Case not found or error fetching status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Case Status',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A032A), Color(0xFF151038)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search by CNR Number',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 16-digit CNR number to get real-time case status.',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1832),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF02F1C3).withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: _cnrController,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter CNR Number (e.g. MHAU010045672023)',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white30,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.search_normal,
                      color: Color(0xFF02F1C3),
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner,
                          color: Color(0xFF02F1C3)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('QR Scanner coming soon!')),
                        );
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => _searchByCnr(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _searchByCnr,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02F1C3),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          'Get Case Status',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 32),
                _buildResultCard(_result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(LegalCase legalCase) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1832),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF02F1C3).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF02F1C3).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  legalCase.court,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF02F1C3),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                legalCase.formattedDate,
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            legalCase.title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            legalCase.caseNumber,
            style: GoogleFonts.poppins(
              color: const Color(0xFF02F1C3),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (legalCase.cnrNumber != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'CNR: ${legalCase.cnrNumber}',
                style: GoogleFonts.robotoMono(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          if (legalCase.status != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF02F1C3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF02F1C3).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  _buildStatusRow('Status', legalCase.status!),
                  if (legalCase.nextHearingDate != null) ...[
                    const Divider(color: Colors.white10),
                    _buildStatusRow('Next Hearing', legalCase.nextHearingDate!),
                  ],
                ],
              ),
            ),
          ],
          if (legalCase.petitioner != null) ...[
            const SizedBox(height: 20),
            _buildPartyInfo('Petitioner', legalCase.petitioner!),
          ],
          if (legalCase.respondent != null) ...[
            const SizedBox(height: 12),
            _buildPartyInfo('Respondent', legalCase.respondent!),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPartyInfo(String label, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF02F1C3),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
