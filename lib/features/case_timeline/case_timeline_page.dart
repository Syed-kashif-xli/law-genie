import 'package:flutter/material.dart';

class CaseTimelinePage extends StatelessWidget {
  const CaseTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Timeline'),
      ),
      body: const Center(
        child: Text('Case Timeline Page'),
      ),
    );
  }
}