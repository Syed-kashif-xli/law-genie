import 'package:flutter/material.dart';

class GenerateDocPage extends StatelessWidget {
  const GenerateDocPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Document'),
      ),
      body: const Center(
        child: Text('Generate Document Page'),
      ),
    );
  }
}