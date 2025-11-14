import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_file/open_file.dart';

class DocumentViewerPage extends StatefulWidget {
  final String documentContent;

  const DocumentViewerPage({super.key, required this.documentContent});

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  bool _isDownloading = false;
  bool _isSavingToCloud = false;

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.poppinsRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Text(
              widget.documentContent,
              style: pw.TextStyle(font: font, fontSize: 12),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _downloadAsPdf() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final pdfData = await _generatePdf();

      // Get the directory for downloads
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Could not get downloads directory.');
      }
      
      final fileName = 'GeneratedDocument_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to $filePath')),
      );
      
      // Open the PDF file
      await OpenFile.open(filePath);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF: $e')),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<void> _saveToCloud() async {
    setState(() {
      _isSavingToCloud = true;
    });

    try {
      final pdfData = await _generatePdf();
      final fileName = 'GeneratedDocument_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('documents/$fileName');
      await storageRef.putData(pdfData);

      final downloadUrl = await storageRef.getDownloadURL();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to cloud! Download URL: $downloadUrl')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving to cloud: $e')),
      );
    } finally {
      setState(() {
        _isSavingToCloud = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.2),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Generated Document',
          style: GoogleFonts.merriweather(
            color: const Color(0xFF333333),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          if (_isDownloading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 24, 
                height: 24, 
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF4A8CFF))
              ),
            )
          else
            IconButton(
              icon: const Icon(Iconsax.document_download, color: Color(0xFF333333)),
              onPressed: _downloadAsPdf,
              tooltip: 'Download as PDF',
            ),
          if (_isSavingToCloud)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 24, 
                height: 24, 
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF4A8CFF))
              ),
            )
          else
            IconButton(
              icon: const Icon(Iconsax.cloud_add, color: Color(0xFF333334)),
              onPressed: _saveToCloud,
              tooltip: 'Save to Cloud',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: SelectableText(
            widget.documentContent,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF333333),
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}
