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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimelineProvider>(context, listen: false)
          .fetchTimelineEvents(widget.caseId);
    });
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
      backgroundColor: const Color(0xFF0A032A), // Dark background
      appBar: AppBar(
        title:
            const Text('Case Timeline', style: TextStyle(color: Colors.white)),
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
                style: TextStyle(fontSize: 18, color: Colors.white70),
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
                    color: const Color(0xFF19173A), // Dark card background
                    shadowColor: Colors.black.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(item.status).withOpacity(0.2),
                            const Color(0xFF19173A), // Dark gradient end
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
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
                                      Icon(Icons.calendar_today,
                                          size: 16,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.6)),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat.yMMMMd().format(item.date),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item.description,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (item.reminderDate != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.notifications_active,
                                              size: 16,
                                              color: Colors.blueAccent),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Reminder: ${DateFormat.yMMMMd().add_jm().format(item.reminderDate!)}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                      color: Colors.blueAccent,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'rename') {
                                  _showAddEventDialog(context, widget.caseId,
                                      event: item);
                                } else if (value == 'delete') {
                                  _showDeleteConfirmationDialog(
                                      context, widget.caseId, item);
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'rename',
                                  child: Text('Rename'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete'),
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

  Future<void> _showAddEventDialog(BuildContext context, String caseId,
      {TimelineEvent? event}) async {
    await showDialog(
      context: context,
      builder: (context) => AddEventDialog(caseId: caseId, event: event),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String caseId, TimelineEvent event) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final timelineProvider =
                    Provider.of<TimelineProvider>(context, listen: false);
                if (event.reminderDate != null) {
                  NotificationService().cancelNotification(event.id.hashCode);
                }
                timelineProvider.deleteTimelineEvent(caseId, event.id!);
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

class AddEventDialog extends StatefulWidget {
  final String caseId;
  final TimelineEvent? event;
  const AddEventDialog({super.key, required this.caseId, this.event});

  @override
  AddEventDialogState createState() => AddEventDialogState();
}

class AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimelineStatus _selectedStatus;
  bool _isReminderSet = false;
  DateTime? _reminderDate;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? '');
    _selectedDate = widget.event?.date ?? DateTime.now();
    _selectedStatus = widget.event?.status ?? TimelineStatus.upcoming;
    if (widget.event?.reminderDate != null) {
      _isReminderSet = true;
      _reminderDate = widget.event!.reminderDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
          widget.event == null ? 'Add Timeline Event' : 'Edit Timeline Event',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: 'Title', border: OutlineInputBorder()),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Date: ${DateFormat.yMMMMd().format(_selectedDate)}'),
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
                    child:
                        Text(status.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Set Reminder'),
                value: _isReminderSet,
                onChanged: (bool value) {
                  setState(() {
                    _isReminderSet = value;
                    if (_isReminderSet) {
                      _selectReminderDateTime();
                    } else {
                      _reminderDate = null;
                    }
                  });
                },
              ),
              if (_isReminderSet && _reminderDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                            'Reminder: ${DateFormat.yMMMMd().add_jm().format(_reminderDate!)}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: _selectReminderDateTime,
                      )
                    ],
                  ),
                )
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _saveEvent,
          child: Text(widget.event == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _selectReminderDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate == null) return; // User cancelled

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderDate ?? DateTime.now()),
    );
    if (pickedTime == null) return; // User cancelled

    setState(() {
      _reminderDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _isReminderSet = true; // Ensure this is set if they picked a date
    });
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final timelineProvider =
        Provider.of<TimelineProvider>(context, listen: false);

    if (widget.event != null && widget.event?.id != null) {
      await _notificationService.cancelNotification(widget.event!.id.hashCode);
    }

    DateTime? finalReminderDate;
    if (_isReminderSet && _reminderDate != null) {
      if (_reminderDate!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder date must be in the future')),
        );
        return;
      }
      finalReminderDate = _reminderDate;
    }

    try {
      if (widget.event == null) {
        final newEvent = TimelineEvent(
          title: _titleController.text,
          description: _descriptionController.text,
          date: _selectedDate,
          status: _selectedStatus,
          icon: Icons.event,
          reminderDate: finalReminderDate,
        );
        final docRef =
            await timelineProvider.addTimelineEvent(widget.caseId, newEvent);

        if (finalReminderDate != null && docRef != null) {
          await _notificationService.scheduleNotification(
            id: docRef.id.hashCode,
            title: 'Case Reminder: ${newEvent.title}',
            body: newEvent.description,
            scheduledDate: finalReminderDate,
          );
        }
      } else {
        final updatedEvent = widget.event!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          date: _selectedDate,
          status: _selectedStatus,
          reminderDate: finalReminderDate,
        );
        await timelineProvider.updateTimelineEvent(widget.caseId, updatedEvent);

        if (finalReminderDate != null && updatedEvent.id != null) {
          await _notificationService.scheduleNotification(
            id: updatedEvent.id!.hashCode,
            title: 'Case Reminder: ${updatedEvent.title}',
            body: updatedEvent.description,
            scheduledDate: finalReminderDate,
          );
        }
      }
    } catch (e) {
      // Silently fail if notification permission is not granted
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
