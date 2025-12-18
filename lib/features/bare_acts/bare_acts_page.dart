import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../services/bare_act_service.dart';
import '../../services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'models/bare_act.dart';
import 'bare_act_viewer_page.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/home/providers/usage_provider.dart';
import '../../utils/usage_limit_helper.dart';

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

  // Ad State
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _bannerAd = AdService.createBannerAd(
      onAdLoaded: (ad) {
        setState(() {
          _isAdLoaded = true;
        });
      },
    )..load();
  }

  Future<void> _loadInitialData() async {
    // 1. Fetch all acts first to populate cache and derive categories
    _acts = await _bareActService.getAllActs();

    // 2. Get the derived categories
    _categories = _bareActService.getCategories();

    // 3. Update UI
    setState(() {
      _isLoading = false;
      // Re-apply filter in case we were reloading with a selected category
      if (_selectedCategory != 'All' &&
          !_categories.contains(_selectedCategory)) {
        _selectedCategory = 'All'; // Reset if category no longer exists
      }
    });

    if (_selectedCategory != 'All') {
      _filterActs();
    }
  }

  Future<void> _filterActs() async {
    // No set state loading here for instant feel if cached,
    // but if we were strictly async we would.
    // Since service uses cache, we can just await and set state.

    List<BareAct> results;
    if (_searchController.text.isNotEmpty) {
      results = await _bareActService.searchActs(_searchController.text);
    } else {
      results = await _bareActService.getActsByCategory(_selectedCategory);
    }

    setState(() {
      _acts = results;
    });
  }

  Future<void> _checkUsageAndNavigate(BareAct act) async {
    // Check Usage Limits
    final canUse = await UsageLimitHelper.checkAndShowLimit(
      context,
      'bareActs',
      customTitle: 'Bare Acts Limit Reached',
    );
    if (!canUse) return;

    final usageProvider = Provider.of<UsageProvider>(context, listen: false);

    usageProvider.incrementBareActs();

    // Resolve URL before navigating
    _resolveAndNavigate(act);
  }

  Future<void> _resolveAndNavigate(BareAct act) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF02F1C3))),
    );

    // Fetch URL
    final String resolvedUrl = await _bareActService.resolvePdfUrl(act);

    // Pop loading
    if (mounted) Navigator.pop(context);

    if (resolvedUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not load PDF. Please try again.')),
        );
      }
      return;
    }

    // Create a temporary BareAct with the resolved URL for the viewer
    final resolvedAct = BareAct(
      id: act.id,
      title: act.title,
      category: act.category,
      pdfUrl: resolvedUrl, // Use the actual http URL
      year: act.year,
    );

    if (mounted) {
      _navigateToViewer(resolvedAct);
    }
  }

  void _navigateToViewer(BareAct act) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BareActViewerPage(bareAct: act),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A032A),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bare Acts',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1832),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF2C55A9).withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search laws, acts, years...',
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
                  const SizedBox(height: 20),
                  // Categories
                  if (_categories.isNotEmpty)
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategory == category;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                                _searchController.clear();
                              });
                              _filterActs();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF02F1C3)
                                    : const Color(0xFF1A1832),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF02F1C3)
                                      : Colors.white.withValues(alpha: 0.1),
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF02F1C3)
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: GoogleFonts.poppins(
                                    color: isSelected
                                        ? const Color(0xFF0A032A)
                                        : Colors.white70,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Iconsax.document_text,
                                  size: 60, color: Colors.white10),
                              const SizedBox(height: 16),
                              Text(
                                'No Acts Found',
                                style: GoogleFonts.poppins(
                                    color: Colors.white54, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: _acts.length,
                          itemBuilder: (context, index) {
                            final act = _acts[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1832)
                                    .withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF2C55A9)
                                      .withValues(alpha: 0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => _checkUsageAndNavigate(act),
                                  splashColor: const Color(0xFF02F1C3)
                                      .withValues(alpha: 0.1),
                                  highlightColor: const Color(0xFF02F1C3)
                                      .withValues(alpha: 0.05),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                const Color(0xFF02F1C3)
                                                    .withValues(alpha: 0.15),
                                                const Color(0xFF2C55A9)
                                                    .withValues(alpha: 0.15),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color: const Color(0xFF02F1C3)
                                                    .withValues(alpha: 0.2)),
                                          ),
                                          child: const Icon(
                                            Iconsax.document_text,
                                            color: Color(0xFF02F1C3),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                act.title,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  height: 1.3,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.05),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      act.category,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: const Color(
                                                            0xFF02F1C3),
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '•  ${act.year}',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white54,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Iconsax.arrow_right_3,
                                          color: Colors.white30,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            if (_isAdLoaded && _bannerAd != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
