import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  final GenerativeModel _model;

  ChatSession? _chatSession;

  GeminiService()
      : _model = FirebaseVertexAI.instance.generativeModel(
          model: 'gemini-2.5-flash',
          systemInstruction: Content.system(
            'You are a helpful, friendly, and intelligent AI assistant. '
            'You are expert in legal matters. '
            'Keep your responses concise, natural, and conversational. '
            'Avoid robotic phrasing like "I am an AI". '
            'If the user asks for legal advice, give a brief summary and suggest checking the detailed documents.',
          ),
        );

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
      debugPrint('Error generating text: $e');
      return 'Sorry, I encountered an error: $e';
    }
  }

  Future<String> sendMultiPartMessage(
      String message, List<InlineDataPart> attachments) async {
    try {
      final parts = <Part>[TextPart(message)];
      parts.addAll(attachments);

      final response = await _model.generateContent([Content.multi(parts)]);
      return response.text ?? '';
    } catch (e) {
      debugPrint('Error generating multi-part response: $e');
      return 'Error: $e';
    }
  }

  // Keep for backward compatibility
  Future<String> generateText(String prompt) async => sendMessage(prompt);
}
