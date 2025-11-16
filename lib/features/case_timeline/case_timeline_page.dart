import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/timeline_event.dart';
import 'package:myapp/features/case_timeline/timeline_provider.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

class CaseTimelinePage extends StatefulWidget {
  final String caseId;
  const CaseTimelinePage({super.key, required this.caseId});

  @override
  CaseTimelinePageState createState() => CaseTimelinePageState();
}

class CaseTimelinePageState extends State<CaseTimelinePage> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Fetch the timeline events for the specific case when the page loads
    Provider.of<TimelineProvider>(context, listen: false).fetchTimelineEvents(widget.caseId);
  }

  Color _getStatusColor(TimelineStatus status) {
    switch (status) {
      case TimelineStatus.completed:
        return Colors.green;
      case TimelineStatus.ongoing:
        return Colors.blue;
      case TimelineStatus.upcoming:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Timeline'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
      ),
      body: Consumer<TimelineProvider>(
        builder: (context, timelineProvider, child) {
          if (timelineProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final timelineData = timelineProvider.events;

          if (timelineData.isEmpty) {
            return const Center(
              child: Text(
                'No timeline events yet. Tap the + button to add one!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: timelineData.length,
            itemBuilder: (context, index) {
              final item = timelineData[index];
              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.1,
                isFirst: index == 0,
                isLast: index == timelineData.length - 1,
                indicatorStyle: IndicatorStyle(
                  width: 50,
                  height: 50,
                  indicator: Container(
                    decoration: BoxDecoration(
                      color: _getStatusColor(item.status),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getStatusColor(item.status).withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(item.icon, color: Colors.white, size: 28),
                    ),
                  ),
                ),
                beforeLineStyle: LineStyle(
                  color: _getStatusColor(item.status),
                  thickness: 3,
                ),
                afterLineStyle: LineStyle(
                  color: _getStatusColor(item.status),
                  thickness: 3,
                ),
                endChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(item.status).withOpacity(0.1),
                            theme.scaffoldBackgroundColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat.yMMMMd().format(item.date),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.description,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (item.reminderDate != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.notifications_active, size: 16, color: Colors.blueAccent),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Reminder Set',
                                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                if (item.status == TimelineStatus.upcoming)
                                  IconButton(
                                    icon: const Icon(Icons.notification_add, color: Colors.teal),
                                    tooltip: 'Set Reminder',
                                    onPressed: () {
                                      _showReminderDialog(context, item);
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
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
        onPressed: () => _showAddEventDialog(context, widget.caseId),
        tooltip: 'Add Event',
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showAddEventDialog(BuildContext context, String caseId) async {
    await showDialog(
      context: context,
      builder: (context) => AddEventDialog(caseId: caseId),
    );
  }

  Future<void> _showReminderDialog(BuildContext context, TimelineEvent item) async {
    final timelineProvider = Provider.of<TimelineProvider>(context, listen: false);

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: item.reminderDate ?? item.date,
      firstDate: DateTime.now(),
      lastDate: item.date.add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      if (!mounted) return;
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(item.reminderDate ?? item.date),
      );

      if (selectedTime != null) {
        final scheduledDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        // Schedule the notification
        await _notificationService.scheduleNotification(
          id: item.hashCode,
          title: 'Case Reminder: ${item.title}',
          body: item.description,
          scheduledDate: scheduledDate,
        );

        // Update the event with the new reminder date
        final updatedEvent = item.copyWith(reminderDate: scheduledDate);
        await timelineProvider.updateTimelineEvent(widget.caseId, updatedEvent);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder set for ${DateFormat.yMMMMd().add_jm().format(scheduledDate)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

class AddEventDialog extends StatefulWidget {
  final String caseId;
  const AddEventDialog({super.key, required this.caseId});

  @override
  AddEventDialogState createState() => AddEventDialogState();
}

class AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimelineStatus _selectedStatus = TimelineStatus.upcoming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Timeline Event', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
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
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: TimelineStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
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
              final newEvent = TimelineEvent(
                title: _titleController.text,
                description: _descriptionController.text,
                date: _selectedDate,
                status: _selectedStatus,
                icon: Icons.event, // Default icon
              );
              Provider.of<TimelineProvider>(context, listen: false).addTimelineEvent(widget.caseId, newEvent);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
