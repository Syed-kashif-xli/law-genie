import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  final GenerativeModel _model;

  ChatSession? _chatSession;

  GeminiService()
      : _model =
            FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

  void startChat() {
    _chatSession = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      if (_chatSession == null) {
        startChat();
      }
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? '';
    } catch (e) {
      print('Error generating text: $e');
      return 'Sorry, I encountered an error: $e';
    }
  }

  // Keep for backward compatibility if needed, or remove if unused elsewhere
  Future<String> generateText(String prompt) async {
    return sendMessage(prompt);
  }
}
