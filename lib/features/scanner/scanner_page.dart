import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:printing/printing.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final List<String> _scannedImages = [];
  List<Map<String, dynamic>> _recentScans = [];
  bool _isGenerating = false;
  bool _isProcessingOcr = false;

  @override
  void initState() {
    super.initState();
    _loadRecentScans();
  }

  Future<void> _loadRecentScans() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recentScansString = prefs.getString('recent_scans');
    if (recentScansString != null) {
      setState(() {
        _recentScans =
            List<Map<String, dynamic>>.from(jsonDecode(recentScansString));
      });
    }
  }

  Future<void> _saveRecentScan(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final newScan = {
      'path': path,
      'date': DateTime.now().toIso8601String(),
      'name': path.split('/').last,
    };
    _recentScans.insert(0, newScan);
    if (_recentScans.length > 10) {
      _recentScans.removeLast();
    }
    await prefs.setString('recent_scans', jsonEncode(_recentScans));
    setState(() {});
  }

  Future<void> _startScan() async {
    try {
      final List<String>? pictures = await CunningDocumentScanner.getPictures();
      if (pictures != null && pictures.isNotEmpty) {
        setState(() {
          _scannedImages.addAll(pictures);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _scannedImages.addAll(images.map((e) => e.path));
      });
    }
  }

  Future<void> _savePdf() async {
    if (_scannedImages.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final pdf = pw.Document();

      for (var imagePath in _scannedImages) {
        // Compress image to reduce size and lag
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          imagePath,
          minWidth: 1080,
          minHeight: 1920,
          quality: 80,
        );

        if (compressedBytes == null) continue;

        final pdfImage = pw.MemoryImage(compressedBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.copyWith(
              marginBottom: 0,
              marginLeft: 0,
              marginRight: 0,
              marginTop: 0,
            ),
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }

      // Default to Downloads folder
      String outputDirectory;
      if (Platform.isAndroid) {
        // Try standard Downloads path
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          outputDirectory = downloadsDir.path;
        } else {
          // Fallback to external storage
          final externalDir = await getExternalStorageDirectory();
          outputDirectory = externalDir?.path ??
              (await getApplicationDocumentsDirectory()).path;
        }
      } else {
        // iOS/Other
        outputDirectory = (await getApplicationDocumentsDirectory()).path;
      }

      // Ask for filename
      String? customName;
      if (mounted) {
        customName = await showDialog<String>(
          context: context,
          builder: (context) {
            final controller = TextEditingController(
                text: 'Scan_${DateTime.now().toString().split(' ')[0]}');
            return AlertDialog(
              backgroundColor: const Color(0xFF19173A).withOpacity(0.95),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Text('Save Document',
                  style: GoogleFonts.outfit(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter a name for your PDF:',
                      style: GoogleFonts.outfit(
                          color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter filename',
                      hintStyle: GoogleFonts.outfit(color: Colors.white30),
                    ),
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: GoogleFonts.outfit(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, controller.text.trim()),
                  child: Text('Save',
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF02F1C3),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      }

      if (customName == null || customName.isEmpty) {
        if (mounted) {
          setState(() {
            _isGenerating = false;
          });
        }
        return; // User cancelled
      }

      final fileName = '$customName.pdf';
      final filePath = '$outputDirectory/$fileName';
      final file = File(filePath);

      try {
        final pdfBytes = await pdf.save();
        await file.writeAsBytes(pdfBytes);
      } catch (e) {
        // If permission denied or path failed, fallback to app-specific storage
        final appDir = await getExternalStorageDirectory();
        outputDirectory =
            appDir?.path ?? (await getApplicationDocumentsDirectory()).path;
        final fallbackPath = '$outputDirectory/$fileName';
        final fallbackFile = File(fallbackPath);
        final pdfBytes = await pdf.save();
        await fallbackFile.writeAsBytes(pdfBytes);

        // Update filePath for the success message
        // Note: We can't easily update the 'filePath' variable since it's final,
        // but we can use the fallbackFile.path for the message.
        await _saveRecentScan(fallbackFile.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Saved to ${fallbackFile.path} (Downloads folder access denied)')),
          );
          setState(() {
            _scannedImages.clear();
          });
        }
        return;
      }

      await _saveRecentScan(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to $filePath')),
        );
        setState(() {
          _scannedImages.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _performOcr(String pdfPath) async {
    setState(() {
      _isProcessingOcr = true;
    });

    try {
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      StringBuffer extractedText = StringBuffer();

      for (var imagePath in _scannedImages) {
        final inputImage = InputImage.fromFilePath(imagePath);
        final RecognizedText recognizedText =
            await textRecognizer.processImage(inputImage);
        extractedText.writeln(recognizedText.text);
        extractedText.writeln('\n---\n');
      }

      await textRecognizer.close();

      if (mounted) {
        _showOcrResult(extractedText.toString());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error performing OCR: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingOcr = false;
        });
      }
    }
  }

  Future<void> _ocrImage(String path) async {
    try {
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFilePath(path);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      if (mounted) _showOcrResult(recognizedText.text);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('OCR Failed: $e')));
    }
  }

  void _showOcrResult(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF19173A).withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Extracted Text',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(text,
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Text copied to clipboard')),
              );
            },
            child: Text('Copy',
                style: GoogleFonts.outfit(
                    color: const Color(0xFF02F1C3),
                    fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Close', style: GoogleFonts.outfit(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildRecentScansDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pro Scanner',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF02F1C3).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.clock,
                    color: Color(0xFF02F1C3), size: 20),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Recent Scans',
            ),
          ),
          if (_scannedImages.isNotEmpty)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.trash,
                    color: Colors.redAccent, size: 20),
              ),
              onPressed: () {
                setState(() => _scannedImages.clear());
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A032A),
                  Color(0xFF19173A),
                  Color(0xFF050218),
                ],
              ),
            ),
          ),
          // Decorative Blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2C55A9).withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2C55A9).withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF02F1C3).withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF02F1C3).withOpacity(0.2),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          // Backdrop Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.transparent),
          ),

          // Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _scannedImages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF02F1C3).withOpacity(0.2),
                                      const Color(0xFF2C55A9).withOpacity(0.1),
                                    ],
                                  ),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.1)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF02F1C3)
                                          .withOpacity(0.1),
                                      blurRadius: 50,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Iconsax.scan,
                                  size: 70,
                                  color: Color(0xFF02F1C3),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Ready to Scan',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Capture documents with high precision\nor import from gallery',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _scannedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(
                                      File(_scannedImages[index]),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _scannedImages.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.2)),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _ocrImage(_scannedImages[index]),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.2)),
                                      ),
                                      child: const Icon(
                                        Iconsax.text_block,
                                        color: Color(0xFF02F1C3),
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: _scannedImages.isEmpty
                ? Row(
                    children: [
                      Expanded(
                        child: _buildGradientButton(
                          icon: Iconsax.gallery,
                          label: 'Gallery',
                          onPressed: _pickFromGallery,
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGradientButton(
                          icon: Iconsax.scan,
                          label: 'Scan',
                          onPressed: _startScan,
                          isPrimary: true,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildGradientButton(
                        icon: Iconsax.document_download,
                        label: 'Save as PDF',
                        onPressed: _savePdf,
                        isPrimary: true,
                        isLoading: _isGenerating,
                      ),
                      const SizedBox(height: 16),
                      _buildGradientButton(
                        icon: Iconsax.add,
                        label: 'Add Page',
                        onPressed: _startScan,
                        isPrimary: false,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _performOcrOnPdf(String pdfPath) async {
    setState(() {
      _isProcessingOcr = true;
    });

    try {
      final file = File(pdfPath);
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      // Rasterize the first page of the PDF to an image
      final pdfBytes = await file.readAsBytes();
      await for (final page in Printing.raster(pdfBytes, pages: [0])) {
        final imageBytes = await page.toPng();

        // Save to temp file for OCR
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_ocr_image.png');
        await tempFile.writeAsBytes(imageBytes);

        // Perform OCR
        final textRecognizer =
            TextRecognizer(script: TextRecognitionScript.latin);
        final inputImage = InputImage.fromFilePath(tempFile.path);
        final RecognizedText recognizedText =
            await textRecognizer.processImage(inputImage);
        await textRecognizer.close();

        if (mounted) {
          _showOcrResult(recognizedText.text);
        }
        break; // Only process the first page for now
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCR Failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingOcr = false;
        });
      }
    }
  }

  Widget _buildRecentScansDrawer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A032A),
                Color(0xFF1A1052),
                Color(0xFF0A032A),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Recent Scans',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            BoxShadow(
                              color: const Color(0xFF02F1C3).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Section
                Expanded(
                  child: _recentScans.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF2C55A9).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Iconsax.document_text,
                                  size: 48,
                                  color: Colors.white24,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No recent scans',
                                style: GoogleFonts.outfit(
                                  color: Colors.white54,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          itemCount: _recentScans.length,
                          itemBuilder: (context, index) {
                            final scan = _recentScans[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.08)),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.08),
                                    Colors.white.withOpacity(0.02),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF2C55A9),
                                                    Color(0xFF4C75C9)
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF2C55A9)
                                                            .withOpacity(0.4),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                  Iconsax.document_text,
                                                  color: Colors.white,
                                                  size: 24),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    scan['name'] ?? 'Untitled',
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Icon(Iconsax.clock,
                                                          size: 14,
                                                          color:
                                                              Colors.white54),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        scan['date'] != null
                                                            ? DateTime.parse(
                                                                    scan[
                                                                        'date'])
                                                                .toString()
                                                                .split('.')[0]
                                                            : '',
                                                        style:
                                                            GoogleFonts.outfit(
                                                          color: Colors.white54,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Container(
                                          height: 1,
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildActionButton(
                                              icon: Iconsax.eye,
                                              label: 'Open',
                                              onTap: () =>
                                                  OpenFile.open(scan['path']),
                                            ),
                                            _buildActionButton(
                                              icon: Iconsax.text_block,
                                              label: 'OCR',
                                              onTap: () => _performOcrOnPdf(
                                                  scan['path']),
                                            ),
                                            _buildActionButton(
                                              icon: Iconsax.export_1,
                                              label: 'Share',
                                              onTap: () => Share.shareXFiles(
                                                  [XFile(scan['path'])],
                                                  text: 'Shared via Law Genie'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
    Color? color,
    Color? textColor,
    bool isLoading = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isPrimary
            ? LinearGradient(
                colors: color != null
                    ? [color, color.withOpacity(0.8)]
                    : [const Color(0xFF2C55A9), const Color(0xFF4C75C9)],
              )
            : null,
        color: isPrimary ? null : Colors.white.withOpacity(0.05),
        border:
            isPrimary ? null : Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: (color ?? const Color(0xFF2C55A9)).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: textColor ?? Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: textColor ?? Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          color: textColor ?? Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
