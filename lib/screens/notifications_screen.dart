import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/features/case_timeline/timeline_provider.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
          if (timelineProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final upcomingEvents = timelineProvider.events
              .where((event) =>
                  event.reminderDate != null &&
                  event.reminderDate!.isAfter(DateTime.now()))
              .toList();

          if (upcomingEvents.isEmpty) {
            return Center(
              child: Text(
                'No upcoming reminders.',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70),
              ),
            );
          }

          // Sort events by reminder date
          upcomingEvents
              .sort((a, b) => a.reminderDate!.compareTo(b.reminderDate!));

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: upcomingEvents.length,
            itemBuilder: (context, index) {
              final event = upcomingEvents[index];
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
