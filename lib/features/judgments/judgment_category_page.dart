import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/judgment_provider.dart';
import 'package:myapp/models/judgment_model.dart';
import 'package:myapp/features/judgments/judgment_list_page.dart';

class JudgmentCategoryPage extends StatefulWidget {
  const JudgmentCategoryPage({super.key});

  @override
  State<JudgmentCategoryPage> createState() => _JudgmentCategoryPageState();
}

class _JudgmentCategoryPageState extends State<JudgmentCategoryPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<JudgmentProvider>().loadCategories();
      }
    });
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JudgmentListPage(query: query),
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
        title: Text(
          'Browse Judgments',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A032A), Color(0xFF19173A), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search judgments (e.g. Right to Privacy)',
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.white54, fontSize: 14),
                      prefixIcon: const Icon(Iconsax.search_normal,
                          color: Colors.white54),
                      suffixIcon: IconButton(
                        icon: const Icon(Iconsax.arrow_right_1,
                            color: Color(0xFF02F1C3)),
                        onPressed: _onSearch,
                      ),
                      border: InputBorder.none,
                      filled: false,
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
              ),

              // Categories Grid
              Expanded(
                child: Consumer<JudgmentProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF02F1C3)));
                    }

                    if (provider.errorMessage != null &&
                        provider.categories.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.danger,
                                color: Colors.redAccent, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              provider.errorMessage!,
                              style: GoogleFonts.poppins(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => provider.loadCategories(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: provider.categories.length,
                      itemBuilder: (context, index) {
                        final category = provider.categories[index];
                        return _buildCategoryCard(context, category);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, JudgmentCategory category) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JudgmentListPage(category: category),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF02F1C3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Iconsax.judge, color: Color(0xFF02F1C3), size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
