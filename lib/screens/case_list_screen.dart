import 'package:flutter/material.dart';
import 'package:myapp/features/case_timeline/case_timeline_page.dart';
import 'package:myapp/models/case_model.dart';
import 'package:myapp/providers/case_provider.dart';
import 'package:myapp/features/home/providers/usage_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:myapp/services/notification_service.dart'; // Added

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
  DateTime? _selectedNextHearingDate;
  bool _isSaving = false;

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
    _selectedNextHearingDate = widget.caseItem?.nextHearingDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _caseNumberController.dispose();
    _courtNameController.dispose();
    _partiesController.dispose();
    super.dispose();
  }

  Future<void> _pickNextHearingDate() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        _selectedNextHearingDate ?? now.add(const Duration(days: 1));

    // Show Date Picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      // Show Time Picker
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_selectedNextHearingDate ?? initialDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedNextHearingDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveCase() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final parties = _partiesController.text
            .split(',')
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .toList();

        final notificationService = NotificationService();
        await notificationService.requestNotificationPermissions();

        if (widget.caseItem == null) {
          final newCase = Case(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            caseNumber: _caseNumberController.text.trim(),
            courtName: _courtNameController.text.trim(),
            parties: parties,
            creationDate: DateTime.now(),
            nextHearingDate: _selectedNextHearingDate,
          );
          final docRef = await Provider.of<CaseProvider>(context, listen: false)
              .addCase(newCase);

          if (mounted && docRef != null) {
            Provider.of<UsageProvider>(context, listen: false).incrementCases();

            // Schedule Notification if date is set
            if (_selectedNextHearingDate != null) {
              await notificationService.scheduleNotification(
                id: docRef.id.hashCode,
                title: 'Upcoming Hearing: ${newCase.title}',
                body:
                    'Your case (${newCase.caseNumber}) has a hearing at ${DateFormat.jm().format(_selectedNextHearingDate!)}',
                scheduledDate: _selectedNextHearingDate!,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder set successfully!')),
                );
              }
            }
          }
        } else {
          // Update Case
          final updatedCase = widget.caseItem!.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            caseNumber: _caseNumberController.text.trim(),
            courtName: _courtNameController.text.trim(),
            parties: parties,
            nextHearingDate: _selectedNextHearingDate,
          );
          await Provider.of<CaseProvider>(context, listen: false)
              .updateCase(updatedCase);

          // Update Notification
          if (_selectedNextHearingDate != null) {
            await notificationService
                .cancelNotification(widget.caseItem!.id.hashCode);
            await notificationService.scheduleNotification(
              id: widget.caseItem!.id
                  .hashCode, // Use hashcode of ID for notification ID
              title: 'Upcoming Hearing: ${updatedCase.title}',
              body:
                  'Your case (${updatedCase.caseNumber}) has a hearing at ${DateFormat.jm().format(_selectedNextHearingDate!)}',
              scheduledDate: _selectedNextHearingDate!,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder updated successfully!')),
              );
            }
          } else {
            // If date removed, cancel notification
            if (widget.caseItem!.nextHearingDate != null) {
              await notificationService
                  .cancelNotification(widget.caseItem!.id.hashCode);
            }
          }
        }
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving case: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool isMultiLine = false,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      maxLines: isMultiLine ? 3 : 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2C55A9))),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF19173A), // Dark dialog
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.caseItem == null ? 'Add a New Case' : 'Edit Case',
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                  controller: _titleController,
                  label: 'Case Title',
                  icon: Iconsax.folder),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Iconsax.document,
                  isMultiLine: true),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _caseNumberController,
                  label: 'Case Number',
                  icon: Iconsax.hashtag),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _courtNameController,
                  label: 'Court Name',
                  icon: Iconsax.courthouse),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _partiesController,
                  label: 'Parties (comma-separated)',
                  icon: Iconsax.people),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickNextHearingDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Next Hearing Date (Optional)',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                    prefixIcon:
                        const Icon(Icons.calendar_today, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                  child: Text(
                    _selectedNextHearingDate != null
                        ? DateFormat.yMMMMd()
                            .add_jm()
                            .format(_selectedNextHearingDate!)
                        : 'Tap to set reminder',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child:
              Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C55A9),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _isSaving ? null : _saveCase,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.caseItem == null ? 'Add Case' : 'Save',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}
