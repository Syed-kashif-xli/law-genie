import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  final GenerativeModel _model;

  ChatSession? _chatSession;

  GeminiService()
      : _model = FirebaseAI.googleAI().generativeModel(
          model: 'gemini-2.5-flash',
          systemInstruction: Content.system(
            'You are a helpful, friendly, and intelligent AI assistant. '
            'You are talking to the user via voice. '
            'Keep your responses concise, natural, and conversational. '
            'Avoid long paragraphs, bullet points, or robotic phrasing like "I am an AI". '
            'Act like a real human having a chat. '
            'If the user asks for legal advice, give a brief summary and suggest checking the detailed documents, but keep the tone light and helpful.',
          ),
        );

  void startChat() {
    _chatSession = _model.startChat();
  }

  Future<Stream<GenerateContentResponse>> sendMessageStream(
      String message) async {
    try {
      if (_chatSession == null) {
        startChat();
      }
      return _chatSession!.sendMessageStream(Content.text(message));
    } catch (e) {
      debugPrint('Error generating stream: $e');
      rethrow;
    }
  }

  Future<String> sendMessage(String message) async {
    try {
      if (_chatSession == null) {
        startChat();
      }
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? '';
    } catch (e) {
      debugPrint('Error generating text: $e');
      return 'Sorry, I encountered an error: $e';
    }
  }

  // Keep for backward compatibility if needed, or remove if unused elsewhere
  Future<String> generateText(String prompt) async {
    return sendMessage(prompt);
  }
}
