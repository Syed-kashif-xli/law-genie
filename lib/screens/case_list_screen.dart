import 'package:flutter/material.dart';
import 'package:myapp/features/case_timeline/case_timeline_page.dart';
import 'package:myapp/models/case_model.dart';
import 'package:myapp/providers/case_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class CaseListScreen extends StatelessWidget {
  const CaseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A032A), // Dark background
      appBar: AppBar(
        title: const Text('My Cases', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A032A), // Match body background
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: caseProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : caseProvider.cases.isEmpty
              ? const Center(
                  child: Text(
                    'No cases yet. Tap the + button to add one!',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: caseProvider.cases.length,
                  itemBuilder: (context, index) {
                    final caseItem = caseProvider.cases[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF19173A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CaseTimelinePage(caseId: caseItem.id!),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C55A9)
                                        .withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Iconsax.folder_2,
                                      color: Color(0xFF5C9DFF), size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        caseItem.title,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Case #: ${caseItem.caseNumber}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Created: ${DateFormat('MMM d, y').format(caseItem.creationDate)}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert,
                                      color: Colors.white38),
                                  color: const Color(0xFF2A2650),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  onSelected: (value) {
                                    if (value == 'rename') {
                                      _showAddCaseDialog(context,
                                          caseItem: caseItem);
                                    } else if (value == 'delete') {
                                      _showDeleteConfirmationDialog(
                                          context, caseItem);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'rename',
                                      child: Row(
                                        children: [
                                          const Icon(Iconsax.edit,
                                              size: 18, color: Colors.white),
                                          const SizedBox(width: 12),
                                          Text('Rename',
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(Iconsax.trash,
                                              size: 18,
                                              color: Colors.redAccent),
                                          const SizedBox(width: 12),
                                          Text('Delete',
                                              style: GoogleFonts.poppins(
                                                  color: Colors.redAccent)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCaseDialog(context);
        },
        tooltip: 'Add Case',
        backgroundColor: const Color(0xFF2C55A9),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showAddCaseDialog(BuildContext context,
      {Case? caseItem}) async {
    await showDialog(
      context: context,
      builder: (context) => AddCaseDialog(caseItem: caseItem),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, Case caseItem) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF19173A), // Dark dialog
          title: const Text('Confirm Delete',
              style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to delete this case?',
              style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Provider.of<CaseProvider>(context, listen: false)
                    .deleteCase(caseItem.id!);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class AddCaseDialog extends StatefulWidget {
  final Case? caseItem;
  const AddCaseDialog({super.key, this.caseItem});

  @override
  AddCaseDialogState createState() => AddCaseDialogState();
}

class AddCaseDialogState extends State<AddCaseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _caseNumberController;
  late TextEditingController _courtNameController;
  late TextEditingController _partiesController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.caseItem?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.caseItem?.description ?? '');
    _caseNumberController =
        TextEditingController(text: widget.caseItem?.caseNumber ?? '');
    _courtNameController =
        TextEditingController(text: widget.caseItem?.courtName ?? '');
    _partiesController =
        TextEditingController(text: widget.caseItem?.parties.join(', ') ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF19173A), // Dark dialog
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.caseItem == null ? 'Add a New Case' : 'Edit Case',
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: 'Case Title', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Description', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caseNumberController,
                decoration: const InputDecoration(
                    labelText: 'Case Number', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a case number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courtNameController,
                decoration: const InputDecoration(
                    labelText: 'Court Name', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a court name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _partiesController,
                decoration: const InputDecoration(
                    labelText: 'Parties (comma-separated)',
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the parties' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C55A9),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (widget.caseItem == null) {
                final newCase = Case(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  caseNumber: _caseNumberController.text,
                  courtName: _courtNameController.text,
                  parties: _partiesController.text
                      .split(',')
                      .map((p) => p.trim())
                      .toList(),
                  creationDate: DateTime.now(),
                );
                Provider.of<CaseProvider>(context, listen: false)
                    .addCase(newCase);
              } else {
                final updatedCase = widget.caseItem!.copyWith(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  caseNumber: _caseNumberController.text,
                  courtName: _courtNameController.text,
                  parties: _partiesController.text
                      .split(',')
                      .map((p) => p.trim())
                      .toList(),
                );
                Provider.of<CaseProvider>(context, listen: false)
                    .updateCase(updatedCase);
              }
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.caseItem == null ? 'Add Case' : 'Save'),
        ),
      ],
    );
  }
}
