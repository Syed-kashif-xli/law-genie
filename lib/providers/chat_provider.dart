
import 'package:flutter/material.dart';
import 'package:myapp/models/chat_model.dart';
import 'package:myapp/services/chat_storage.dart';

class ChatProvider with ChangeNotifier {
  final ChatStorageService _chatStorageService = ChatStorageService();
  List<ChatSession> _chatSessions = [];

  List<ChatSession> get chatSessions => _chatSessions;

  Future<void> loadChatSessions() async {
    _chatSessions = await _chatStorageService.getChatSessions();
    notifyListeners();
  }

  Future<void> addChatSession(ChatSession session) async {
    await _chatStorageService.addChatSession(session);
    await loadChatSessions();
  }

  Future<void> clearChatHistory() async {
    await _chatStorageService.clearAllChatSessions();
    _chatSessions = [];
    notifyListeners();
  }
}
