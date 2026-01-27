import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myapp/services/pdf_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../services/ecourts_service.dart';
import '../case_finder/models/legal_case.dart';
import '../shared/pdf_viewer_page.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

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
      body: Stack(
        children: [
          // Dynamic Background Elements
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F002C),
                  Color(0xFF1A0033),
                  Color(0xFF0F002C)
                ],
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withAlpha(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7000FF).withAlpha(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        if (_result == null) ...[
                          _buildMainContainer(),
                          const SizedBox(height: 30),
                          _buildKeyPoints(),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('Basic case information',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white54, fontSize: 12)),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      PdfService.generateCaseStatusPdf(
                                          _result!),
                                  icon: const Icon(Iconsax.document_download,
                                      color: Color(0xFF00E5FF), size: 18),
                                  label: Text('DOWNLOAD REPORT',
                                      style: GoogleFonts.audiowide(
                                          color: const Color(0xFF00E5FF),
                                          fontSize: 10)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow('Case Type', _result?.caseType),
                            _buildDetailRow(
                                'Filing Number', _result?.filingNumber),
                            _buildDetailRow('Filing Date', _result?.filingDate),
                            _buildDetailRow(
                                'Registration No', _result?.registrationNumber),
                            _buildDetailRow(
                                'Registration Date', _result?.registrationDate),
                            _buildDetailRow('CNR Number', _result?.cnrNumber),
                          ]),
                          _buildDetailSection('CASE STATUS', [
                            _buildDetailRow('First Hearing Date',
                                _result?.firstHearingDate),
                            _buildDetailRow(
                                'Next Hearing Date', _result?.nextHearingDate),
                            _buildDetailRow(
                                'Case Stage',
                                _result?.caseStage != null
                                    ? _ecourtsService
                                        .stripHtml(_result!.caseStage!)
                                    : 'N/A'),
                            _buildDetailRow('Nature of Disposal',
                                _result?.natureOfDisposal),
                            _buildDetailRow(
                                'Court Number', _result?.courtNumber),
                            _buildDetailRow('Judge', _result?.judgeDesignation),
                            _buildDetailRow('Court', _result?.court),
                          ]),
                          if (_result?.acts != null &&
                              _result!.acts!.isNotEmpty)
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
                                  _buildDetailRow('Petitioner', p,
                                      isBold: true)),
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
                                  _buildDetailRow('Respondent', r,
                                      isBold: true)),
                            if (_result?.respondentAdvocate != null &&
                                _result!.respondentAdvocate!.isNotEmpty)
                              _buildDetailRow(
                                  'Advocate', _result?.respondentAdvocate),
                          ]),
                          if (_result?.finalOrders != null &&
                              _result!.finalOrders!.isNotEmpty)
                            _buildOrdersSection(
                                'FINAL ORDERS', _result!.finalOrders!),
                          if (_result?.hearingHistory != null &&
                              _result!.hearingHistory!.isNotEmpty)
                            _buildHistorySection(),
                          if (_result?.interimOrders != null &&
                              _result!.interimOrders!.isNotEmpty)
                            _buildOrdersSection(
                                'INTERIM ORDERS', _result!.interimOrders!),
                          if (_result?.transfers != null &&
                              _result!.transfers!.isNotEmpty)
                            _buildTransfersSection(),
                          if (_result?.processes != null &&
                              _result!.processes!.isNotEmpty)
                            _buildDetailSection('PROCESSES', [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: HtmlWidget(
                                  _result!.processes!,
                                  customStylesBuilder: (element) {
                                    if (element.localName == 'table') {
                                      return {
                                        'border-collapse': 'collapse',
                                        'width': '100%',
                                        'background-color': '#1A1440',
                                        'border': '1px solid #33E5FF',
                                      };
                                    }
                                    if (element.localName == 'th' ||
                                        element.localName == 'b') {
                                      return {
                                        'background-color': '#2A2060',
                                        'color': '#00E5FF',
                                        'padding': '10px',
                                        'font-weight': 'bold',
                                      };
                                    }
                                    if (element.localName == 'td') {
                                      return {
                                        'border': '1px solid #ffffff1A',
                                        'padding': '10px',
                                        'color': '#FFFFFFE6',
                                      };
                                    }
                                    return null;
                                  },
                                  textStyle: GoogleFonts.outfit(fontSize: 13),
                                ),
                              ),
                            ]),
                          if (_result?.subordinateCourtInfo != null &&
                              _result!.subordinateCourtInfo!.isNotEmpty &&
                              _result!.subordinateCourtInfo != 'null')
                            _buildDetailSection(
                                'SUBORDINATE COURT INFORMATION', [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: HtmlWidget(
                                  _result!.subordinateCourtInfo!,
                                  customStylesBuilder: (element) {
                                    if (element.localName == 'table') {
                                      return {
                                        'border-collapse': 'collapse',
                                        'width': '100%',
                                        'background-color': '#1A1440',
                                        'border': '1px solid #33E5FF',
                                      };
                                    }
                                    if (element.localName == 'th' ||
                                        element.localName == 'b') {
                                      return {
                                        'background-color': '#2A2060',
                                        'color': '#00E5FF',
                                        'padding': '10px',
                                        'font-weight': 'bold',
                                      };
                                    }
                                    if (element.localName == 'td') {
                                      return {
                                        'border': '1px solid #ffffff1A',
                                        'padding': '10px',
                                        'color': '#FFFFFFE6',
                                      };
                                    }
                                    return null;
                                  },
                                  textStyle: GoogleFonts.outfit(fontSize: 13),
                                ),
                              ),
                            ]),
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
        ],
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
            'CASE STATUS',
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

  Widget _buildMainContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withAlpha(30), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CNR NUMBER',
                    style: GoogleFonts.audiowide(
                      color: const Color(0xFF00E5FF),
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                  const Icon(Iconsax.radar, color: Color(0xFF00E5FF), size: 24),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Identify your case instantly using its 16-digit CNR index.',
                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 30),
              _buildInputField(),
              const SizedBox(height: 30),
              _buildLocateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF00E5FF).withAlpha(100), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withAlpha(30),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: _cnrController,
        cursorColor: const Color(0xFF00E5FF),
        style: GoogleFonts.exo2(
          color: Colors.white,
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
          hintText: 'Enter CNR Number',
          hintStyle: GoogleFonts.exo2(color: Colors.white30, fontSize: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
        onSubmitted: (_) => _searchByCnr(),
      ),
    );
  }

  Widget _buildKeyPoints() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.flash_1,
                        color: Color(0xFF00E5FF), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'QUICK TIPS',
                    style: GoogleFonts.audiowide(
                      color: const Color(0xFF00E5FF),
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildPointItem(Iconsax.search_status,
                  'Ensure you enter the full 16-digit CNR number.'),
              _buildPointItem(Iconsax.document_text,
                  'CNR reflects the complete history of a case.'),
              _buildPointItem(Iconsax.global,
                  'Search covers all district and state courts across India.'),
              _buildPointItem(Iconsax.info_circle,
                  'Filing/Registration details are not needed.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
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
            colors: [Color(0xFF00E5FF), Color(0xFF0095FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withAlpha(100),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.white.withAlpha(40), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.flash_1, color: Colors.black, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'SEARCH CASE',
                    style: GoogleFonts.audiowide(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      ..._result!.hearingHistory!.map((h) => GestureDetector(
            onTap:
                h.businessParams != null ? () => _showBusinessDetails(h) : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: h.businessParams != null
                    ? Border.all(color: const Color(0xFF00E5FF).withAlpha(50))
                    : null,
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
                      if (h.businessParams != null)
                        const Icon(Icons.touch_app,
                            color: Color(0xFF00E5FF), size: 14),
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
            ),
          )),
    ]);
  }

  void _showBusinessDetails(HearingRecord record) async {
    if (record.businessParams == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151038).withAlpha(230),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: const Color(0xFF00E5FF).withAlpha(80), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withAlpha(30),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withAlpha(20)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BUSINESS DETAILS',
                        style: GoogleFonts.audiowide(
                          color: const Color(0xFF00E5FF),
                          fontSize: 18,
                          letterSpacing: 1.2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: FutureBuilder<String?>(
                      future: _ecourtsService
                          .getBusinessDetails(record.businessParams!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 40),
                                const CircularProgressIndicator(
                                  color: Color(0xFF00E5FF),
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'FETCHING RECORDS...',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          );
                        }

                        if (snapshot.hasError ||
                            snapshot.data == null ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.info_outline,
                                      color: Colors.amber, size: 48),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No business details found for this date.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                        color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return HtmlWidget(
                          snapshot.data!,
                          textStyle: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.6,
                          ),
                          customStylesBuilder: (element) {
                            if (element.localName == 'table') {
                              return {
                                'border-collapse': 'collapse',
                                'width': '100%',
                                'margin': '10px 0',
                                'background-color': '#ffffff08',
                              };
                            }
                            if (element.localName == 'td' ||
                                element.localName == 'th') {
                              return {
                                'border': '1px solid #ffffff1a',
                                'padding': '12px 8px',
                                'color': '#FFFFFF',
                              };
                            }
                            if (element.localName == 'th' ||
                                element.localName == 'b') {
                              return {
                                'color': '#00E5FF',
                                'font-weight': 'bold',
                              };
                            }
                            if (element.localName == 'a') {
                              return {
                                'color': '#33E5FF',
                                'text-decoration': 'underline',
                              };
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ),
                ),
                // Footer / Bottom spacing
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewerPage(
                            url: o.pdfUrl!,
                            title: 'Order: ${o.orderDate}',
                            headers: _ecourtsService.getStandardHeaders(),
                          ),
                        ),
                      );
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
