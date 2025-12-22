import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:myapp/providers/diary_provider.dart';
import 'package:myapp/features/home/widgets/inline_banner_ad_widget.dart';
import 'package:myapp/features/home/providers/usage_provider.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  void _addNewEntry() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DiaryEditorPage(
          onSave: (entry) {
            Provider.of<DiaryProvider>(context, listen: false).addEntry(entry);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A032A), Color(0xFF151038)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'AI Legal Diary',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.search_normal, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF02F1C3), Color(0xFF00C7A0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF02F1C3).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _addNewEntry,
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Iconsax.add, color: Color(0xFF0A032A)),
            label: Text(
              'New Entry',
              style: GoogleFonts.poppins(
                color: const Color(0xFF0A032A),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        body: Consumer<DiaryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.entries.isEmpty) {
              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Iconsax.note_1,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Your Legal Journey',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Document your thoughts and get AI insights.',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const InlineBannerAdWidget(),
                ],
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: provider.entries.length,
                    itemBuilder: (context, index) {
                      final entry = provider.entries[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildEntryCard(entry),
                      );
                    },
                  ),
                ),
                const InlineBannerAdWidget(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEntryCard(DiaryEntry entry) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF19173A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getMoodColor(entry.mood).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _getMoodColor(entry.mood)
                                .withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(_getMoodIcon(entry.mood),
                              size: 16, color: _getMoodColor(entry.mood)),
                          const SizedBox(width: 8),
                          Text(
                            entry.mood,
                            style: GoogleFonts.poppins(
                              color: _getMoodColor(entry.mood),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(entry.date),
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (entry.aiSuggestion != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(Iconsax.magic_star,
                            color: const Color(0xFF02F1C3), size: 20),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  entry.content,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.6,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return Colors.greenAccent;
      case 'Stressed':
        return Colors.orangeAccent;
      case 'Sad':
        return Colors.blueAccent;
      case 'Confident':
        return Colors.purpleAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'Happy':
        return Iconsax.emoji_happy;
      case 'Stressed':
        return Iconsax.emoji_normal; // Closest to stressed
      case 'Sad':
        return Iconsax.emoji_sad;
      case 'Confident':
        return Iconsax.verify;
      default:
        return Iconsax.note;
    }
  }
}

class DiaryEntry {
  final String? id;
  final String title;
  final String content;
  final DateTime date;
  final String mood;
  final String? aiSuggestion;

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.aiSuggestion,
  });
}

class DiaryEditorPage extends StatefulWidget {
  final Function(DiaryEntry) onSave;

  const DiaryEditorPage({super.key, required this.onSave});

  @override
  State<DiaryEditorPage> createState() => _DiaryEditorPageState();
}

class _DiaryEditorPageState extends State<DiaryEditorPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = 'Neutral';
  String? _aiSuggestion;
  bool _isGenerating = false;

  final List<String> _moods = [
    'Neutral',
    'Happy',
    'Stressed',
    'Sad',
    'Confident'
  ];

  Future<void> _getAISuggestion() async {
    if (_contentController.text.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-2.5-flash',
        systemInstruction: Content.system(
            'You are a legal assistant analyzing a user\'s diary note. '
            'Provide a brief, helpful legal insight or suggestion based on the note. '
            'Keep it concise (under 50 words) and supportive.'),
      );

      final prompt = [Content.text(_contentController.text)];
      final response = await model.generateContent(prompt);

      setState(() {
        _aiSuggestion = response.text;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating suggestion: $e')),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _save() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both title and content')),
      );
      return;
    }

    // Check Usage Limits
    final usageProvider = Provider.of<UsageProvider>(context, listen: false);
    final limitError = usageProvider.canUseFeature('diary');
    if (limitError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$limitError (Legal Diary)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final entry = DiaryEntry(
      title: _titleController.text,
      content: _contentController.text,
      date: DateTime.now(),
      mood: _selectedMood,
      aiSuggestion: _aiSuggestion,
    );

    widget.onSave(entry);
    usageProvider.incrementDiary(); // Increment Firestore Count
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A032A), Color(0xFF151038)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'New Entry',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: _save,
                style: TextButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF02F1C3).withValues(alpha: 0.1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF02F1C3),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mood Selector
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _moods.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final mood = _moods[index];
                          final isSelected = mood == _selectedMood;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedMood = mood),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF02F1C3)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF02F1C3)
                                      : Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Text(
                                mood,
                                style: GoogleFonts.poppins(
                                  color: isSelected
                                      ? const Color(0xFF0A032A)
                                      : Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title Input
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: GoogleFonts.poppins(color: Colors.white38),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false, // Override global theme
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Content Input
                    Container(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: TextField(
                        controller: _contentController,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.6,
                        ),
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Write your thoughts...',
                          hintStyle: GoogleFonts.poppins(color: Colors.white38),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false, // Override global theme
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_aiSuggestion != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF02F1C3).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF02F1C3)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF02F1C3)
                                        .withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Iconsax.magic_star,
                                      size: 18, color: Color(0xFF02F1C3)),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'AI Suggestion',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF02F1C3),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            MarkdownBody(
                              data: _aiSuggestion!,
                              styleSheet: MarkdownStyleSheet(
                                p: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF19173A),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF02F1C3), Color(0xFF00C7A0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF02F1C3)
                                  .withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _getAISuggestion,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Color(0xFF0A032A)),
                                )
                              : const Icon(Iconsax.magic_star,
                                  color: Color(0xFF0A032A)),
                          label: Text(
                            _isGenerating
                                ? 'Analyzing...'
                                : 'Get AI Suggestion',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0A032A),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
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
