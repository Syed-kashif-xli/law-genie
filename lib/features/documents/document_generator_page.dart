import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:iconsax/iconsax.dart';
import 'document_fields.dart'; // Import the new file
import 'document_viewer_page.dart';
import '../../services/ad_service.dart';
import 'package:myapp/features/home/widgets/inline_banner_ad_widget.dart';

class DocumentGeneratorPage extends StatefulWidget {
  const DocumentGeneratorPage({super.key});

  @override
  State<DocumentGeneratorPage> createState() => _DocumentGeneratorPageState();
}

class _DocumentGeneratorPageState extends State<DocumentGeneratorPage> {
  String? _selectedDocumentType;
  String? _selectedJurisdiction;
  String? _selectedLanguage;
  bool _isGenerating = false;

  late final GenerativeModel _model;

  // Controllers for dynamic fields
  final Map<String, TextEditingController> _dynamicFieldControllers = {};

  final List<String> _jurisdictions = [
    'Delhi',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
    'Uttar Pradesh',
  ];

  final List<String> _languages = ['English', 'Hindi'];

  @override
  void initState() {
    super.initState();
    _initGenerativeModel();
    // Initialize with the keys from documentFields
    _selectedDocumentType = documentFields.keys.first;
    _updateDynamicControllers(_selectedDocumentType);
  }

