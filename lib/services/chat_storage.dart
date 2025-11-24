import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/chat_model.dart';

class ChatStorageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> addChatSession(ChatSession session) async {
    if (_userId == null) return;
    await _db
        .collection('users')
        .doc(_userId)
        .collection('chats')
        .doc(session.sessionId)
        .set(session.toMap()); // Assuming ChatSession has toMap()
  }

  Future<List<ChatSession>> getChatSessions() async {
    if (_userId == null) return [];
    final snapshot = await _db
        .collection('users')
        .doc(_userId)
        .collection('chats')
        .orderBy('timestamp', descending: true) // Assuming timestamp exists
        .get();

    return snapshot.docs
        .map((doc) => ChatSession.fromMap(doc.data())) // Assuming fromMap()
        .toList();
  }

  Future<void> deleteChatSession(String sessionId) async {
    if (_userId == null) return;
    await _db
        .collection('users')
        .doc(_userId)
        .collection('chats')
        .doc(sessionId)
        .delete();
  }

  Future<void> clearAllChatSessions() async {
    if (_userId == null) return;
    final snapshot =
        await _db.collection('users').doc(_userId).collection('chats').get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
