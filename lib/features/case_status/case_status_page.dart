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
  int _selectedTab = 0;

  @override
  void dispose() {
    _cnrController.dispose();
    super.dispose();
  }

  Future<void> _searchByCnr() async {
    final cnr = _cnrController.text.trim().toUpperCase();
    if (cnr.isEmpty) {
      _showSnackBar('Please enter a CNR number', isError: true);
      return;
    }

    if (cnr.length != 16) {
      _showSnackBar('CNR number must be 16 characters', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result = await _ecourtsService.getCaseStatusByCnr(cnr);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _result = result;
      });

      if (result == null) {
        _showErrorOverlay('Authorization Failed or Case Not Found');
      } else {
        _showSnackBar('Case Details Fetched Successfully!');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorOverlay('Server Error: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF00E5FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorOverlay(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            message,
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xFFFF5252),
        elevation: 10,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F002C),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F002C), Color(0xFF2E0054), Color(0xFF0F002C)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              const SizedBox(height: 10),
              _buildTabs(),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      if (_result == null) ...[
                        _buildMainContainer(),
                        const SizedBox(height: 24),
                        _buildInfoBox(),
                      ],
                      if (_isLoading) ...[
                        const SizedBox(height: 40),
                        const CircularProgressIndicator(
                            color: Color(0xFF00E5FF)),
                        const SizedBox(height: 12),
                        Text('Fetching detailed case history...',
                            style: GoogleFonts.poppins(
                                color: Colors.white38, fontSize: 12)),
                      ],
                      if (_result != null) ...[
                        const SizedBox(height: 10),
                        _buildDetailSection('CASE DETAILS', [
                          _buildDetailRow('Case Type', _result?.caseType),
                          _buildDetailRow(
                              'Registration No', _result?.registrationNumber),
                          _buildDetailRow(
                              'Registration Date', _result?.registrationDate),
                          _buildDetailRow('CNR Number', _result?.cnrNumber),
                        ]),
                        _buildDetailSection('CASE STATUS', [
                          _buildDetailRow(
                              'First Hearing Date', _result?.firstHearingDate),
                          _buildDetailRow(
                              'Next Hearing Date', _result?.nextHearingDate),
                          _buildDetailRow(
                              'Case Stage',
                              _result?.caseStage != null
                                  ? _ecourtsService
                                      .stripHtml(_result!.caseStage!)
                                  : 'N/A'),
                          _buildDetailRow('Court', _result?.court),
                        ]),
                        if (_result?.acts != null && _result!.acts!.isNotEmpty)
                          _buildDetailSection('ACTS', [
                            Text(
                              _result!.acts!,
                              style: GoogleFonts.outfit(
                                  color: Colors.white, fontSize: 15),
                            ),
                          ]),
                        _buildDetailSection('PETITIONER & ADVOCATE', [
                          _buildDetailRow('Petitioner', _result?.petitioner,
                              isBold: true),
                          if (_result?.extraPetitioners != null)
                            ..._result!.extraPetitioners!.map((p) =>
                                _buildDetailRow('Petitioner', p, isBold: true)),
                          if (_result?.petitionerAdvocate != null &&
                              _result!.petitionerAdvocate!.isNotEmpty)
                            _buildDetailRow(
                                'Advocate', _result?.petitionerAdvocate),
                        ]),
                        _buildDetailSection('RESPONDENT & ADVOCATE', [
                          _buildDetailRow('Respondent', _result?.respondent,
                              isBold: true),
                          if (_result?.extraRespondents != null)
                            ..._result!.extraRespondents!.map((r) =>
                                _buildDetailRow('Respondent', r, isBold: true)),
                          if (_result?.respondentAdvocate != null &&
                              _result!.respondentAdvocate!.isNotEmpty)
                            _buildDetailRow(
                                'Advocate', _result?.respondentAdvocate),
                        ]),
                        if (_result?.hearingHistory != null &&
                            _result!.hearingHistory!.isNotEmpty)
                          _buildHistorySection(),
                        if (_result?.interimOrders != null &&
                            _result!.interimOrders!.isNotEmpty)
                          _buildOrdersSection(
                              'INTERIM ORDERS', _result!.interimOrders!),
                        if (_result?.finalOrders != null &&
                            _result!.finalOrders!.isNotEmpty)
                          _buildOrdersSection(
                              'FINAL ORDERS', _result!.finalOrders!),
                        if (_result?.transfers != null &&
                            _result!.transfers!.isNotEmpty)
                          _buildTransfersSection(),
                        const SizedBox(height: 20),
                        _buildNewSearchButton(),
                      ],
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'e-COURTS',
            style: GoogleFonts.audiowide(
              color: Colors.white,
              fontSize: 28,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'CNR QUICK'),
          _buildTabItem(1, 'FILING NO'),
          _buildTabItem(2, 'DETAILS'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
                  )
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withAlpha(100),
                      blurRadius: 10,
                    )
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: isActive ? Colors.black : Colors.white60,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CNR NUMBER',
            style: GoogleFonts.audiowide(
              color: const Color(0xFF00E5FF),
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Identify your case instantly using its 16-digit CNR index.',
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 30),
          _buildInputField(),
          const SizedBox(height: 30),
          _buildLocateButton(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.2), blurRadius: 10),
        ],
      ),
      child: TextField(
        controller: _cnrController,
        cursorColor: Colors.black,
        style: GoogleFonts.exo2(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Iconsax.barcode, color: Color(0xFF00E5FF), size: 28),
          ),
          hintText: 'MP04010244152024',
          hintStyle: GoogleFonts.exo2(color: Colors.grey, fontSize: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
        onSubmitted: (_) => _searchByCnr(),
      ),
    );
  }

  Widget _buildLocateButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _searchByCnr,
      child: Container(
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withAlpha(120),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.radar, color: Colors.black, size: 22),
              const SizedBox(width: 12),
              Text(
                'LOCATE CASE',
                style: GoogleFonts.audiowide(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E144D).withAlpha(150),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF00E5FF).withAlpha(40)),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.info_circle, color: Color(0xFF00E5FF), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Case Number and Registration details are not required for CNR search.',
              style: GoogleFonts.poppins(
                  color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF00E5FF).withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.audiowide(
              color: const Color(0xFF00E5FF),
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, {bool isBold = false}) {
    // If value is null, empty, or 'Unknown', show 'N/A' or handle gracefully
    final displayValue =
        (value == null || value.trim().isEmpty) ? 'N/A' : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              displayValue,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewSearchButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          setState(() {
            _result = null;
            _cnrController.clear();
          });
        },
        icon: const Icon(Icons.refresh, color: Color(0xFF00E5FF)),
        label: Text(
          'Search Another Case',
          style: GoogleFonts.poppins(color: const Color(0xFF00E5FF)),
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return _buildDetailSection('CASE HISTORY', [
      ..._result!.hearingHistory!.map((h) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(h.hearingDate,
                        style: GoogleFonts.outfit(
                            color: const Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withAlpha(50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Business: ${h.businessOnDate}',
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(h.judge,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Purpose: ${h.purpose}',
                    style: GoogleFonts.poppins(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          )),
    ]);
  }

  Widget _buildOrdersSection(String title, List<OrderRecord> orders) {
    return _buildDetailSection(title, [
      ...orders.map((o) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.orderDate,
                          style: GoogleFonts.outfit(
                              color: const Color(0xFF00E5FF),
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(o.orderDetails,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
                if (o.pdfUrl != null)
                  IconButton(
                    icon: const Icon(Iconsax.document_download,
                        color: Color(0xFF00E5FF)),
                    onPressed: () {
                      // Handled by user request for professional PDF experience later
                      _showSnackBar('Opening Order PDF...');
                    },
                  ),
              ],
            ),
          )),
    ]);
  }

  Widget _buildTransfersSection() {
    return _buildDetailSection('CASE TRANSFER DETAILS', [
      ..._result!.transfers!.map((t) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transfer Date: ${t.transferDate}',
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildTransferRow('From', t.fromCourt),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(Icons.arrow_downward,
                      color: Colors.white24, size: 16),
                ),
                _buildTransferRow('To', t.toCourt),
              ],
            ),
          )),
    ]);
  }

  Widget _buildTransferRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
        Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12))),
      ],
    );
  }
}