  Future<void> _initGenerativeModel() async {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(
          'You are an expert legal drafter specializing in Indian legal documents. '
          'Generate professional, legally sound documents compliant with Indian laws. '
          'Use standard Indian legal formats, terminology, and citations. '
          'Ensure the document is complete with placeholders for specific details (e.g., [Name], [Date], [Place]). '
          'The output should be the document content ONLY, ready for printing or saving as PDF. '
          'Do not include any conversational text before or after the document.'),
    );
  }

  @override
  void dispose() {
    // Dispose all dynamic controllers
    _dynamicFieldControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _updateDynamicControllers(String? documentType) {
    if (documentType == null) return;

    // Clear old controllers
    _dynamicFieldControllers.forEach((_, controller) => controller.dispose());
    _dynamicFieldControllers.clear();

    // Create new controllers for the selected document type
    final fields = documentFields[documentType] ?? [];
    for (final field in fields) {
      _dynamicFieldControllers[field] = TextEditingController();
    }
  }

  String _stripEmoji(String text) {
    return text
        .replaceAll(
            RegExp(
                r'(\u[0-9a-fA-F]{4})|(\U[0-9a-fA-F]{8})|([\uD800-\uDBFF][\uDC00-\uDFFF])|([\u2600-\u26FF\u2700-\u27BF])|([\uD83C-\uDBFF\uDC00-\uDFFF].)|[\uFE0E\uFE0F]'),
            '')
        .trim();
  }

  Future<void> _generateDocument() async {
    if (_selectedDocumentType == null ||
        _selectedDocumentType == 'Select Document Type') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a document type.')),
      );
      return;
    }
    if (_selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a language.')),
      );
      return;
    }

    _showAdAndGenerate();
  }

  void _showAdAndGenerate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    AdService.showRewardedAd(
      onUserEarnedReward: () {
        Navigator.pop(context); // Close loading
        _performGeneration();
      },
      onAdFailedToLoad: () {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load ad. Generating document...')),
        );
        _performGeneration();
      },
    );
  }

  Future<void> _performGeneration() async {
    setState(() {
      _isGenerating = true;
    });

    final docType = _stripEmoji(_selectedDocumentType!);

    // Constructing the details from dynamic fields
    final details = _dynamicFieldControllers.entries
        .map((entry) => "- ${_stripEmoji(entry.key)}: ${entry.value.text}")
        .join("\n");

    final prompt = """
    **Act as an expert Indian legal drafter.**

    Generate a '$docType' in $_selectedLanguage. This document must strictly adhere to the highest standards of Indian legal drafting and legal style. Ensure the language used is formal, precise, and consistent with the style used in Indian courts.

    **Input Details:**
    $details
    - Jurisdiction: $_selectedJurisdiction

    **Mandatory Formatting and Structure:**

    1.  **Court/Forum Name (if applicable):** Start with the name of the court or forum at the top, centered and in bold. E.g., **IN THE COURT OF THE DISTRICT JUDGE, DELHI**.
    2.  **Case Number (if applicable):** Below the court name, add the case number. E.g., **CIVIL SUIT NO. 123 OF 2024**.
    3.  **Parties:** Clearly define the parties. Use a two-column format with the petitioner/plaintiff on the left and the respondent/defendant on the right. Include full names, parentage, addresses, and their roles.
        *Example:*
        [Petitioner Name]
        S/o [Father's Name]
        R/o [Address]                                             ...Petitioner

        VERSUS

        [Respondent Name]
        S/o [Father's Name]
        R/o [Address]                                             ...Respondent

    4.  **Title of the Document:** Centered, bold, and underlined. E.g., **<u>RENTAL AGREEMENT</u>** or **<u>WRITTEN STATEMENT</u>**.
    5.  **Recitals/Preamble (WHEREAS clauses for agreements):** For agreements, use 'WHEREAS' clauses to state the background. For petitions/plaints, provide an introduction.
    6.  **Operative Clauses/Body:**
        - For agreements, use the phrase: **'NOW, THEREFORE, THIS AGREEMENT WITNESSETH AS FOLLOWS:'**
        - For petitions/plaints, structure the content into numbered paragraphs, each addressing a specific point.
        - Use formal legal language throughout (e.g., 'hereto', 'hereinafter', 'aforesaid', 'notwithstanding').
    7.  **Prayer Clause (for petitions/plaints):** End with a clear 'PRAYER' section, stating the relief sought from the court.
    8.  **Verification Clause:** Include a verification clause at the end. 
        *Example for Plaint:*
        **VERIFICATION**
        Verified at [Place] on this [Date] day of [Month], [Year] that the contents of paragraphs 1 to [last paragraph] of the above plaint are true to my knowledge and the contents of paragraphs [x] to [y] are based on legal advice received and believed to be true. 

        [Deponent/Petitioner Signature]

    9.  **Signature Blocks:** Include signature blocks for the parties and their advocates (if applicable) on the right-hand side.

    **Final Output:** The document must be a complete, professional, and executable legal draft, free of any conversational text or explanations. Do not include any text like "Here is the document you requested".
    """;
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      if (!mounted) return;

      if (responseText != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DocumentViewerPage(documentContent: responseText),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not generate document.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating document: $e')),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Document Generator',
          style: GoogleFonts.merriweather(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'Enter Document Details',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white, // White text
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  _buildSectionTitle('Document Type'),
                  _buildDocumentTypeDropdown(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Language'),
                  _buildDropdown(
                      _languages,
                      _selectedLanguage,
                      'Select language',
                      (val) => setState(() => _selectedLanguage = val)),
                  const SizedBox(height: 20),
                  _buildDynamicFields(), // Widget for dynamic fields
                  const SizedBox(height: 20),
                  _buildSectionTitle('Jurisdiction'),
                  _buildDropdown(
                      _jurisdictions,
                      _selectedJurisdiction,
                      'Select jurisdiction',
                      (val) => setState(() => _selectedJurisdiction = val)),
                  const SizedBox(height: 32),
                  _buildGenerateButton(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const InlineBannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        _stripEmoji(title),
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white, // White text
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.lexend(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lexend(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF0A032A), // Dark input
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C55A9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C55A9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF02F1C3), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDynamicFields() {
    final fields = documentFields[_selectedDocumentType] ?? [];
    if (fields.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final field = fields[index];
        final controller = _dynamicFieldControllers[field];
        final isMultiLine = field == 'Additional Details (Optional)';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(field),
            _buildTextField(
              controller!,
              'Enter ${_stripEmoji(field)}',
              maxLines: isMultiLine ? 5 : 1,
            ),
          ],
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 20),
    );
  }

  Widget _buildDropdown(List<String> items, String? value, String hint,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      hint: Text(hint,
          style: GoogleFonts.lexend(color: Colors.white38),
          overflow: TextOverflow.ellipsis),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item,
              style: GoogleFonts.lexend(fontSize: 14, color: Colors.white),
              overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF0A032A), // Dark dropdown
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C55A9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C55A9)),
        ),
      ),
      dropdownColor: const Color(0xFF19173A), // Dark dropdown menu
    );
  }

  Widget _buildDocumentTypeDropdown() {
    return DropdownSearch<String>(
      items: documentFields.keys.toList(),
      selectedItem: _selectedDocumentType,
      onChanged: (String? newValue) {
        setState(() {
          _selectedDocumentType = newValue;
          _updateDynamicControllers(newValue);
        });
      },
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          hintText: 'Select document type',
          hintStyle: GoogleFonts.lexend(color: Colors.white38),
          filled: true,
          fillColor: const Color(0xFF0A032A), // Dark background
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2C55A9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2C55A9)),
          ),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: "Search...",
          ),
        ),
        itemBuilder: (context, item, isSelected) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color:
                isSelected ? const Color(0xFF2C55A9) : const Color(0xFF19173A),
            child: Text(
              item,
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF5C9DFF), Color(0xFF4A8CFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C9DFF).withAlpha(102),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : _generateDocument,
        icon: _isGenerating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : const Icon(Iconsax.document_text_1, color: Colors.white),
        label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              _isGenerating ? 'Generating...' : 'Generate Document',
              style:
                  GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 16),
            )),
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
