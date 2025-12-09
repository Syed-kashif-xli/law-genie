import 'dart:typed_data';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/features/court_order_reader/summary_display_page.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/home/providers/usage_provider.dart';
import 'package:myapp/features/home/widgets/inline_banner_ad_widget.dart';

class CourtOrderReaderPage extends StatefulWidget {
  const CourtOrderReaderPage({super.key});

  @override
  State<CourtOrderReaderPage> createState() => _CourtOrderReaderPageState();
}

class _CourtOrderReaderPageState extends State<CourtOrderReaderPage> {
  List<Uint8List> _fileBytesList = [];
  bool _isLoading = false;
  List<String> _fileNames = [];

  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(
          'You are an expert at analyzing Indian Court Orders and Judgments. '
          'Summarize the provided court order clearly and concisely. '
          'Identify the key elements: Case Name, Court, Judge(s), Key Issues, Arguments, Final Verdict/Order, and Important Statutes cited. '
          'Explain complex legal jargon in simple English. '
          'Format the summary with clear headings and bullet points.'),
    );
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _fileBytesList = result.files
            .where((file) => file.bytes != null)
            .map((file) => file.bytes!)
            .toList();
        _fileNames = result.files
            .where((file) => file.bytes != null)
            .map((file) => file.name)
            .toList();
      });
    }
  }

  Future<void> _summarize() async {
    if (_fileBytesList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please pick one or more PDF files first.')),
      );
      return;
    }

    final usageProvider = Provider.of<UsageProvider>(context, listen: false);
    if (usageProvider.courtOrdersUsage >= usageProvider.courtOrdersLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Free plan limit reached. Upgrade to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final content = [
        Content.multi([
          TextPart(
              'Summarize the following court order documents. Provide a concise summary of the key points, rulings, and directives for each document.'),
          ..._fileBytesList
              .map((bytes) => InlineDataPart('application/pdf', bytes)),
        ])
      ];
      final response = await _model.generateContent(content);
      final summary = response.text;

      if (summary != null) {
        usageProvider.incrementCourtOrders();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryDisplayPage(summary: summary),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error summarizing documents: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A), // Dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A032A), // Match body background
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Court Order Summarizer',
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFileUploadCard(),
              const SizedBox(height: 24),
              if (_fileNames.isNotEmpty) _buildSelectedFilesList(),
              const SizedBox(height: 24),
              _buildGenerateButton(),
              const SizedBox(height: 32),
              const InlineBannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadCard() {
    return GestureDetector(
      onTap: _pickFiles,
      child: DottedBorder(
        color: const Color(0xFF02F1C3),
        strokeWidth: 2,
        dashPattern: const [8, 4],
        radius: const Radius.circular(12),
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF19173A), // Dark card background
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.document_upload,
                size: 48,
                color: const Color(0xFF02F1C3),
              ),
              const SizedBox(height: 16),
              Text(
                'Tap to upload PDFs',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFilesList() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF19173A), // Dark card
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 5),
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
                'Selected Files',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF02F1C3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_fileNames.length} files',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF02F1C3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fileNames.map((fileName) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.document_text,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        fileName,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          final index = _fileNames.indexOf(fileName);
                          if (index != -1) {
                            _fileNames.removeAt(index);
                            _fileBytesList.removeAt(index);
                          }
                        });
                      },
                      child: const Icon(Icons.close,
                          color: Colors.white38, size: 16),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: _fileBytesList.isEmpty
            ? const LinearGradient(
                colors: [Color(0xFFB0B0B0), Color(0xFF9E9E9E)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF5C9DFF), Color(0xFF4A8CFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        boxShadow: _fileBytesList.isEmpty
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF5C9DFF).withAlpha(102),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
      ),
      child: ElevatedButton.icon(
        onPressed: _fileBytesList.isEmpty || _isLoading ? null : _summarize,
        icon: _isLoading
            ? const SizedBox.shrink()
            : const Icon(Iconsax.document_text_1, color: Colors.white),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(
                  'Generate Summary',
                  style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class DottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final Radius radius;

  const DottedBorder({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.dashPattern = const <double>[3, 1],
    this.radius = const Radius.circular(0),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedPainter(
        color: color,
        strokeWidth: strokeWidth,
        dashPattern: dashPattern,
        radius: radius,
      ),
      child: child,
    );
  }
}

class _DottedPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final Radius radius;

  _DottedPainter({
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.dashPattern = const <double>[3, 1],
    this.radius = const Radius.circular(0),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), radius));

    final Path dashPath = Path();
    double distance = 0.0;
    for (final PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashPattern[0]),
          Offset.zero,
        );
        distance += dashPattern[0];
        distance += dashPattern[1];
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
