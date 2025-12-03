import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/services/gemini_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/home/providers/usage_provider.dart';

class RiskAnalysisPage extends StatefulWidget {
  const RiskAnalysisPage({super.key});

  @override
  State<RiskAnalysisPage> createState() => _RiskAnalysisPageState();
}

class _RiskAnalysisPageState extends State<RiskAnalysisPage>
    with TickerProviderStateMixin {
  final TextEditingController _caseTitleController = TextEditingController();
  final TextEditingController _partiesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _keyFactController = TextEditingController();
  final GeminiService _geminiService = GeminiService();

  String _selectedCaseType = 'Civil';
  final List<String> _parties = [];
  final List<String> _keyFacts = [];
  final List<String> _attachedFileNames = [];
  final List<String> _evidenceTypes = [];

  final List<String> _caseTypes = [
    'Civil',
    'Criminal',
    'Family',
    'Property',
    'Corporate',
    'Labor',
    'Tax',
    'Constitutional',
    'Other'
  ];

  final List<String> _availableEvidence = [
    'Documents',
    'Witnesses',
    'Physical Evidence',
    'Digital Evidence',
    'Expert Testimony',
    'CCTV Footage',
    'Audio Recording',
    'Photographs'
  ];

  bool _isLoading = false;
  Map<String, dynamic>? _analysisResult;
  late AnimationController _inputAnimationController;

  @override
  void initState() {
    super.initState();
    _inputAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _inputAnimationController.forward();
  }

  @override
  void dispose() {
    _caseTitleController.dispose();
    _partiesController.dispose();
    _descriptionController.dispose();
    _keyFactController.dispose();
    _inputAnimationController.dispose();
    super.dispose();
  }

  void _addParty() {
    if (_partiesController.text.trim().isNotEmpty) {
      setState(() {
        _parties.add(_partiesController.text.trim());
        _partiesController.clear();
      });
    }
  }

  void _addKeyFact() {
    if (_keyFactController.text.trim().isNotEmpty) {
      setState(() {
        _keyFacts.add(_keyFactController.text.trim());
        _keyFactController.clear();
      });
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'png'],
      );

      if (result != null) {
        setState(() {
          _attachedFileNames.addAll(result.files.map((e) => e.name).toList());
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking file: $e")),
        );
      }
    }
  }

  Future<void> _analyzeRisk() async {
    if (_caseTitleController.text.trim().isEmpty &&
        _descriptionController.text.trim().isEmpty &&
        _parties.isEmpty &&
        _keyFacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please provide case details to analyze.")),
      );
      return;
    }

    final usageProvider = Provider.of<UsageProvider>(context, listen: false);
    if (usageProvider.riskAnalysisUsage >= usageProvider.riskAnalysisLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Free plan limit reached. Upgrade to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisResult = null;
    });

    try {
      String caseDetails = """
Case Type: $_selectedCaseType
Case Title: ${_caseTitleController.text}

Parties Involved:
${_parties.isEmpty ? 'Not specified' : _parties.map((p) => '- $p').join('\n')}

Case Description:
${_descriptionController.text}

Key Facts:
${_keyFacts.isEmpty ? 'Not specified' : _keyFacts.map((f) => '- $f').join('\n')}

Evidence Available: ${_evidenceTypes.isEmpty ? 'Not specified' : _evidenceTypes.join(', ')}

Attached Documents: ${_attachedFileNames.isEmpty ? 'None' : _attachedFileNames.join(', ')}
      """;

      final prompt = """
      Analyze the following legal case for risk assessment:
      
      $caseDetails

      Provide a JSON response strictly in this format (no markdown, just raw JSON):
      {
        "win_probability": 75,
        "risk_level": "Medium",
        "estimated_duration": "12-18 Months",
        "estimated_cost": "₹50,000 - ₹1,00,000",
        "major_challenges": ["Challenge 1", "Challenge 2", "Challenge 3"],
        "swot": {
          "strengths": ["Strength 1", "Strength 2"],
          "weaknesses": ["Weakness 1", "Weakness 2"],
          "opportunities": ["Opportunity 1", "Opportunity 2"],
          "threats": ["Threat 1", "Threat 2"]
        },
        "strategy_recommendations": ["Step 1", "Step 2", "Step 3"]
      }
      """;

      final response = await _geminiService.sendMessage(prompt);

      // Robust JSON extraction
      int startIndex = response.indexOf('{');
      int endIndex = response.lastIndexOf('}');

      if (startIndex == -1 || endIndex == -1) {
        throw Exception("AI did not return a valid JSON object.");
      }

      String jsonString = response.substring(startIndex, endIndex + 1);

      setState(() {
        _analysisResult = json.decode(jsonString);
        _isLoading = false;
      });
      usageProvider.incrementRiskAnalysis();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Error: ${e.toString().replaceAll('Exception:', '')}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Risk Analysis",
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _AnimatedSlideIn(
              delay: 0,
              controller: _inputAnimationController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Case Information",
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF02F1C3),
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Provide detailed information for accurate risk assessment",
                    style: GoogleFonts.poppins(
                        color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Case Type Dropdown
            _AnimatedSlideIn(
              delay: 100,
              controller: _inputAnimationController,
              child: _buildInputSection(
                icon: Iconsax.category,
                label: "Case Type",
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A032A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2C55A9)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCaseType,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF0A032A),
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 14),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Color(0xFF02F1C3)),
                      items: _caseTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCaseType = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Case Title
            _AnimatedSlideIn(
              delay: 200,
              controller: _inputAnimationController,
              child: _buildInputSection(
                icon: Iconsax.document_text,
                label: "Case Title",
                child: _buildTextField(
                  controller: _caseTitleController,
                  hint: "e.g., Property Dispute - Ancestral Land",
                  maxLines: 1,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Parties Involved
            _AnimatedSlideIn(
              delay: 300,
              controller: _inputAnimationController,
              child: _buildInputSection(
                icon: Iconsax.people,
                label: "Parties Involved",
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _partiesController,
                            hint: "Add party name (Plaintiff/Defendant)",
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: const Color(0xFF02F1C3),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: _addParty,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12.5),
                              child: const Icon(Icons.add,
                                  color: Color(0xFF0A032A)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_parties.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _parties.map((party) {
                          return Chip(
                            backgroundColor:
                                const Color(0xFF02F1C3).withValues(alpha: 0.2),
                            label: Text(
                              party,
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF02F1C3), fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close,
                                size: 16, color: Color(0xFF02F1C3)),
                            onDeleted: () {
                              setState(() {
                                _parties.remove(party);
                              });
                            },
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Case Description
            _AnimatedSlideIn(
              delay: 400,
              controller: _inputAnimationController,
              child: _buildInputSection(
                icon: Iconsax.note_text,
                label: "Case Description",
                child: _buildTextField(
                  controller: _descriptionController,
                  hint:
                      "Provide detailed description of the case, including background, current status, and any relevant context...",
                  maxLines: 5,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Key Facts
            _AnimatedSlideIn(
              delay: 500,
              controller: _inputAnimationController,
              child: _buildInputSection(
                icon: Iconsax.clipboard_tick,
                label: "Key Facts",
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _keyFactController,
                            hint: "Add important fact or evidence",
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: const Color(0xFF02F1C3),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: _addKeyFact,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12.5),
                              child: const Icon(Icons.add,
                                  color: Color(0xFF0A032A)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_keyFacts.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ...List.generate(_keyFacts.length, (index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A032A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF2C55A9)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF02F1C3)
                                      .withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFF02F1C3),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _keyFacts[index],
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    size: 18, color: Colors.white54),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    _keyFacts.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Evidence Available
            _AnimatedSlideIn(
              delay: 600,
              controller: _inputAnimationController,
              child: _buildInputSection(
                icon: Iconsax.folder_open,
                label: "Evidence Available",
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableEvidence.map((evidence) {
                    final isSelected = _evidenceTypes.contains(evidence);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(evidence),
                      labelStyle: GoogleFonts.poppins(
                        color:
                            isSelected ? const Color(0xFF0A032A) : Colors.white,
                        fontSize: 12,
                      ),
                      backgroundColor: const Color(0xFF0A032A),
                      selectedColor: const Color(0xFF02F1C3),
                      checkmarkColor: const Color(0xFF0A032A),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF02F1C3)
                            : const Color(0xFF2C55A9),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _evidenceTypes.add(evidence);
                          } else {
                            _evidenceTypes.remove(evidence);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Document Upload
            _AnimatedSlideIn(
              delay: 700,
              controller: _inputAnimationController,
              child: _buildInputSection(
                icon: Iconsax.document_upload,
                label: "Supporting Documents",
                child: Column(
                  children: [
                    InkWell(
                      onTap: _pickDocument,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A032A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF2C55A9),
                              width: 1.0,
                              style: BorderStyle.solid),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.document_upload,
                                color: Color(0xFF02F1C3)),
                            const SizedBox(width: 10),
                            Text(
                              "Upload Documents",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF02F1C3),
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_attachedFileNames.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _attachedFileNames.map((fileName) {
                          return Chip(
                            backgroundColor: const Color(0xFF02F1C3),
                            label: Text(
                              fileName,
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                            deleteIcon: const Icon(Icons.close,
                                size: 16, color: Colors.black54),
                            onDeleted: () {
                              setState(() {
                                _attachedFileNames.remove(fileName);
                              });
                            },
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Analyze Button
            _AnimatedSlideIn(
              delay: 800,
              controller: _inputAnimationController,
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _analyzeRisk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02F1C3),
                    foregroundColor: const Color(0xFF0A032A),
                    disabledBackgroundColor: Colors.white24,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: const Color(0xFF02F1C3).withValues(alpha: 0.4),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.magic_star,
                                size: 24, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              "Analyze Risk",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Results Section
            if (_analysisResult != null) ...[
              _buildDashboard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF02F1C3), size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlignVertical:
          maxLines > 1 ? TextAlignVertical.top : TextAlignVertical.center,
      style: GoogleFonts.poppins(
          color: Colors.white, fontSize: 14, height: maxLines > 1 ? 1.5 : 1.2),
      cursorColor: const Color(0xFF02F1C3),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF0A032A),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Widget _buildDashboard() {
    // Safe extraction of Win Probability
    int winProb = 0;
    try {
      var val = _analysisResult?['win_probability'];
      if (val is int) {
        winProb = val;
      } else if (val is double) {
        winProb = val.toInt();
      } else if (val is String) {
        winProb = int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }
    } catch (e) {
      winProb = 0;
    }

    // Safe extraction of Risk Level
    String riskLevel = _analysisResult?['risk_level']?.toString() ?? "Unknown";

    Color riskColor = const Color(0xFF00C853);
    if (riskLevel.toLowerCase().contains('high')) {
      riskColor = const Color(0xFFFF3D00);
    } else if (riskLevel.toLowerCase().contains('medium')) {
      riskColor = const Color(0xFFFFD600);
    }

    // Safe extraction of Lists
    List<dynamic> challenges =
        (_analysisResult?['major_challenges'] as List?) ?? [];
    List<dynamic> strategy =
        (_analysisResult?['strategy_recommendations'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FadeInUp(
          delay: 0,
          child: Text(
            "Analysis Results",
            style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 15),

        // Win Probability & Risk Row
        Row(
          children: [
            Expanded(
              child: _FadeInUp(
                delay: 100,
                child: _buildResultCard(
                  title: "Win Chance",
                  content: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: winProb / 100),
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeOutQuart,
                          builder: (context, value, _) =>
                              CircularProgressIndicator(
                            value: value,
                            color: const Color(0xFF02F1C3),
                            backgroundColor: Colors.white10,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      ),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: winProb),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeOutQuart,
                        builder: (context, value, _) => Text(
                          "$value%",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _FadeInUp(
                delay: 200,
                child: _buildResultCard(
                  title: "Risk Level",
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: riskColor, size: 40),
                      const SizedBox(height: 5),
                      Flexible(
                        child: Text(
                          riskLevel,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: riskColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  borderColor: riskColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Estimates
        _FadeInUp(
          delay: 300,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF19173A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildEstimateItem(
                      Iconsax.clock,
                      "Duration",
                      _analysisResult?['estimated_duration']?.toString() ??
                          "N/A"),
                ),
                Container(width: 1, height: 40, color: Colors.white10),
                Expanded(
                  child: _buildEstimateItem(Iconsax.money, "Est. Cost",
                      _analysisResult?['estimated_cost']?.toString() ?? "N/A"),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 25),

        // Challenges
        if (challenges.isNotEmpty) ...[
          _FadeInUp(
            delay: 400,
            child: _buildSectionHeader("Major Challenges", Iconsax.danger),
          ),
          ...challenges.asMap().entries.map((entry) => _FadeInUp(
                delay: 500 + (entry.key * 100),
                child:
                    _buildBulletPoint(entry.value.toString(), Colors.redAccent),
              )),
          const SizedBox(height: 25),
        ],

        // SWOT
        _FadeInUp(
          delay: 700,
          child: _buildSectionHeader("SWOT Analysis", Iconsax.chart_2),
        ),
        _FadeInUp(delay: 800, child: _buildSwotGrid()),

        const SizedBox(height: 25),

        // Strategy
        if (strategy.isNotEmpty) ...[
          _FadeInUp(
            delay: 900,
            child: _buildSectionHeader(
                "Strategic Recommendations", Iconsax.lamp_on),
          ),
          ...strategy.asMap().entries.map((entry) => _FadeInUp(
                delay: 1000 + (entry.key * 100),
                child: _buildBulletPoint(
                    entry.value.toString(), const Color(0xFF02F1C3)),
              )),
          const SizedBox(height: 40),
        ],
      ],
    );
  }

  Widget _buildResultCard(
      {required String title, required Widget content, Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF19173A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14)),
          const Spacer(),
          content,
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildEstimateItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(label,
            style: GoogleFonts.poppins(color: Colors.white30, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF02F1C3), size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                  color: const Color(0xFF02F1C3),
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color bulletColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: CircleAvatar(radius: 4, backgroundColor: bulletColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(color: Colors.white70, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwotGrid() {
    final swot = _analysisResult?['swot'] ?? {};
    return Column(
      children: [
        Row(
          children: [
            _buildSwotCard("Strengths", swot['strengths'] as List? ?? [],
                Colors.green, Iconsax.like_1),
            const SizedBox(width: 10),
            _buildSwotCard("Weaknesses", swot['weaknesses'] as List? ?? [],
                Colors.orange, Iconsax.dislike),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildSwotCard(
                "Opportunities",
                swot['opportunities'] as List? ?? [],
                Colors.blue,
                Iconsax.trend_up),
            const SizedBox(width: 10),
            _buildSwotCard("Threats", swot['threats'] as List? ?? [],
                Colors.red, Iconsax.danger),
          ],
        ),
      ],
    );
  }

  Widget _buildSwotCard(
      String title, List<dynamic> items, Color color, IconData icon) {
    return Expanded(
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(title,
                      style: GoogleFonts.poppins(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No data',
                        style: GoogleFonts.poppins(
                            color: Colors.white30, fontSize: 11),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("• ", style: TextStyle(color: color)),
                              Expanded(
                                child: Text(
                                  "${items[index]}",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white70, fontSize: 11),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animation Widgets
class _AnimatedSlideIn extends StatelessWidget {
  final Widget child;
  final int delay;
  final AnimationController controller;

  const _AnimatedSlideIn({
    required this.child,
    required this.delay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final animation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay / 1000,
        (delay + 300) / 1000,
        curve: Curves.easeOutCubic,
      ),
    ));

    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay / 1000,
        (delay + 300) / 1000,
        curve: Curves.easeOut,
      ),
    ));

    return SlideTransition(
      position: animation,
      child: FadeTransition(
        opacity: opacityAnimation,
        child: child,
      ),
    );
  }
}

class _FadeInUp extends StatefulWidget {
  final Widget child;
  final int delay;

  const _FadeInUp({required this.child, required this.delay});

  @override
  State<_FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<_FadeInUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _opacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _translate = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _translate,
        child: widget.child,
      ),
    );
  }
}
