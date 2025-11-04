
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/features/case_timeline/timeline_model.dart';
import 'package:myapp/features/case_timeline/timeline_provider.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

class CaseTimelinePage extends StatefulWidget {
  const CaseTimelinePage({super.key});

  @override
  _CaseTimelinePageState createState() => _CaseTimelinePageState();
}

class _CaseTimelinePageState extends State<CaseTimelinePage> {
  final NotificationService _notificationService = NotificationService();

  Color _getStatusColor(TimelineStatus status) {
    switch (status) {
      case TimelineStatus.completed:
        return Colors.green;
      case TimelineStatus.ongoing:
        return Colors.yellow;
      case TimelineStatus.upcoming:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Timeline'),
        centerTitle: true,
      ),
      body: Consumer<TimelineProvider>(
        builder: (context, timelineProvider, child) {
          if (timelineProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final timelineData = timelineProvider.timeline;

          if (timelineData.isEmpty) {
            return const Center(child: Text('No timeline events yet. Add one!'));
          }

          return ListView.builder(
            itemCount: timelineData.length,
            itemBuilder: (context, index) {
              final item = timelineData[index];
              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.1,
                isFirst: index == 0,
                isLast: index == timelineData.length - 1,
                indicatorStyle: IndicatorStyle(
                  width: 40,
                  height: 40,
                  indicator: Container(
                    decoration: BoxDecoration(
                      color: _getStatusColor(item.status),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Icon(item.icon, color: Colors.white, size: 24),
                    ),
                  ),
                ),
                beforeLineStyle: LineStyle(color: _getStatusColor(item.status), thickness: 2),
                afterLineStyle: LineStyle(color: _getStatusColor(item.status), thickness: 2),
                endChild: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat.yMMMMd().format(item.date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(item.description, style: Theme.of(context).textTheme.bodyMedium),
                          if (item.status == TimelineStatus.upcoming)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(Icons.notifications_active_outlined, color: Colors.blueAccent),
                                  tooltip: 'Set Reminder',
                                  onPressed: () {
                                    _showReminderDialog(context, item);
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Add Event',
      ),
    );
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const AddEventDialog(),
    );
  }

  Future<void> _showReminderDialog(BuildContext context, TimelineModel item) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: item.date,
      firstDate: DateTime.now(),
      lastDate: item.date.add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(item.date),
      );

      if (selectedTime != null) {
        final scheduledDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        await _notificationService.scheduleNotification(
          id: item.hashCode,
          title: 'Case Reminder: ${item.title}',
          body: item.description,
          scheduledDate: scheduledDate,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder set for ${DateFormat.yMMMMd().add_jm().format(scheduledDate)}')),
        );
      }
    }
  }
}

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({super.key});

  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimelineStatus _selectedStatus = TimelineStatus.upcoming;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Timeline Event'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text('Date: ${DateFormat.yMMMMd().format(_selectedDate)}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _selectedDate) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              DropdownButtonFormField<TimelineStatus>(
                value: _selectedStatus,
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
                items: TimelineStatus.values.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status.toString().split('.').last));
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newEvent = TimelineModel(
                title: _titleController.text,
                description: _descriptionController.text,
                date: _selectedDate,
                status: _selectedStatus,
                icon: Icons.event, // Default icon for new events
              );
              Provider.of<TimelineProvider>(context, listen: false).addTimelineEvent(newEvent);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
