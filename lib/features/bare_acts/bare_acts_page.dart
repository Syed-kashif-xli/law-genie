import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:ui' as ui;

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
  final FocusNode _searchFocusNode = FocusNode();

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
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      },
    )..load();
  }

  Future<void> _loadInitialData() async {
    // 1. Fetch all acts first to populate cache and derive categories
    _acts = await _bareActService.getAllActs();

    // 2. Get the derived categories
    _categories = _bareActService.getCategories();

    // 3. Update UI
    if (mounted) {
      setState(() {
        _isLoading = false;
        // Re-apply filter in case we were reloading with a selected category
        if (_selectedCategory != 'All' &&
            !_categories.contains(_selectedCategory)) {
          _selectedCategory = 'All'; // Reset if category no longer exists
        }
      });
    }

    if (_selectedCategory != 'All') {
      _filterActs();
    }
  }

  Future<void> _filterActs() async {
    List<BareAct> results;
    final query = _searchController.text.trim();

    if (query.isNotEmpty) {
      // If searching, ignore category filter effectively (Global Search)
      results = await _bareActService.searchActs(query);
    } else {
      results = await _bareActService.getActsByCategory(_selectedCategory);
    }

    if (mounted) {
      setState(() {
        _acts = results;
      });
    }
  }

  Future<void> _checkUsageAndNavigate(BareAct act) async {
    // Check Usage Limits
    final canUse = await UsageLimitHelper.checkAndShowLimit(
      context,
      'bareActs',
      customTitle: 'Bare Acts Limit Reached',
    );
    if (!canUse) return;

    if (!mounted) return;

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
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      resizeToAvoidBottomInset: false, // Prevents resizing when keyboard opens
      body: Stack(
        children: [
          // Ambient Background
          Positioned(
            top: -100,
            right: -100,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6A11CB).withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2575FC).withValues(alpha: 0.15),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildSearchAndFilter(),
                Expanded(child: _buildActsList()),
                if (_isAdLoaded && _bannerAd != null)
                  Container(
                    height: _bannerAd!.size.height.toDouble(),
                    width: _bannerAd!.size.width.toDouble(),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: AdWidget(ad: _bannerAd!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Bare Acts Library',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF19173A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _searchFocusNode.hasFocus
                    ? const Color(0xFF02F1C3)
                    : Colors.white.withValues(alpha: 0.1),
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
              focusNode: _searchFocusNode,
              style: GoogleFonts.poppins(color: Colors.white),
              cursorColor: const Color(0xFF02F1C3),
              decoration: InputDecoration(
                hintText: 'Search statutes, acts...',
                hintStyle: GoogleFonts.poppins(color: Colors.white38),
                prefixIcon:
                    const Icon(Iconsax.search_normal, color: Color(0xFF02F1C3)),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          _filterActs();
                          FocusScope.of(context).unfocus();
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
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      });
                      _filterActs();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : const Color(0xFF19173A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
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
    );
  }

  Widget _buildActsList() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF02F1C3)));
    }

    if (_acts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.search_status,
                  size: 50, color: Colors.white24),
            ),
            const SizedBox(height: 16),
            Text(
              'No Acts Found',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term or category',
              style: GoogleFonts.poppins(color: Colors.white30, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _acts.length,
      itemBuilder: (context, index) {
        final act = _acts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF19173A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _checkUsageAndNavigate(act),
              splashColor: const Color(0xFF6A11CB).withValues(alpha: 0.1),
              highlightColor: const Color(0xFF6A11CB).withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A11CB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Iconsax.document_text,
                        color: Color(0xFF6A11CB), // Purple accent
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            act.title,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (act.year.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    act.year,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Text(
                                  act.category,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF02F1C3),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Iconsax.arrow_right_3,
                      color: Colors.white12,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
