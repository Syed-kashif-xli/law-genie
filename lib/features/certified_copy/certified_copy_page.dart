import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'certified_copy_review_page.dart';

class CertifiedRegistryCopyPage extends StatefulWidget {
  final bool isDigitalCopy;

  const CertifiedRegistryCopyPage({
    super.key,
    this.isDigitalCopy = false,
  });

  @override
  State<CertifiedRegistryCopyPage> createState() =>
      _CertifiedRegistryCopyPageState();
}

class _CertifiedRegistryCopyPageState extends State<CertifiedRegistryCopyPage> {
  final _formKey = GlobalKey<FormState>();

  // 1. District
  String? _selectedDistrict;
  final List<String> _districts = [
    'Agar Malwa',
    'Alirajpur',
    'Anuppur',
    'Ashok Nagar',
    'Balaghat',
    'Barwani',
    'Betul',
    'Bhind',
    'Bhopal',
    'Burhanpur',
    'Chhatarpur',
    'Chhindwara',
    'Damoh',
    'Datia',
    'Dewas',
    'Dhar',
    'Dindori',
    'Guna',
    'Gwalior',
    'Harda',
    'Indore',
    'Jabalpur',
    'Jhabua',
    'Katni',
    'Khandwa',
    'Khargone',
    'Mandla',
    'Mandsaur',
    'Morena',
    'Narmadapuram (Hoshangabad)',
    'Narsinghpur',
    'Neemuch',
    'Niwari',
    'Panna',
    'Raisen',
    'Rajgarh',
    'Ratlam',
    'Rewa',
    'Sagar',
    'Satna',
    'Sehore',
    'Seoni',
    'Shahdol',
    'Shajapur',
    'Sheopur',
    'Shivpuri',
    'Sidhi',
    'Singrauli',
    'Tikamgarh',
    'Ujjain',
    'Umaria',
    'Vidisha',
  ];

  // 2. Date Range
  String _selectedDateOption = 'Current Financial Year';
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;

  // 3. Deed Type
  String? _selectedDeedType;
  final List<String> _deedTypes = [
    'Acknowledgement of debt',
    'Acknowledgement of receipt of payment',
    'Administration Bond',
    'Affidavit',
    'Agreement or Memorandum of an agreement',
    'Agreement relating to Deposit of Title Deed/pawn/pledge or hypothecation',
    'Agreement/Memorandum of an agreement',
    'Amendment Deed/Correction Deed',
    'Appointment in execution of a power',
    'Appraisement or valuation',
    'Apprenticeship deed',
    'Articles of Association of a Company',
    'Authority to adopt',
    'Award',
    'Award without Property',
    'Bank Guarantee',
    'Bond',
    'Bottomry Bond',
    'Cancellation deed',
    'Certificate of Enrolment',
    'Certificate of Practice as Notary',
    'Certificate of Sale',
    'Certificate or other document',
    'Charter Party',
    'Clearance List',
    'Composition Deed',
    'Consent Deed',
    'Conveyance',
    'Copy or Extract',
    'Counterpart or Duplicate',
    'Customs Bond or Excise Bond',
    'Declaration under Madhya Pradesh Prakoshtha Swamitva Adhiniyam, 2000',
    'Delivery Order in Respect of goods',
    'Divorce',
    'Entry of Certificate of marriage',
    'Exchange Deed',
    'Further Charge',
    'Gift',
    'Indemnity Bond',
    'Lease Deed',
    'Letter of Allotment of Shares',
    'Letter of Guarantee',
    'Letter of License',
    'License relating to Arms or Ammunitions (Arms Act, 1959)',
    'Memorandum of company',
    'Mortgage',
    'Mortgage of a Crop',
    'Notarial Act',
    'Note of Protest',
    'Note or Memorandum',
    'Partition',
    'Partnership',
    'Protest of Bill or Note',
    'Re-conveyance of mortgage property',
    'Release',
    'Respondentia Bond',
    'Security Bond Not Mortgage Deed',
    'Settlement',
    'Share Warrant',
    'Shipping Order',
    'Surrender of Lease',
    'Transfer',
    'Transfer of Lease',
    'Trust',
    'Warrant for Goods',
  ];

