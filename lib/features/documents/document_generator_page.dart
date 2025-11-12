import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:iconsax/iconsax.dart';

const String _apiKey = 'AIzaSyC6NWmWsSowYUpYMOKCJ2EO1fD8-9UXB6s';

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
  String? _selectedLanguage;
  String? _generatedDocument;
  bool _isGenerating = false;

  late final GenerativeModel _model;

  final List<String> _documentTypes = [
    '⚖️ Affidavit',
    '📄 Agreement for Sale',
    '🧑‍⚖️ Bail Application',
    '💸 Cheque Bounce Notice',
    '🛒 Consumer Complaint',
    '💔 Divorce Petition',
    '📜 Durable Power of Attorney',
    '🏢 Franchise Agreement',
    '🎁 Gift Deed',
    '🛡️ Indemnity Bond',
    '🤝 Joint Venture Agreement',
    '📄 Lease Agreement',
    '📢 Legal Notice',
    '📝 Living Will',
    '🏠 Mortgage Deed',
    '🤫 Non-Disclosure Agreement (NDA)',
    '👥 Partnership Deed',
    '👪 Paternity Acknowledgment',
    '✍️ Pleading Paper',
    '📜 Power of Attorney',
    '💍 Prenuptial Agreement',
    '💰 Promissory Note',
    '🏡 Property Sale Agreement',
    '👋 Relinquishment Deed',
    '🏠 Rental Agreement',
    '💰 Sale Deed',
    '⚙️ Service Level Agreement (SLA)',
    '🤝 Settlement Agreement',
    '📜 Special Power of Attorney',
    '🏛️ Trust Deed',
    '🕊️ Will',
    '👨‍👩‍👧‍👦 Adoption Deed',
    '📝 Arbitration Agreement',
    '➡️ Assignment Deed',
    '🧑‍🤝‍🧑 Co-founder\'s Agreement',
    '👨‍💼 Consultancy Agreement',
    '📝 Contract for Services',
    '©️ Copyright License Agreement',
    '💰 Debt Settlement Agreement',
    '👨‍💼 Employee Offer Letter',
    '📜 End-User License Agreement (EULA)',
    '🤝 Escrow Agreement',
    '🧑‍🤝‍🧑 Founders\'s Agreement',
    '👨‍💻 Freelancer Agreement',
    '🔗 Hypothecation Deed',
    '💡 Intellectual Property (IP) Assignment Agreement',
    '👨‍🎓 Internship Agreement',
    '💰 Loan Agreement',
    '📝 Memorandum of Understanding (MoU)',
    '🎵 Music License Agreement',
    '👍 No Objection Certificate (NOC)',
    '➗ Partition Deed',
    '💍 Postnuptial Agreement',
    '🤝 Release Agreement',
    '🧾 Rent Receipt',
    '👋 Resignation Letter',
    '💰 Share Purchase Agreement',
    '🤝 Shareholders\'s Agreement',
    '💻 Software Development Agreement',
    '📜 Software License Agreement',
    '🤝 Sponsorship Agreement',
    '↩️ Surrender of Tenancy',
    '📝 Term Sheet',
    '📜 Terms of Service',
    '™️ Trademark License Agreement',
    '🚗 Vehicle Lease Agreement',
    '🚚 Vendor Agreement',
    '🔒 Website Privacy Policy',
    '📜 Website Terms and Conditions',
  ];

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
  }

  Future<void> _initGenerativeModel() async {
    final geminiPrompt = await rootBundle.loadString('GEMINI.md');
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
      systemInstruction: Content.text(geminiPrompt),
    );
  }

  @override
  void dispose() {
    _partyANameController.dispose();
    _partyBNameController.dispose();
    _additionalDetailsController.dispose();
    _effectiveDateController.dispose();
    super.dispose();
  }

  Future<void> _generateDocument() async {
    if (_selectedDocumentType == null) {
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

    final prompt = """
    Generate a '$_selectedDocumentType' in $_selectedLanguage with the following details:
    - Party A: ${_partyANameController.text}
    - Party B: ${_partyBNameController.text}
    - Effective Date: ${_effectiveDateController.text}
    - Jurisdiction: $_selectedJurisdiction
    - Additional Details: ${_additionalDetailsController.text}

    Please format the output as a legal document.
    Remember to wrap the document in [START_DOCUMENT:$_selectedDocumentType] and [END_DOCUMENT] tags.
    """ ;
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
      items: _documentTypes,
      selectedItem: _selectedDocumentType,
      onChanged: (String? newValue) {
        setState(() {
          _selectedDocumentType = newValue;
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

  Widget _buildDateField() {
    return TextField(
      controller: _effectiveDateController,
      style: GoogleFonts.lexend(color: Colors.black87),
      decoration: InputDecoration(
        hintText: 'dd-mm-yyyy',
        hintStyle: GoogleFonts.lexend(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: Icon(Iconsax.calendar_1, color: Colors.grey[600]),
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
      onTap: () async {
        FocusScope.of(context)
            .requestFocus(FocusNode()); // to prevent keyboard from appearing
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
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
