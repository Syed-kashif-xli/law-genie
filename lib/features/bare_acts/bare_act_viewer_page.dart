import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:url_launcher/url_launcher.dart';
import 'models/bare_act.dart';

class BareActViewerPage extends StatelessWidget {
  final BareAct bareAct;

  const BareActViewerPage({super.key, required this.bareAct});

  Future<void> _downloadPdf(BuildContext context) async {
    final Uri url = Uri.parse(bareAct.pdfUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch download link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1832),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bareAct.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${bareAct.category} • ${bareAct.year}',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.orange),
            onPressed: () => _downloadPdf(context),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: const PDF().fromUrl(
        bareAct.pdfUrl,
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
                'Loading PDF... $progress%',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            ],
          ),
        ),
        errorWidget: (error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load PDF',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _downloadPdf(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in Browser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02F1C3),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
