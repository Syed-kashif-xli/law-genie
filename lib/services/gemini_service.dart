import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService() : _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-1.5-flash');

  Future<String> generateText(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      print('Error generating text: $e');
      return 'Error generating text: $e';
    }
  }
}
