import 'package:hive/hive.dart';
import 'package:myapp/models/chat_model.dart';

class ChatStorageService {
  static const String _boxName = 'chat_sessions';

  Future<Box<ChatSession>> get _box async =>
      await Hive.openBox<ChatSession>(_boxName);

  Future<void> addChatSession(ChatSession session) async {
    final box = await _box;
    await box.put(session.sessionId, session);
  }

  Future<List<ChatSession>> getChatSessions() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<void> deleteChatSession(String sessionId) async {
    final box = await _box;
    await box.delete(sessionId);
  }

  Future<void> clearAllChatSessions() async {
    final box = await _box;
    await box.clear();
  }
}
