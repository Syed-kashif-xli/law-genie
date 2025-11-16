import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/timeline_event.dart';
import 'package:myapp/features/case_timeline/timeline_provider.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Reminders'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
      ),
      body: Consumer<TimelineProvider>(
        builder: (context, timelineProvider, child) {
          if (timelineProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final upcomingEvents = timelineProvider.events
              .where((event) => event.reminderDate != null && event.reminderDate!.isAfter(DateTime.now()))
              .toList();

          if (upcomingEvents.isEmpty) {
            return const Center(
              child: Text(
                'No upcoming reminders.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Sort events by reminder date
          upcomingEvents.sort((a, b) => a.reminderDate!.compareTo(b.reminderDate!));

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: upcomingEvents.length,
            itemBuilder: (context, index) {
              final event = upcomingEvents[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.primaryColor,
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(
                    event.title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Reminder on ${DateFormat.yMMMMd().add_jm().format(event.reminderDate!)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to the case timeline or show event details
                    Navigator.pushNamed(context, '/caseTimeline');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
