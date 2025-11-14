import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentViewerPage extends StatefulWidget {
  final String documentContent;

  const DocumentViewerPage({super.key, required this.documentContent});

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  late final TextEditingController _documentController;

  @override
  void initState() {
    super.initState();
    _documentController = TextEditingController(text: widget.documentContent);
  }

  @override
  void dispose() {
    _documentController.dispose();
    super.dispose();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _documentController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Document'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _documentController,
          maxLines: null, // Allows for multiline input
          expands: true, // Expands to fill the available space
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Your generated document will appear here.',
          ),
          style: GoogleFonts.merriweather(fontSize: 16),
        ),
      ),
    );
  }
}
