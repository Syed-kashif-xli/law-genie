import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/bare_act.dart';

class BareActViewerPage extends StatelessWidget {
  final BareAct bareAct;

  const BareActViewerPage({super.key, required this.bareAct});

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF02F1C3)),
        ),
      );

      // Check Permissions
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        // For Android 13+ (SDK 33), permission.storage might be denied permanently or not needed for public media dirs,
        // but for Download folder using File API, we might need manageExternalStorage or just scoped storage which is complex.
        // We will try to save to a safe App Directory first if external fails, or suggest 'Open' which caches it.
      }

      // Download
      final response = await http.get(Uri.parse(bareAct.pdfUrl));
      if (response.statusCode != 200)
        throw Exception('Download failed: ${response.statusCode}');

      // Determine path
      Directory? directory;
      if (Platform.isAndroid) {
        // Try public Download folder
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final safeTitle =
            bareAct.title.replaceAll(RegExp(r'[^\w\s\-]'), '').trim();
        // Ensure LawGenie folder exists
        final safeDir = Directory('${directory.path}/LawGenie');
        if (!await safeDir.exists()) {
          await safeDir.create(recursive: true).catchError(
              (e) => directory!); // Fallback to root if create fails
        }

        final saveDiv = await safeDir.exists() ? safeDir : directory;

        final String filePath = '${saveDiv.path}/$safeTitle.pdf';
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (context.mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloaded to: $filePath'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'OPEN',
                textColor: Colors.white,
                onPressed: () => OpenFile.open(filePath),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download error: $e')),
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