  // 5. Party Details
  String? _partyType;
  final TextEditingController _partyNameEngController = TextEditingController();
  final TextEditingController _partyNameHindiController =
      TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  // 6. Property Details
  String? _propertyType;
  final TextEditingController _propertyAddressEngController =
      TextEditingController();
  final TextEditingController _propertyAddressHindiController =
      TextEditingController();
  final TextEditingController _propertyIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateDateRange(_selectedDateOption);
  }

  void _updateDateRange(String option) {
    DateTime now = DateTime.now();
    DateTime start;
    DateTime end = now;

    int currentYear = now.year;
    // Financial year starts April 1st
    DateTime fyStart = DateTime(currentYear, 4, 1);
    if (now.isBefore(fyStart)) {
      currentYear--;
      fyStart = DateTime(currentYear, 4, 1);
    }

    switch (option) {
      case 'Current Financial Year':
        start = fyStart;
        break;
      case 'Last Financial Year':
        start = DateTime(currentYear - 1, 4, 1);
        end = DateTime(currentYear, 3, 31);
        break;
      case 'Last 3 Financial Years':
        start = DateTime(currentYear - 3, 4, 1);
        break;
      case 'Last 5 Financial Years':
        start = DateTime(currentYear - 5, 4, 1);
        break;
      case 'Custom Date':
        // Don't auto-fill, keep existing or clear if needed
        return;
      default:
        start = fyStart;
    }

    setState(() {
      _fromDate = start;
      _toDate = end;
      _fromDateController.text = DateFormat('dd-MM-yyyy').format(start);
      _toDateController.text = DateFormat('dd-MM-yyyy').format(end);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isFrom ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now()),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF02F1C3),
              onPrimary: Colors.black,
              surface: Color(0xFF19173A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF19173A),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          _fromDateController.text = DateFormat('dd-MM-yyyy').format(picked);
        } else {
          _toDate = picked;
          _toDateController.text = DateFormat('dd-MM-yyyy').format(picked);
        }
        _selectedDateOption = 'Custom Date';
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CertifiedCopyReviewPage(
            district: _selectedDistrict!,
            dateOption: _selectedDateOption,
            fromDate: _fromDateController.text,
            toDate: _toDateController.text,
            deedType: _selectedDeedType,
            searchByParty: true,
            partyType: _partyType,
            partyNameEng: _partyNameEngController.text,
            partyNameHindi: _partyNameHindiController.text,
            mobileNumber: _mobileNumberController.text,
            searchByProperty: true,
            propertyType: _propertyType,
            propertyAddressEng: _propertyAddressEngController.text,
            propertyAddressHindi: _propertyAddressHindiController.text,
            propertyId: _propertyIdController.text,
            isDigitalCopy: widget.isDigitalCopy,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          widget.isDigitalCopy
              ? 'Certified Digital Copy'
              : 'Certified Registry Copy',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A032A),
              Color(0xFF1A0B4E),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF02F1C3).withOpacity(0.2),
                          const Color(0xFF02F1C3).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF02F1C3).withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF02F1C3).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF02F1C3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Iconsax.location,
                              color: Colors.black, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected State',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Madhya Pradesh',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionContainer(
                    title: 'District Details',
                    icon: Iconsax.map_1,
                    child: _buildDropdown(
                      label: 'District',
                      hint: 'Select District',
                      value: _selectedDistrict,
                      items: _districts,
                      onChanged: (val) =>
                          setState(() => _selectedDistrict = val),
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionContainer(
                    title: 'Date Range',
                    icon: Iconsax.calendar_1,
                    child: _buildDateRangeSection(),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionContainer(
                    title: 'Deed Information',
                    icon: Iconsax.document_text,
                    child: _buildDropdown(
                      label: 'Deed Type',
                      hint: 'Select Deed Type',
                      value: _selectedDeedType,
                      items: _deedTypes,
                      onChanged: (val) =>
                          setState(() => _selectedDeedType = val),
                      isRequired: false,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionContainer(
                    title: 'Party Details',
                    icon: Iconsax.user,
                    child: _buildPartyDetailsForm(),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionContainer(
                    title: 'Property Details',
                    icon: Iconsax.building,
                    child: _buildPropertyDetailsForm(),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF02F1C3).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF02F1C3),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.search_normal, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Search Records',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF02F1C3), size: 22),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A0B4E),
          style: GoogleFonts.poppins(color: Colors.white),
          icon: const Icon(Iconsax.arrow_down_1,
              color: Color(0xFF02F1C3), size: 20),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.white30),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFF02F1C3), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (val) => val == null ? 'Please select $label' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            'Current Financial Year',
            'Last Financial Year',
            'Last 3 Financial Years',
            'Last 5 Financial Years',
            'Custom Date'
          ].map((option) {
            final isSelected = _selectedDateOption == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDateOption = option;
                    _updateDateRange(option);
                  });
                }
              },
              backgroundColor: Colors.black.withOpacity(0.2),
              selectedColor: const Color(0xFF02F1C3).withOpacity(0.15),
              labelStyle: GoogleFonts.poppins(
                color: isSelected ? const Color(0xFF02F1C3) : Colors.white60,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF02F1C3)
                      : Colors.white.withOpacity(0.05),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                'From Date',
                _fromDateController,
                () => _selectDate(context, true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                'To Date',
                _toDateController,
                () => _selectDate(context, false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
      String label, TextEditingController controller, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500),
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'dd-mm-yyyy',
            hintStyle: GoogleFonts.poppins(color: Colors.white30),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            suffixIcon: const Icon(Iconsax.calendar_1,
                color: Color(0xFF02F1C3), size: 20),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFF02F1C3), width: 1.5),
            ),
          ),
          validator: (val) => val!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildPartyDetailsForm() {
    return Column(
      children: [
        const Divider(color: Colors.white10, height: 32),
        _buildDropdown(
          label: 'Party Type',
          hint: 'Select Party Type',
          value: _partyType,
          items: ['Individual', 'Organization', 'Government'],
          onChanged: (val) => setState(() => _partyType = val),
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Party Name (English)',
          hint: 'Enter party name in English',
          controller: _partyNameEngController,
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Party Name (Hindi)',
          hint: 'Enter party name in Hindi',
          controller: _partyNameHindiController,
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Mobile Number',
          hint: 'Jis par registry ho (Optional)',
          controller: _mobileNumberController,
          isRequired: false,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildPropertyDetailsForm() {
    return Column(
      children: [
        const Divider(color: Colors.white10, height: 32),
        _buildDropdown(
          label: 'Property Type',
          hint: 'Select Property Type',
          value: _propertyType,
          items: [
            'Plot',
            'Building',
            'Agricultural Land',
          ],
          onChanged: (val) => setState(() => _propertyType = val),
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Property Address (English)',
          hint: 'Colony | Building | Block | Plot | Flat',
          controller: _propertyAddressEngController,
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Property Address (Hindi)',
          hint: 'Colony | Building | Block | Plot | Flat',
          controller: _propertyAddressHindiController,
          isRequired: false,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Property ID (Optional)',
          hint: 'Enter Property ID',
          controller: _propertyIdController,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.white30),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFF02F1C3), width: 1.5),
            ),
          ),
          validator:
              isRequired ? (val) => val!.isEmpty ? 'Required' : null : null,
        ),
      ],
    );
  }
}
