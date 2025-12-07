import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151038),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // ignore: deprecated_member_use
              Share.share('Check out this legal document: ${widget.url}');
            },
          ),
        ],
      ),
      body: const PDF(
        swipeHorizontal: true,
        enableSwipe: true,
        autoSpacing: false,
        pageFling: false,
      ).cachedFromUrl(
        widget.url,
        placeholder: (progress) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: progress / 100,
                color: const Color(0xFF02F1C3),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading PDF: $progress%',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            ],
          ),
        ),
        errorWidget: (error) => Center(
          child: Text(
            'Failed to load PDF: $error',
            style: GoogleFonts.poppins(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
