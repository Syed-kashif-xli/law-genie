
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/features/home/widgets/feature_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Law Genie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: const [
            FeatureCard(
              icon: Iconsax.message_question,
              title: 'Chat with Law Genie',
              description: 'Get instant AI-powered legal advice and answers.',
            ),
            FeatureCard(
              icon: Iconsax.document_text,
              title: 'Generate Legal Docs',
              description: 'Create professional contracts, NDAs, and more.',
            ),
            FeatureCard(
              icon: Iconsax.shield_tick,
              title: 'Assess Legal Risks',
              description: 'Analyze potential legal risks and get recommendations.',
            ),
            FeatureCard(
              icon: Iconsax.calendar_1,
              title: 'Track Your Case Timeline',
              description: 'Manage deadlines, hearings, and case milestones.',
            ),
          ],
        ),
      ),
    );
  }
}
