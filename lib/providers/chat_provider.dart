import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/chat_model.dart';
import 'package:myapp/services/chat_storage.dart';
import 'package:myapp/services/pdf_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatStorageService _chatStorageService = ChatStorageService();
  List<ChatSession> _chatSessions = [];
  StreamSubscription<List<ChatSession>>? _chatSubscription;

  ChatProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _chatSubscription?.cancel();
      if (user != null) {
        _chatSubscription = _chatStorageService.getChatSessionsStream().listen(
          (sessions) {
            _chatSessions = sessions;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error listening to chat sessions: $error');
          },
        );
      } else {
        _chatSessions = [];
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }

  List<ChatSession> get chatSessions => _chatSessions;
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadChatSessions() async {
    // Kept for manual refresh if needed, but stream handles updates
    _chatSessions = await _chatStorageService.getChatSessions();
    notifyListeners();
  }

  Future<void> addChatSession(ChatSession session) async {
    await _chatStorageService.addChatSession(session);
    // Stream will update UI
  }

  Future<void> renameChatSession(String sessionId, String newTitle) async {
    await _chatStorageService.updateChatSessionTitle(sessionId, newTitle);
    // Stream will update UI
  }

  Future<void> deleteChatSession(String sessionId) async {
    await _chatStorageService.deleteChatSession(sessionId);
    // Stream will update UI
  }

  Future<void> downloadChatSession(ChatSession session) async {
    await PdfService.generateChatPdf(session);
  }

  Future<void> clearChatHistory() async {
    await _chatStorageService.clearAllChatSessions();
    _chatSessions = [];
    notifyListeners();
  }
}
