import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../services/bare_act_service.dart';
import 'models/bare_act.dart';
import 'bare_act_viewer_page.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/home/providers/usage_provider.dart';

class BareActsPage extends StatefulWidget {
  const BareActsPage({super.key});

  @override
  State<BareActsPage> createState() => _BareActsPageState();
}

class _BareActsPageState extends State<BareActsPage> {
  final BareActService _bareActService = BareActService();
  final TextEditingController _searchController = TextEditingController();

  List<BareAct> _acts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _categories = _bareActService.getCategories();
    _acts = await _bareActService.getAllActs();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _filterActs() async {
    setState(() => _isLoading = true);

    List<BareAct> results;
    if (_searchController.text.isNotEmpty) {
      results = await _bareActService.searchActs(_searchController.text);
    } else {
      results = await _bareActService.getActsByCategory(_selectedCategory);
    }

    setState(() {
      _acts = results;
      _isLoading = false;
    });
  }

  void _checkUsageAndNavigate(BareAct act) {
    final usageProvider = Provider.of<UsageProvider>(context, listen: false);
    if (usageProvider.bareActsUsage >= usageProvider.bareActsLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Free plan limit reached. Upgrade to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    usageProvider.incrementBareActs();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BareActViewerPage(bareAct: act),
      ),
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
        title: Text(
          'Bare Acts',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1832),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF02F1C3).withValues(alpha: 0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search Acts (e.g., IPC, Contract)...',
                        hintStyle: GoogleFonts.poppins(color: Colors.white30),
                        prefixIcon: const Icon(Iconsax.search_normal,
                            color: Color(0xFF02F1C3)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Colors.white54),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterActs();
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) => _filterActs(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Categories
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              _searchController.clear();
                            });
                            _filterActs();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF02F1C3)
                                      .withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF02F1C3)
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(
                                color: isSelected
                                    ? const Color(0xFF02F1C3)
                                    : Colors.white70,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // List of Acts
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF02F1C3)))
                  : _acts.isEmpty
                      ? Center(
                          child: Text(
                            'No Acts found',
                            style: GoogleFonts.poppins(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _acts.length,
                          itemBuilder: (context, index) {
                            final act = _acts[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1832),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF02F1C3)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Iconsax.document_text,
                                    color: Color(0xFF02F1C3),
                                  ),
                                ),
                                title: Text(
                                  act.title,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${act.category} • ${act.year}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.visibility_rounded,
                                      color: Color(0xFF02F1C3)),
                                  onPressed: () {
                                    _checkUsageAndNavigate(act);
                                  },
                                ),
                                onTap: () {
                                  _checkUsageAndNavigate(act);
                                },
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
