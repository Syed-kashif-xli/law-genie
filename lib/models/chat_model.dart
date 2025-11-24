import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'chat_model.g.dart';

@HiveType(typeId: 0)
class ChatSession extends HiveObject {
  @HiveField(0)
  late String sessionId;

  @HiveField(1)
  late DateTime timestamp;

  @HiveField(2)
  late List<ChatMessage> messages;

  ChatSession({
    required this.sessionId,
    required this.timestamp,
    required this.messages,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'timestamp': Timestamp.fromDate(timestamp),
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      sessionId: map['sessionId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      messages: (map['messages'] as List<dynamic>)
          .map((m) => ChatMessage.fromMap(m))
          .toList(),
    );
  }
}

@HiveType(typeId: 1)
class ChatMessage extends HiveObject {
  @HiveField(0)
  late String userMessage;

  @HiveField(1)
  late String botResponse;

  ChatMessage({
    required this.userMessage,
    required this.botResponse,
  });

  Map<String, dynamic> toMap() {
    return {
      'userMessage': userMessage,
      'botResponse': botResponse,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      userMessage: map['userMessage'] ?? '',
      botResponse: map['botResponse'] ?? '',
    );
  }
}
