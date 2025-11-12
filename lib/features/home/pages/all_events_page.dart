import 'package:flutter/material.dart';
import 'package:myapp/features/case_timeline/timeline_provider.dart';
import 'package:myapp/features/home/widgets/event_card.dart';
import 'package:provider/provider.dart';

class AllEventsPage extends StatelessWidget {
  const AllEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
      ),
      body: Consumer<TimelineProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.timeline.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: provider.timeline.length,
            itemBuilder: (context, index) {
              final event = provider.timeline[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: EventCard(event: event),
              );
            },
          );
        },
      ),
    );
  }
}
