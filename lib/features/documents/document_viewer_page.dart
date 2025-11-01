import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentViewerPage extends StatelessWidget {
  final String document;

  const DocumentViewerPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Generated Document',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Text(document, style: GoogleFonts.poppins()),
      ),
    );
  }
}
