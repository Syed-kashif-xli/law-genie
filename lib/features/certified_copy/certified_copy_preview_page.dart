import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'certified_copy_payment_page.dart';

class CertifiedCopyPreviewPage extends StatefulWidget {
  final OrderModel order;
  final bool isFinalFile;

  const CertifiedCopyPreviewPage({
    super.key,
    required this.order,
    this.isFinalFile = false,
  });

  @override
  State<CertifiedCopyPreviewPage> createState() =>
      _CertifiedCopyPreviewPageState();
}

class _CertifiedCopyPreviewPageState extends State<CertifiedCopyPreviewPage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  String? _localPdfPath;

  String? get _targetUrl =>
      widget.isFinalFile ? widget.order.finalFileUrl : widget.order.previewUrl;

  @override
  void initState() {
    super.initState();
    if (_targetUrl != null) {
      final processedUrl = _convertGoogleDriveUrl(_targetUrl!);
      try {
        final uri = Uri.parse(processedUrl);
        // Auto-download if it looks like a PDF or is a drive link (assume PDF)
        if (uri.path.toLowerCase().endsWith('.pdf') ||
            _targetUrl!.contains('drive.google.com')) {
          _downloadPdf();
        }
      } catch (e) {
        debugPrint('Error parsing URL in initState: $e');
      }
    }
  }

  Future<void> _downloadPdf() async {
    try {
      final processedUrl = _convertGoogleDriveUrl(_targetUrl!);
      debugPrint('DEBUG: Starting PDF download from $processedUrl');
      final response = await http.get(Uri.parse(processedUrl));
      debugPrint('DEBUG: Download response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('DEBUG: Failed to download PDF');
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final prefix = widget.isFinalFile ? 'final' : 'preview';
      final file = File('${dir.path}/${prefix}_${widget.order.id}.pdf');
      await file.writeAsBytes(response.bodyBytes);
      debugPrint('DEBUG: PDF saved to ${file.path}');

      if (mounted) {
        setState(() {
          _localPdfPath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _shareFile() async {
    if (_localPdfPath == null) {
      setState(() => _isLoading = true);
      await _downloadPdf();
    }

    if (_localPdfPath != null) {
      final file = XFile(_localPdfPath!);
      // ignore: deprecated_member_use
      await Share.shareXFiles([file], text: 'Here is your Certified Copy');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not prepare file for sharing')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleIncorrect() async {
    setState(() => _isLoading = true);
    await _firestoreService.updateOrderPreviewStatus(widget.order.id, 'wrong');
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We will re-check your document.'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _handleCorrect() async {
    // Navigate to Payment Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CertifiedCopyPaymentPage(order: widget.order),
      ),
    );
  }

  String _convertGoogleDriveUrl(String url) {
    if (url.contains('drive.google.com')) {
      final idRegex = RegExp(r'[-\w]{25,}');
      final match = idRegex.firstMatch(url);
      if (match != null) {
        return 'https://drive.google.com/uc?export=download&id=${match.group(0)}';
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    bool isPdf = false;
    String? processedUrl;

    if (_targetUrl != null) {
      processedUrl = _convertGoogleDriveUrl(_targetUrl!);
      try {
        // Check for PDF in the original URL or if it's a drive link (assume PDF for drive if not obvious)
        final uri = Uri.parse(processedUrl);
        isPdf = uri.path.toLowerCase().endsWith('.pdf') ||
            _targetUrl!.contains('drive.google.com');
      } catch (e) {
        debugPrint('Error parsing preview URL: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isFinalFile ? 'Certified Copy' : 'Document Preview',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A032A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: widget.isFinalFile
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _shareFile,
              backgroundColor: const Color(0xFF02F1C3),
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.share, color: Colors.black),
              label: Text(
                _isLoading ? 'Preparing...' : 'Share / Save',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A032A), Color(0xFF1A0B4E)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withValues(alpha: 0.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: processedUrl == null
                      ? const Center(
                          child: Text('No document available',
                              style: TextStyle(color: Colors.white)))
                      : isPdf
                          ? _localPdfPath != null
                              // If downloaded locally, use PDF Viewer
                              ? const PDF().fromPath(_localPdfPath!)
                              : _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.error_outline,
                                              color: Colors.red, size: 48),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Failed to load PDF Preview',
                                            style: GoogleFonts.poppins(
                                                color: Colors.white),
                                          ),
                                          const SizedBox(height: 8),
                                          // Fallback to Google Docs Viewer if direct download fails
                                          ElevatedButton(
                                            onPressed: () {
                                              // We'll just trigger a rebuild with a flag?
                                              // Or better, launch webview here.
                                              // Actually, let's just make the webview the fallback immediately.
                                            },
                                            child: const Text('Try Web Viewer'),
                                          ),
                                        ],
                                      ),
                                    )
                          : WebViewWidget(
                              controller: WebViewController()
                                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                ..loadRequest(Uri.parse(
                                    'https://docs.google.com/gview?embedded=true&url=$_targetUrl')),
                            ),
                ),
              ),
            ),
            if (!widget.isFinalFile)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleIncorrect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.red))
                            : Text(
                                'This is Incorrect',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleCorrect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF02F1C3),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'This is Correct',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
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
}
