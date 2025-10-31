import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class DocumentGeneratorPage extends StatefulWidget {
  const DocumentGeneratorPage({super.key});

  @override
  State<DocumentGeneratorPage> createState() => _DocumentGeneratorPageState();
}

class _DocumentGeneratorPageState extends State<DocumentGeneratorPage> {
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
          style: GoogleFonts.poppins(
              color: const Color(0xFF333333),
              fontWeight: FontWeight.w600,
              fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 72.0, bottom: 8.0),
              child: Text(
                'Create professional legal documents with AI assistance',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Document Type'),
              _buildDropdown(_documentTypes, _selectedDocumentType, 'Select document type',
                  (val) => setState(() => _selectedDocumentType = val)),
              const SizedBox(height: 20),
              _buildSectionTitle('Party A Name'),
              _buildTextField(_partyANameController, 'Enter name'),
              const SizedBox(height: 20),
              _buildSectionTitle('Party B Name'),
              _buildTextField(_partyBNameController, 'Enter name'),
              const SizedBox(height: 20),
              _buildSectionTitle('Additional Details'),
              _buildTextField(_additionalDetailsController, 'Provide specific terms, conditions, or requirements...',
                  maxLines: 4),
              const SizedBox(height: 20),
              _buildSectionTitle('Effective Date'),
              _buildDateField(),
              const SizedBox(height: 20),
              _buildSectionTitle('Jurisdiction'),
              _buildDropdown(_jurisdictions, _selectedJurisdiction, 'Select jurisdiction',
                  (val) => setState(() => _selectedJurisdiction = val)),
              const SizedBox(height: 32),
              _buildGenerateButton(),
            ],
          ),
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
          fontSize: 14,
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
      style: GoogleFonts.poppins(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildDropdown(
      List<String> items, String? value, String hint, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(hint, style: GoogleFonts.poppins(color: Colors.grey[400])),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: GoogleFonts.poppins(fontSize: 14)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _effectiveDateController,
      style: GoogleFonts.poppins(color: Colors.black87),
      decoration: InputDecoration(
        hintText: 'dd-mm-yyyy',
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: Icon(Iconsax.calendar_1, color: Colors.grey[600]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode()); // to prevent keyboard from appearing
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          String formattedDate = "${pickedDate.day.toString().padLeft(2,'0')}-${pickedDate.month.toString().padLeft(2,'0')}-${pickedDate.year}";
          setState(() {
            _effectiveDateController.text = formattedDate;
          });
        }
      },
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
            color: const Color(0xFF5C9DFF).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Iconsax.document_text_1, color: Colors.white),
        label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
          'Generate Document',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        )),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
