import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/case_finder_service.dart';
import 'models/legal_case.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/home/providers/usage_provider.dart';
import 'widgets/case_card.dart';

class CaseFinderPage extends StatefulWidget {
  const CaseFinderPage({super.key});

  @override
  State<CaseFinderPage> createState() => _CaseFinderPageState();
}

class _CaseFinderPageState extends State<CaseFinderPage>
    with SingleTickerProviderStateMixin {
  final CaseFinderService _caseFinderService = CaseFinderService();
  final TextEditingController _searchController = TextEditingController();

  List<LegalCase> _cases = [];
  bool _isLoading = false;
  String _selectedCourt = 'All Courts';
  String? _selectedCategory;
  int? _selectedYear;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecentJudgments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentJudgments() async {
    setState(() => _isLoading = true);
    final cases = await _caseFinderService.getRecentJudgments(
      court: _selectedCourt == 'All Courts' ? null : _selectedCourt,
    );
    setState(() {
      _cases = cases;
      _isLoading = false;
    });
  }

  Future<void> _searchCases() async {
    if (_searchController.text.trim().isEmpty && _selectedYear == null) {
      _loadRecentJudgments();
      _loadRecentJudgments();
      return;
    }

    final usageProvider = Provider.of<UsageProvider>(context, listen: false);
    if (usageProvider.casesUsage >= usageProvider.casesLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Free plan limit reached. Upgrade to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final cases = await _caseFinderService.searchCases(
      _searchController.text.isEmpty ? 'judgment' : _searchController.text,
      fromYear: _selectedYear,
      toYear: _selectedYear,
    );
    setState(() {
      _cases = cases;
      _cases = cases;
      _isLoading = false;
    });
    usageProvider.incrementCases();
  }

  Future<void> _filterByCategory(String category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });
    final cases = await _caseFinderService.getCasesByCategory(category);
    setState(() {
      _cases = cases;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Case Finder',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            Tab(text: 'Search'),
            Tab(text: 'Browse'),
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
            _buildSearchTab(),
            _buildBrowseTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildCourtFilter()),
                  const SizedBox(width: 12),
                  _buildYearFilter(),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF02F1C3),
                  ),
                )
              : _cases.isEmpty
                  ? _buildEmptyState()
                  : _buildCasesList(),
        ),
      ],
    );
  }

  Widget _buildBrowseTab() {
    final categories = _caseFinderService.getCategories();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse by Category',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...categories.map((category) => _buildCategoryCard(category)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1832),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF02F1C3).withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: 'Search cases, keywords...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.white30,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Iconsax.search_normal,
            color: Color(0xFF02F1C3),
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    _loadRecentJudgments();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onSubmitted: (_) => _searchCases(),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildCourtFilter() {
    final courts = _caseFinderService.getAvailableCourts();

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courts.length,
        itemBuilder: (context, index) {
          final court = courts[index];
          final isSelected = court == _selectedCourt;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCourt = court);
              _loadRecentJudgments();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF02F1C3).withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF02F1C3)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Center(
                child: Text(
                  court == 'All Courts' ? 'All' : court.split(' ')[0],
                  style: GoogleFonts.poppins(
                    color:
                        isSelected ? const Color(0xFF02F1C3) : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildYearFilter() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _selectedYear != null
            ? const Color(0xFF02F1C3).withOpacity(0.15)
            : const Color(0xFF1A1832),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedYear != null
              ? const Color(0xFF02F1C3)
              : const Color(0xFF02F1C3).withOpacity(0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedYear,
          hint: Row(
            children: [
              Icon(Iconsax.calendar_1, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'Year',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          dropdownColor: const Color(0xFF1A1832),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white54, size: 16),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          onChanged: (int? newValue) {
            setState(() {
              _selectedYear = newValue;
            });
            _searchCases();
          },
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('All Years'),
            ),
            ...List.generate(75, (index) {
              final year = DateTime.now().year - index;
              return DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCasesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _cases.length,
      itemBuilder: (context, index) {
        return CaseCard(
          legalCase: _cases[index],
          onTap: () => _showCaseDetails(_cases[index]),
        );
      },
    );
  }

  Widget _buildCategoryCard(String category) {
    return GestureDetector(
      onTap: () {
        _filterByCategory(category);
        _tabController.animateTo(0);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1832),
              const Color(0xFF151028),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF02F1C3).withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF02F1C3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Iconsax.book,
                color: Color(0xFF02F1C3),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF02F1C3).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.search_normal,
              size: 48,
              color: Color(0xFF02F1C3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No cases found',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showCaseDetails(LegalCase legalCase) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1832), Color(0xFF0A032A)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF02F1C3).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            legalCase.court,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF02F1C3),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          legalCase.formattedDate,
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      legalCase.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      legalCase.caseNumber,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF02F1C3),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (legalCase.judgeName != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.gavel_rounded,
                            size: 16,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            legalCase.judgeName!,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (legalCase.summary != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Summary',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF02F1C3),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        legalCase.summary!,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],
                    if (legalCase.url != null) ...[
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final Uri url = Uri.parse(legalCase.url!);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.download_rounded, size: 20),
                          label: Text(
                            'Download PDF Judgment',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
