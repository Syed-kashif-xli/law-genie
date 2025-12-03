import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/models/chat_model.dart';

class ChatStorageService {
  // Explicitly using the URL to ensure connection to the correct region (asia-southeast1)
  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://law-genie-56982041-cd466-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> addChatSession(ChatSession session) async {
    debugPrint(
        'DEBUG: addChatSession called. UserID: $_userId, SessionID: ${session.sessionId}');
    if (_userId == null) {
      debugPrint('DEBUG: UserID is null. Cannot save chat.');
      return;
    }
    try {
      await _db
          .ref()
          .child('users')
          .child(_userId!)
          .child('chats')
          .child(session.sessionId)
          .set(session.toMap());
      debugPrint('DEBUG: Chat session saved successfully.');
    } catch (e) {
      debugPrint('DEBUG: Error saving chat session: $e');
      rethrow;
    }
  }

  Stream<List<ChatSession>> getChatSessionsStream() {
    if (_userId == null) {
      return Stream.value([]);
    }
    return _db
        .ref()
        .child('users')
        .child(_userId!)
        .child('chats')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      final List<ChatSession> sessions = [];
      try {
        if (data is Map) {
          data.forEach((key, value) {
            try {
              if (value is Map) {
                sessions
                    .add(ChatSession.fromMap(Map<String, dynamic>.from(value)));
              }
            } catch (e) {
              debugPrint('DEBUG: Error parsing session $key: $e');
            }
          });
        } else if (data is List) {
          // Handle case where Firebase returns list (unlikely for keyed objects but possible if keys are integers)
          for (var item in data) {
            if (item is Map) {
              sessions
                  .add(ChatSession.fromMap(Map<String, dynamic>.from(item)));
            }
          }
        }

        // Sort by timestamp descending (newest first)
        sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return sessions;
      } catch (e) {
        debugPrint('DEBUG: Error processing chat stream: $e');
        return [];
      }
    });
  }

  Future<List<ChatSession>> getChatSessions() async {
    debugPrint('DEBUG: getChatSessions called. UserID: $_userId');
    if (_userId == null) {
      debugPrint('DEBUG: UserID is null. Returning empty list.');
      return [];
    }
    try {
      final snapshot = await _db
          .ref()
          .child('users')
          .child(_userId!)
          .child('chats')
          .orderByChild('timestamp')
          .get();

      if (snapshot.exists) {
        debugPrint('DEBUG: Snapshot exists. Parsing data...');
        final data = snapshot.value;

        if (data is! Map) {
          debugPrint(
              'DEBUG: Data is not a Map. It is ${data.runtimeType}. Returning empty list.');
          return [];
        }

        final List<ChatSession> sessions = [];
        data.forEach((key, value) {
          try {
            if (value is Map) {
              sessions
                  .add(ChatSession.fromMap(Map<String, dynamic>.from(value)));
            } else {
              debugPrint(
                  'DEBUG: Skipping invalid session data for key $key: $value');
            }
          } catch (e) {
            debugPrint('DEBUG: Error parsing session $key: $e');
          }
        });

        // Sort by timestamp descending (newest first)
        sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        debugPrint('DEBUG: Found ${sessions.length} sessions.');
        return sessions;
      } else {
        debugPrint('DEBUG: No chat data found for user.');
      }
      return [];
    } catch (e) {
      debugPrint('DEBUG: Error getting chat sessions: $e');
      return [];
    }
  }

  Future<void> updateChatSessionTitle(String sessionId, String newTitle) async {
    if (_userId == null) return;
    await _db
        .ref()
        .child('users')
        .child(_userId!)
        .child('chats')
        .child(sessionId)
        .update({'title': newTitle});
  }

  Future<void> deleteChatSession(String sessionId) async {
    if (_userId == null) return;
    await _db
        .ref()
        .child('users')
        .child(_userId!)
        .child('chats')
        .child(sessionId)
        .remove();
  }

  Future<void> clearAllChatSessions() async {
    if (_userId == null) return;
    await _db.ref().child('users').child(_userId!).child('chats').remove();
  }
}
