import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:iconsax/iconsax.dart';
import 'document_fields.dart'; // Import the new file

const String _apiKey = 'AIzaSyC6NWmWsSowYUpYMOKCJ2EO1fD8-9UXB6s';

class DocumentGeneratorPage extends StatefulWidget {
  const DocumentGeneratorPage({super.key});

  @override
  State<DocumentGeneratorPage> createState() => _DocumentGeneratorPageState();
}

class _DocumentGeneratorPageState extends State<DocumentGeneratorPage> {
  String? _selectedDocumentType;
  String? _selectedJurisdiction;
  String? _selectedLanguage;
  String? _generatedDocument;
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
    final geminiPrompt = await rootBundle.loadString('GEMINI.md');
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.text(geminiPrompt),
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

  Future<void> _generateDocument() async {
    if (_selectedDocumentType == null || _selectedDocumentType == 'Select Document Type') {
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

    setState(() {
      _isGenerating = true;
      _generatedDocument = null;
    });

    // Constructing the details from dynamic fields
    final details = _dynamicFieldControllers.entries
        .map((entry) => "- ${entry.key}: ${entry.value.text}")
        .join("\n");

    final prompt = """
    Generate a '$_selectedDocumentType' in $_selectedLanguage with the following details:
    $details
    - Jurisdiction: $_selectedJurisdiction

    Please format the output as a legal document.
    Remember to wrap the document in [START_DOCUMENT:$_selectedDocumentType] and [END_DOCUMENT] tags.
    """;
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text;

      String documentContent = "Could not generate document.";

      if (responseText != null) {
        final docStartIndex = responseText.indexOf('[START_DOCUMENT:');
        final docEndIndex = responseText.indexOf('[END_DOCUMENT]');

        if (docStartIndex != -1 && docEndIndex != -1) {
          final titleStartIndex = docStartIndex + '[START_DOCUMENT:'.length;
          final titleEndIndex = responseText.indexOf(']', titleStartIndex);
          if (titleEndIndex != -1 && titleEndIndex < docEndIndex) {
            documentContent =
                responseText.substring(titleEndIndex + 1, docEndIndex).trim();
          } else {
            documentContent = responseText;
          }
        } else {
          documentContent = responseText;
        }
      } else {
        documentContent = "Could not generate document.";
      }

      setState(() {
        _generatedDocument = documentContent;
      });
    } catch (e) {
      setState(() {
        _generatedDocument = "Error generating document: $e";
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F4F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF333333)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text(
          'Document Generator',
          style: GoogleFonts.merriweather(
              color: const Color(0xFF333333),
              fontWeight: FontWeight.w700,
              fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: const Offset(0, 5), // changes position of shadow
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
                        color: const Color(0xFF333333),
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
            _buildGeneratedDocumentDisplay(),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.lexend(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lexend(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5),
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
              'Enter $field',
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
      value: value,
      hint: Text(hint,
          style: GoogleFonts.lexend(color: Colors.grey[400]),
          overflow: TextOverflow.ellipsis),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item,
              style: GoogleFonts.lexend(fontSize: 14),
              overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      dropdownColor: Colors.white,
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
          hintStyle: GoogleFonts.lexend(color: Colors.grey[400]),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
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
            child: Text(
              item,
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: isSelected ? Colors.blue.shade600 : Colors.black87,
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

  Widget _buildGeneratedDocumentDisplay() {
    if (_isGenerating) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_generatedDocument == null || _generatedDocument!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generated Document',
            style: GoogleFonts.merriweather(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          SelectableText(
            _generatedDocument!,
            style: GoogleFonts.lexend(color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }
}
