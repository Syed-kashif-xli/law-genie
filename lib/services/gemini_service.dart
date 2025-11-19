import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  // Initialize the Gemini Developer API backend service
  // Create a `GenerativeModel` instance with a model that supports your use case
  final model = FirebaseAI.googleAI().generativeModel(model: 'gemini-1.5-flash');

  Future<String> generateText(String prompt) async {
    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      print('Error generating text: $e');
      return 'Error generating text: $e';
    }
  }
}
