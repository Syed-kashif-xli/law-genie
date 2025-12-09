import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/features/case_timeline/timeline_provider.dart';
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch reminders when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimelineProvider>(context, listen: false)
          .fetchUpcomingReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: AppBar(
        title: Text(
          'Upcoming Reminders',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<TimelineProvider>(
        builder: (context, timelineProvider, child) {
          if (timelineProvider.isRemindersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final upcomingReminders = timelineProvider.reminders;

          if (upcomingReminders.isEmpty) {
            return Center(
              child: Text(
                'No upcoming reminders.',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: upcomingReminders.length,
            itemBuilder: (context, index) {
              final event = upcomingReminders[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                color: const Color(0xFF19173A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xFF02F1C3).withValues(alpha: 0.2),
                    child: const Icon(Icons.notifications,
                        color: Color(0xFF02F1C3)),
                  ),
                  title: Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    'Reminder on ${DateFormat.yMMMMd().add_jm().format(event.reminderDate!)}',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: () {
                    // Navigate to the case timeline or show event details
                    // Ideally we should pass the caseId if we knew it to open the specific timeline
                    Navigator.pushNamed(context, '/caseList');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await NotificationService().showNotification(
            id: 999,
            title: 'Test Notification',
            body: 'This is a test notification to verify settings.',
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Test notification sent')),
            );
          }
        },
        child: const Icon(Icons.notifications_active, color: Colors.white),
      ),
    );
  }
}
