import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/judgment_model.dart';
import 'package:myapp/providers/judgment_provider.dart';
import 'package:myapp/features/judgments/judgment_detail_page.dart';

class JudgmentListPage extends StatefulWidget {
  final String? query;
  final JudgmentCategory? category;

  const JudgmentListPage({super.key, this.query, this.category});

  @override
  State<JudgmentListPage> createState() => _JudgmentListPageState();
}

class _JudgmentListPageState extends State<JudgmentListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      if (!mounted) return;
      final provider = context.read<JudgmentProvider>();
      if (widget.query != null) {
        provider.searchJudgments(context, widget.query!);
      } else if (widget.category != null) {
        provider.searchJudgments(context, widget.category!.name);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final provider = context.read<JudgmentProvider>();

      // Load more when 80% through the list or within 500px of bottom
      if (currentScroll >= maxScroll - 500 &&
          !provider.isMoreLoading &&
          provider.hasMore) {
        debugPrint('JudgmentListPage: Triggering load more...');
        provider.loadMoreJudgments();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.query != null
        ? 'Results for "${widget.query}"'
        : widget.category?.name ?? 'Judgments';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<JudgmentProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF02F1C3)));
              }

              if (provider.errorMessage != null &&
                  provider.searchResults.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.search_status,
                            color: Color(0xFF02F1C3), size: 80),
                        const SizedBox(height: 24),
                        Text(
                          provider.errorMessage!,
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (widget.query != null) {
                              provider.searchJudgments(context, widget.query!);
                            } else if (widget.category != null) {
                              provider.searchJudgments(
                                  context, widget.category!.name);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF02F1C3),
                            foregroundColor: const Color(0xFF0A032A),
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount:
                    provider.searchResults.length + (provider.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < provider.searchResults.length) {
                    final judgment = provider.searchResults[index];
                    return _PremiumJudgmentCard(judgment: judgment);
                  } else {
                    return _buildLoadingIndicator();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Color(0xFF02F1C3),
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _PremiumJudgmentCard extends StatelessWidget {
  final Judgment judgment;

  const _PremiumJudgmentCard({required this.judgment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        JudgmentDetailPage(judgment: judgment),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF02F1C3).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Iconsax.document_text,
                              color: Color(0xFF02F1C3), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                judgment.title,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  height: 1.3,
                                ),
                              ),
                              if (judgment.date != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Iconsax.calendar_1,
                                        color: Colors.white38, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      judgment.date!,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white38,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (judgment.snippet != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        judgment.snippet!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<JudgmentProvider>(
                          builder: (context, provider, child) {
                            final isThisDownloading = provider.isDownloading &&
                                provider.selectedJudgment?.id == judgment.id;

                            return InkWell(
                              onTap: provider.isDownloading
                                  ? null
                                  : () => provider.downloadJudgment(judgment),
                              child: Row(
                                children: [
                                  if (isThisDownloading)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF02F1C3),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    const Icon(Iconsax.document_download,
                                        color: Color(0xFF02F1C3), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    isThisDownloading
                                        ? 'Processing...'
                                        : 'Download Copy',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF02F1C3),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Icon(Iconsax.arrow_right_3,
                            color: Colors.white24, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
