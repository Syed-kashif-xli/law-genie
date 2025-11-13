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
  // --- TEXT EDITING CONTROLLERS ---
  // General
  final _partyANameController = TextEditingController();
  final _partyBNameController = TextEditingController();
  final _additionalDetailsController = TextEditingController();
  final _effectiveDateController = TextEditingController();

  // Indian Law Specific
  final _deponentNameController = TextEditingController();
  final _deponentAddressController = TextEditingController();
  final _statementOfFactsController = TextEditingController();
  final _sellerNameController = TextEditingController();
  final _buyerNameController = TextEditingController();
  final _propertyDescriptionController = TextEditingController();
  final _saleAmountController = TextEditingController();
  final _accusedNameController = TextEditingController();
  final _firNoController = TextEditingController();
  final _policeStationController = TextEditingController();
  final _sectionsOfLawController = TextEditingController();
  final _chequeNoController = TextEditingController();
  final _chequeDateController = TextEditingController();
  final _chequeAmountController = TextEditingController();
  final _complainantNameController = TextEditingController();
  final _oppositePartyNameController = TextEditingController();
  final _complaintDetailsController = TextEditingController();
  final _petitionerNameController = TextEditingController();
  final _respondentNameController = TextEditingController();
  final _marriageDateController = TextEditingController();
  final _groundsForDivorceController = TextEditingController();
  final _principalNameController = TextEditingController();
  final _attorneyNameController = TextEditingController();
  final _powersGrantedController = TextEditingController();
  final _franchisorNameController = TextEditingController();
  final _franchiseeNameController = TextEditingController();
  final _franchiseTerritoryController = TextEditingController();
  final _donorNameController = TextEditingController();
  final _doneeNameController = TextEditingController();
  final _giftDetailsController = TextEditingController();
  final _indemnifierNameController = TextEditingController();
  final _indemnityHolderNameController = TextEditingController();
  final _indemnityClauseController = TextEditingController();
  final _venturerANameController = TextEditingController();
  final _venturerBNameController = TextEditingController();
  final _jvPurposeController = TextEditingController();
  final _lessorNameController = TextEditingController();
  final _lesseeNameController = TextEditingController();
  final _leasePropertyController = TextEditingController();
  final _noticeSenderNameController = TextEditingController();
  final _noticeRecipientNameController = TextEditingController();
  final _noticeSubjectController = TextEditingController();
  final _testatorNameController = TextEditingController();
  final _willClausesController = TextEditingController();
  final _mortgagorNameController = TextEditingController();
  final _mortgageeNameController = TextEditingController();
  final _mortgagedPropertyController = TextEditingController();
  final _disclosingPartyController = TextEditingController();
  final _receivingPartyController = TextEditingController();
  final _confidentialInfoController = TextEditingController();
  final _partnerANameController = TextEditingController();
  final _partnerBNameController = TextEditingController();
  final _businessNatureController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _childNameController = TextEditingController();
  final _plaintiffNameController = TextEditingController();
  final _defendantNameController = TextEditingController();
  final _prayerForReliefController = TextEditingController();
  final _spouse1NameController = TextEditingController();
  final _spouse2NameController = TextEditingController();
  final _prenupAssetsController = TextEditingController();
  final _promisorNameController = TextEditingController();
  final _promiseeNameController = TextEditingController();
  final _principalAmountController = TextEditingController();
  final _relinquisherNameController = TextEditingController();
  final _beneficiaryNameController = TextEditingController();
  final _relinquishedPropertyController = TextEditingController();
  final _landlordNameController = TextEditingController();
  final _tenantNameController = TextEditingController();
  final _rentAmountController = TextEditingController();
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _serviceProviderController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _serviceDescriptionController = TextEditingController();
  final _settlingPartyAController = TextEditingController();
  final _settlingPartyBController = TextEditingController();
  final _settlementTermsController = TextEditingController();
  final _trusteeNameController = TextEditingController();
  final _beneficiaryOfTrustController = TextEditingController();
  final _trustPropertyController = TextEditingController();
  final _adoptingParentsNameController = TextEditingController();
  final _biologicalParentsNameController = TextEditingController();
  final _childToBeAdoptedNameController = TextEditingController();

  String? _selectedDocumentType;
  String? _selectedJurisdiction;
  String? _selectedLanguage;

  // --- DATA LISTS ---
  final List<String> _documentTypes = [
    '⚖️ Affidavit', '📄 Agreement for Sale', '🧑‍⚖️ Bail Application', '💸 Cheque Bounce Notice', '🛒 Consumer Complaint', '💔 Divorce Petition', '📜 Durable Power of Attorney', '🏢 Franchise Agreement', '🎁 Gift Deed', '🛡️ Indemnity Bond', '🤝 Joint Venture Agreement', '📄 Lease Agreement', '📢 Legal Notice', '📝 Living Will', '🏠 Mortgage Deed', '🤫 Non-Disclosure Agreement (NDA)', '👥 Partnership Deed', '👪 Paternity Acknowledgment', '✍️ Pleading Paper', '📜 Power of Attorney', '💍 Prenuptial Agreement', '💰 Promissory Note', '🏡 Property Sale Agreement', '👋 Relinquishment Deed', '🏠 Rental Agreement', '💰 Sale Deed', '⚙️ Service Level Agreement (SLA)', '🤝 Settlement Agreement', '📜 Special Power of Attorney', '🏛️ Trust Deed', '🕊️ Will', '👨‍👩‍👧‍👦 Adoption Deed', '📝 Arbitration Agreement', '➡️ Assignment Deed', "🧑‍🤝‍🧑 Co-founder's Agreement", '👨‍💼 Consultancy Agreement', '📝 Contract for Services', '©️ Copyright License Agreement', '💰 Debt Settlement Agreement', "👨‍💼 Employee's Offer Letter", '📜 End-User License Agreement (EULA)', '🤝 Escrow Agreement', "🧑‍🤝‍🧑 Founders's Agreement", '👨‍💻 Freelancer Agreement', '🔗 Hypothecation Deed', '💡 Intellectual Property (IP) Assignment Agreement', '👨‍🎓 Internship Agreement', '💰 Loan Agreement', '📝 Memorandum of Understanding (MoU)', '🎵 Music License Agreement', '👍 No Objection Certificate (NOC)', '➗ Partition Deed', '💍 Postnuptial Agreement', '🤝 Release Agreement', '🧾 Rent Receipt', '👋 Resignation Letter', '💰 Share Purchase Agreement', "🤝 Shareholders's Agreement", '💻 Software Development Agreement', '📜 Software License Agreement', '🤝 Sponsorship Agreement', '↩️ Surrender of Tenancy', '📝 Term Sheet', '📜 Terms of Service', '™️ Trademark License Agreement', '🚗 Vehicle Lease Agreement', '🚚 Vendor Agreement', '🔒 Website Privacy Policy', '📜 Website Terms and Conditions'
  ];

  final List<String> _jurisdictions = [
    'Andaman and Nicobar Islands', 'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chandigarh', 'Chhattisgarh', 'Dadra and Nagar Haveli and Daman and Diu', 'Delhi', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jammu and Kashmir', 'Jharkhand', 'Karnataka', 'Kerala', 'Ladakh', 'Lakshadweep', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Puducherry', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
  ];
  final List<String> _languages = ['English', 'Hindi', 'Marathi', 'Bengali', 'Tamil', 'Telugu', 'Gujarati', 'Kannada', 'Malayalam'];


  @override
  void dispose() {
    _partyANameController.dispose();
    _partyBNameController.dispose();
    _additionalDetailsController.dispose();
    _effectiveDateController.dispose();
    _deponentNameController.dispose();
    _deponentAddressController.dispose();
    _statementOfFactsController.dispose();
    _sellerNameController.dispose();
    _buyerNameController.dispose();
    _propertyDescriptionController.dispose();
    _saleAmountController.dispose();
    //... dispose all other controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Lighter background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Document Generator',
          style: GoogleFonts.poppins(
              color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Document Details',
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Document Type'),
                _buildDropdown(_documentTypes, _selectedDocumentType,
                    'Select document type', (val) {
                  setState(() => _selectedDocumentType = val);
                }),
                const SizedBox(height: 20),
                _buildSectionTitle('Language'),
                 _buildDropdown(_languages, _selectedLanguage,
                    'Select language', (val) {
                  setState(() => _selectedLanguage = val);
                }),
                const SizedBox(height: 20),
                ..._buildDynamicFields(),
                _buildSectionTitle('Additional Details'),
                _buildTextField(_additionalDetailsController,
                    'Provide specific terms, conditions, or requirements...',
                    maxLines: 4),
                const SizedBox(height: 20),
                 _buildSectionTitle('Jurisdiction'),
                _buildDropdown(_jurisdictions, _selectedJurisdiction,
                    'Select jurisdiction', (val) {
                  setState(() => _selectedJurisdiction = val);
                }),
                const SizedBox(height: 32),
                _buildGenerateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- DYNAMIC FIELD BUILDER ---
  List<Widget> _buildDynamicFields() {
    // Default fields
    List<Widget> fields = [
      _buildSectionTitle('Party A Name'),
      _buildTextField(_partyANameController, 'Enter name'),
      const SizedBox(height: 20),
      _buildSectionTitle('Party B Name'),
      _buildTextField(_partyBNameController, 'Enter name'),
      const SizedBox(height: 20),
    ];

    switch (_selectedDocumentType) {
      case '⚖️ Affidavit':
        fields = [
          _buildSectionTitle('Deponent Name'),
          _buildTextField(_deponentNameController, 'e.g., John Doe'),
          const SizedBox(height: 20),
          _buildSectionTitle('Deponent Address'),
          _buildTextField(_deponentAddressController, 'e.g., 123 Main St, Anytown'),
          const SizedBox(height: 20),
          _buildSectionTitle('Statement of Facts'),
          _buildTextField(_statementOfFactsController, 'Enter the facts to be affirmed...', maxLines: 5),
          const SizedBox(height: 20),
        ];
        break;
      case '📄 Agreement for Sale':
      case '🏡 Property Sale Agreement':
      case '💰 Sale Deed':
        fields = [
          _buildSectionTitle('Seller Name'),
          _buildTextField(_sellerNameController, 'e.g., Jane Smith'),
          const SizedBox(height: 20),
          _buildSectionTitle('Buyer Name'),
          _buildTextField(_buyerNameController, 'e.g., John Doe'),
          const SizedBox(height: 20),
          _buildSectionTitle('Property Description'),
          _buildTextField(_propertyDescriptionController, 'e.g., Flat No. 101, Building A...'),
          const SizedBox(height: 20),
          _buildSectionTitle('Sale Amount (in INR)'),
          _buildTextField(_saleAmountController, 'e.g., 5000000'),
          const SizedBox(height: 20),
        ];
        break;
       case '🧑‍⚖️ Bail Application':
        fields = [
          _buildSectionTitle('Accused Name'),
          _buildTextField(_accusedNameController, 'e.g., John Doe'),
          const SizedBox(height: 20),
          _buildSectionTitle('FIR No.'),
          _buildTextField(_firNoController, 'e.g., 123/2024'),
          const SizedBox(height: 20),
           _buildSectionTitle('Police Station'),
          _buildTextField(_policeStationController, 'e.g., Connaught Place Police Station'),
          const SizedBox(height: 20),
          _buildSectionTitle('Sections of Law'),
          _buildTextField(_sectionsOfLawController, 'e.g., Section 302 IPC'),
          const SizedBox(height: 20),
        ];
        break;
      case '💸 Cheque Bounce Notice':
         fields = [
          _buildSectionTitle('Sender Name (Payee)'),
          _buildTextField(_noticeSenderNameController, 'e.g., ABC Corp'),
          const SizedBox(height: 20),
          _buildSectionTitle('Recipient Name (Drawer)'),
          _buildTextField(_noticeRecipientNameController, 'e.g., XYZ Pvt Ltd'),
          const SizedBox(height: 20),
          _buildSectionTitle('Cheque No.'),
          _buildTextField(_chequeNoController, 'e.g., 123456'),
          const SizedBox(height: 20),
           _buildSectionTitle('Cheque Date'),
          _buildDateField(controller: _chequeDateController),
          const SizedBox(height: 20),
          _buildSectionTitle('Cheque Amount (in INR)'),
          _buildTextField(_chequeAmountController, 'e.g., 50000'),
          const SizedBox(height: 20),
        ];
        break;
      case '🎁 Gift Deed':
        fields = [
            _buildSectionTitle('Donor Name'),
            _buildTextField(_donorNameController, 'e.g., John Doe'),
            const SizedBox(height: 20),
            _buildSectionTitle('Donee Name'),
            _buildTextField(_doneeNameController, 'e.g., Jane Doe'),
            const SizedBox(height: 20),
            _buildSectionTitle('Details of Gift/Property'),
            _buildTextField(_giftDetailsController, 'e.g., 100 shares of XYZ Ltd. or Property details', maxLines: 3),
            const SizedBox(height: 20),
        ];
        break;
      case '💰 Loan Agreement':
        fields = [
            _buildSectionTitle('Lender Name'),
            _buildTextField(_promisorNameController, 'e.g., ABC Finance'),
            const SizedBox(height: 20),
            _buildSectionTitle('Borrower Name'),
            _buildTextField(_promiseeNameController, 'e.g., John Doe'),
            const SizedBox(height: 20),
            _buildSectionTitle('Principal Loan Amount (in INR)'),
            _buildTextField(_principalAmountController, 'e.g., 100000'),
            const SizedBox(height: 20),
             _buildSectionTitle('Effective Date of Loan'),
            _buildDateField(controller: _effectiveDateController),
            const SizedBox(height: 20),
        ];
        break;
       case '🏠 Rental Agreement':
       case '📄 Lease Agreement':
         fields = [
            _buildSectionTitle('Landlord/Lessor Name'),
            _buildTextField(_landlordNameController, 'e.g., Jane Smith'),
            const SizedBox(height: 20),
            _buildSectionTitle('Tenant/Lessee Name'),
            _buildTextField(_tenantNameController, 'e.g., John Doe'),
            const SizedBox(height: 20),
            _buildSectionTitle('Property Address'),
            _buildTextField(_propertyDescriptionController, 'e.g., 2BHK Flat at...'),
            const SizedBox(height: 20),
             _buildSectionTitle('Monthly Rent (in INR)'),
            _buildTextField(_rentAmountController, 'e.g., 25000'),
            const SizedBox(height: 20),
        ];
        break;
      case '🔒 Website Privacy Policy':
      case '📜 Website Terms and Conditions':
        fields = [
            _buildSectionTitle('Website/App URL'),
            _buildTextField(_websiteUrlController, 'https://example.com'),
            const SizedBox(height: 20),
            _buildSectionTitle('Company/Owner Name'),
            _buildTextField(_companyNameController, 'e.g., Awesome App Inc.'),
            const SizedBox(height: 20),
        ];
        break;
      // Add cases for ALL other document types here...
    }
    return fields;
  }

  // --- UI WIDGET BUILDERS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? value, String hint,
      void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      hint: Text(hint, style: GoogleFonts.poppins(color: Colors.grey.shade500)),
      icon: const Icon(Iconsax.arrow_down_1, color: Colors.black54),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField({TextEditingController? controller}) {
     final dateController = controller ?? _effectiveDateController;
    return TextFormField(
      controller: dateController,
      style: GoogleFonts.poppins(color: Colors.black87),
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'dd-mm-yyyy',
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        suffixIcon: const Icon(Iconsax.calendar_1, color: Colors.black54),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
        ),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          String formattedDate =
              "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
          setState(() {
            dateController.text = formattedDate;
          });
        }
      },
    );
  }

  Widget _buildGenerateButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
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
                  fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8E24AA), // Purple color
            foregroundColor: Colors.white,
            elevation: 5,
            shadowColor: const Color(0xFF8E24AA).withOpacity(0.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
