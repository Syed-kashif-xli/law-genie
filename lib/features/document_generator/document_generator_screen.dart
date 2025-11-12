import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:ui';

class DocumentGeneratorScreen extends StatefulWidget {
  const DocumentGeneratorScreen({super.key});

  @override
  State<DocumentGeneratorScreen> createState() =>
      _DocumentGeneratorScreenState();
}

class _DocumentGeneratorScreenState extends State<DocumentGeneratorScreen> {
  final _partyANameController = TextEditingController();
  final _partyBNameController = TextEditingController();
  final _additionalDetailsController = TextEditingController();
  final _effectiveDateController = TextEditingController();

  String? _selectedDocumentType;
  String? _selectedJurisdiction;

  final List<String> _documentTypes = [
    'Non-Disclosure Agreement',
    'Lease Agreement',
    'Employment Contract',
    'Service Agreement'
  ];

  final List<String> _jurisdictions = [
    'California, USA',
    'New York, USA',
    'Texas, USA',
    'Federal',
  ];

  @override
  void dispose() {
    _partyANameController.dispose();
    _partyBNameController.dispose();
    _additionalDetailsController.dispose();
    _effectiveDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0B2E), // Dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {}, // Placeholder for drawer
        ),
        title: Text(
          'Document Generator',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create professional legal documents with AI assistance',
              style: GoogleFonts.poppins(
                color: Colors.white.withAlpha(178),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildGlassmorphicContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Document Type'),
                  _buildDropdown(_documentTypes, _selectedDocumentType,
                      'Select document type', (val) {
                    setState(() => _selectedDocumentType = val);
                  }),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Party A Name'),
                  _buildTextField(_partyANameController, 'Enter name'),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Party B Name'),
                  _buildTextField(_partyBNameController, 'Enter name'),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Additional Details'),
                  _buildTextField(_additionalDetailsController,
                      'Provide specific terms, conditions, or requirements...',
                      maxLines: 4),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Effective Date'),
                  _buildDateField(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Jurisdiction'),
                  _buildDropdown(_jurisdictions, _selectedJurisdiction,
                      'Select jurisdiction', (val) {
                    setState(() => _selectedJurisdiction = val);
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphicContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withAlpha(51),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white.withAlpha(230),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white54),
        filled: true,
        fillColor: Colors.black.withAlpha(51),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8A2BE2), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? value, String hint,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(hint, style: GoogleFonts.poppins(color: Colors.white54)),
      dropdownColor: const Color(0xFF1A0B2E),
      icon: const Icon(Iconsax.arrow_down_1, color: Colors.white54),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black.withAlpha(51),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8A2BE2), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _effectiveDateController,
      style: GoogleFonts.poppins(color: Colors.white),
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'dd-mm-yyyy',
        hintStyle: GoogleFonts.poppins(color: Colors.white54),
        filled: true,
        fillColor: Colors.black.withAlpha(51),
        suffixIcon: const Icon(Iconsax.calendar_1, color: Colors.white54),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8A2BE2), width: 1.5),
        ),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF8A2BE2), // header background color
                  onPrimary: Colors.white, // header text color
                  onSurface: Colors.white, // body text color
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        const Color(0xFF8A2BE2), // button text color
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          String formattedDate =
              "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
          setState(() {
            _effectiveDateController.text = formattedDate;
          });
        }
      },
    );
  }

  Widget _buildGenerateButton() {
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF8A2BE2), Color(0xFF4B0082)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A2BE2).withAlpha(128),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement document generation logic
          },
          icon: const Icon(Iconsax.document_text_1, color: Colors.white),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Generate Document',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
