import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/judgment_model.dart';
import 'package:myapp/providers/judgment_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';

class JudgmentDetailPage extends StatefulWidget {
  final Judgment judgment;

  const JudgmentDetailPage({super.key, required this.judgment});

  @override
  State<JudgmentDetailPage> createState() => _JudgmentDetailPageState();
}

class _JudgmentDetailPageState extends State<JudgmentDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context
            .read<JudgmentProvider>()
            .fetchJudgmentDetail(widget.judgment.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          Consumer<JudgmentProvider>(
            builder: (context, provider, child) {
              final judgment = provider.selectedJudgment;
              return IconButton(
                icon: provider.isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Color(0xFF02F1C3),
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Iconsax.document_download,
                        color: Color(0xFF02F1C3)),
                tooltip:
                    provider.isDownloading ? 'Generating...' : 'Download PDF',
                onPressed: () {
                  if (judgment != null && !provider.isDownloading) {
                    provider.downloadJudgment(judgment);
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.export, color: Colors.white),
            onPressed: () {
              if (widget.judgment.url != null) {
                Share.share(
                    'Read this judgment on Law Genie: ${widget.judgment.title}\n\n${widget.judgment.url!}');
              }
            },
          ),
        ],
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

              final judgment = provider.selectedJudgment;
              if (judgment == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.danger,
                            color: Colors.redAccent, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          provider.errorMessage ?? "Error loading judgment",
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () =>
                              provider.fetchJudgmentDetail(widget.judgment.id),
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

              return Column(
                children: [
                  // Title Header
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          judgment.title,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (judgment.bench != null || judgment.author != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (judgment.bench != null)
                                  Row(
                                    children: [
                                      const Icon(Iconsax.judge,
                                          color: Color(0xFF02F1C3), size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Bench: ${judgment.bench}',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white70,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (judgment.author != null &&
                                    judgment.bench != null)
                                  const SizedBox(height: 8),
                                if (judgment.author != null)
                                  Row(
                                    children: [
                                      const Icon(Iconsax.user,
                                          color: Color(0xFF02F1C3), size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Author: ${judgment.author}',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white70,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        border: Border(
                          top: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1)),
                          left: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1)),
                          right: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        child: _buildJudgmentContent(judgment.content ?? ''),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildJudgmentContent(String content) {
    if (content.isEmpty) return const SizedBox();

    // If content is extremely large, use a virtualized list to prevent ANR
    // Threshold high (e.g., 80k chars) where Markdown widget starts to lag
    if (content.length > 80000) {
      final paragraphs =
          content.split('\n').where((p) => p.trim().isNotEmpty).toList();

      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: paragraphs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SelectableText(
              paragraphs[index],
              style: GoogleFonts.lexend(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                height: 1.7,
              ),
            ),
          );
        },
      );
    }

    // Standard markdown rendering for normal sized docs
    return Markdown(
      padding: const EdgeInsets.all(24),
      data: content,
      styleSheet: MarkdownStyleSheet(
        p: GoogleFonts.lexend(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
            height: 1.7),
        h1: GoogleFonts.outfit(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        h2: GoogleFonts.outfit(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        strong: const TextStyle(
            color: Color(0xFF02F1C3), fontWeight: FontWeight.bold),
        listBullet: const TextStyle(color: Color(0xFF02F1C3)),
      ),
    );
  }
}
