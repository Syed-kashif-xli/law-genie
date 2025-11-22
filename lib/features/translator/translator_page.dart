import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/services/translation_service.dart';

const String _apiKey = 'AIzaSyC6NWmWsSowYUpYMOKCJ2EO1fD8-9UXB6s';

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TranslationService _translationService;

  // Text Translation State
  final TextEditingController _textController = TextEditingController();
  String _translatedText = '';
  bool _isTranslating = false;
  String _sourceLang = 'English';
  String _targetLang = 'Hindi';

  // Document Translation State
  String? _selectedFilePath;
  String _documentText = '';
  String _translatedDocumentText = '';
  bool _isProcessingDocument = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _translationService = TranslationService(_apiKey);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
  }

  Future<void> _translateText() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _translatedText = '';
    });

    final result = await _translationService.translateText(
      _textController.text,
      _sourceLang,
      _targetLang,
    );

    setState(() {
      _translatedText = result;
      _isTranslating = false;
    });
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _documentText = '';
        _translatedDocumentText = '';
      });
    }
  }

  Future<void> _translateDocument() async {
    if (_selectedFilePath == null) return;

    setState(() {
      _isProcessingDocument = true;
    });

    // 1. Extract Text
    final text =
        await _translationService.extractTextFromPdf(_selectedFilePath!);

    setState(() {
      _documentText = text;
    });

    if (text.length > 30000) {
      setState(() {
        _translatedDocumentText =
            "Document too large for single-pass translation. Showing extracted text only.";
        _isProcessingDocument = false;
      });
      return;
    }

    final translated = await _translationService.translateText(
      text,
      _sourceLang,
      _targetLang,
    );

    setState(() {
      _translatedDocumentText = translated;
      _isProcessingDocument = false;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('AI Translator',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF02F1C3),
          indicatorWeight: 3,
          labelColor: const Color(0xFF02F1C3),
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Text'),
            Tab(text: 'Document'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A032A), Color(0xFF151038)],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTextTab(),
            _buildDocumentTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildLanguageSelector(),
          const SizedBox(height: 24),
          _buildInputArea(),
          const SizedBox(height: 24),
          _buildTranslateButton(_isTranslating, _translateText),
          const SizedBox(height: 24),
          if (_translatedText.isNotEmpty) _buildOutputArea(_translatedText),
        ],
      ),
    );
  }

  Widget _buildDocumentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildLanguageSelector(),
          const SizedBox(height: 24),
          _buildUploadArea(),
          const SizedBox(height: 24),
          _buildTranslateButton(
              _isProcessingDocument || _selectedFilePath == null,
              _translateDocument,
              label: 'Translate Document'),
          const SizedBox(height: 24),
          if (_translatedDocumentText.isNotEmpty)
            _buildOutputArea(_translatedDocumentText,
                title: 'Translated Document'),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF19173A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLanguageChip(_sourceLang),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF02F1C3).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Iconsax.arrow_swap_horizontal,
                  color: Color(0xFF02F1C3)),
              onPressed: _swapLanguages,
            ),
          ),
          _buildLanguageChip(_targetLang),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        language,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1832),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF02F1C3).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Text',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF02F1C3),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Type in $_sourceLang',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              if (_textController.text.isNotEmpty)
                Text(
                  '${_textController.text.length} chars',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(minHeight: 120),
            child: TextField(
              controller: _textController,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
              ),
              maxLines: null,
              minLines: 5,
              cursorColor: const Color(0xFF02F1C3),
              decoration: InputDecoration(
                hintText: 'Start typing in $_sourceLang...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white30,
                  fontSize: 16,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _pickDocument,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: const Color(0xFF19173A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _selectedFilePath != null
                ? const Color(0xFF02F1C3)
                : Colors.white.withOpacity(0.1),
            width: _selectedFilePath != null ? 1.5 : 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF02F1C3).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _selectedFilePath != null
                    ? Iconsax.document_text
                    : Iconsax.document_upload,
                size: 32,
                color: const Color(0xFF02F1C3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilePath != null
                  ? _selectedFilePath!.split('/').last
                  : 'Tap to upload PDF',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedFilePath == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Supports .pdf files',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslateButton(bool isDisabled, VoidCallback onPressed,
      {String label = 'Translate'}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isDisabled
            ? null
            : const LinearGradient(
                colors: [Color(0xFF02F1C3), Color(0xFF00D0A6)],
              ),
        color: isDisabled ? Colors.white.withOpacity(0.1) : null,
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF02F1C3).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isDisabled && (_isTranslating || _isProcessingDocument)
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.poppins(
                  color: isDisabled ? Colors.white38 : const Color(0xFF0A032A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildOutputArea(String text, {String title = 'Translation'}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF19173A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF02F1C3).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF02F1C3),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white54, size: 20),
                onPressed: () => _copyToClipboard(text),
                tooltip: 'Copy',
              ),
            ],
          ),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
