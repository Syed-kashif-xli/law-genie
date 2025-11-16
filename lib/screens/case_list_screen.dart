import 'package:flutter/material.dart';
import 'package:myapp/features/case_timeline/case_timeline_page.dart';
import 'package:myapp/models/case_model.dart';
import 'package:myapp/providers/case_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CaseListScreen extends StatelessWidget {
  const CaseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cases'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
      ),
      body: caseProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : caseProvider.cases.isEmpty
              ? const Center(
                  child: Text(
                    'No cases yet. Tap the + button to add one!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: caseProvider.cases.length,
                  itemBuilder: (context, index) {
                    final caseItem = caseProvider.cases[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColor,
                          child: const Icon(Icons.folder, color: Colors.white),
                        ),
                        title: Text(
                          caseItem.title,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Case #: ${caseItem.caseNumber}\nCreated on: ${DateFormat.yMMMMd().format(caseItem.creationDate)}',
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CaseTimelinePage(caseId: caseItem.id!),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCaseDialog(context);
        },
        tooltip: 'Add Case',
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showAddCaseDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const AddCaseDialog(),
    );
  }
}

class AddCaseDialog extends StatefulWidget {
  const AddCaseDialog({super.key});

  @override
  AddCaseDialogState createState() => AddCaseDialogState();
}

class AddCaseDialogState extends State<AddCaseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _courtNameController = TextEditingController();
  final _partiesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add a New Case', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Case Title', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caseNumberController,
                decoration: const InputDecoration(labelText: 'Case Number', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a case number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courtNameController,
                decoration: const InputDecoration(labelText: 'Court Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a court name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _partiesController,
                decoration: const InputDecoration(labelText: 'Parties (comma-separated)', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter the parties' : null,
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
            backgroundColor: theme.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newCase = Case(
                title: _titleController.text,
                description: _descriptionController.text,
                caseNumber: _caseNumberController.text,
                courtName: _courtNameController.text,
                parties: _partiesController.text.split(',').map((p) => p.trim()).toList(),
                creationDate: DateTime.now(),
              );
              Provider.of<CaseProvider>(context, listen: false).addCase(newCase);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add Case'),
        ),
      ],
    );
  }
}
