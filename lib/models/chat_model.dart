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

  @HiveField(3)
  late String title;

  ChatSession({
    required this.sessionId,
    required this.timestamp,
    required this.messages,
    this.title = 'New Chat',
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'messages': messages.map((m) => m.toMap()).toList(),
      'title': title,
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    var messagesData = map['messages'];
    List<ChatMessage> parsedMessages = [];

    if (messagesData is List) {
      parsedMessages = messagesData
          .map((m) => ChatMessage.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    } else if (messagesData is Map) {
      // Handle Map case where Firebase returns list as Map (e.g. {"0": {...}, "1": {...}})
      final sortedKeys = messagesData.keys.toList()
        ..sort((a, b) {
          if (a is String && b is String) {
            return int.tryParse(a)?.compareTo(int.tryParse(b) ?? 0) ?? 0;
          }
          return 0;
        });

      for (var key in sortedKeys) {
        parsedMessages.add(
            ChatMessage.fromMap(Map<String, dynamic>.from(messagesData[key])));
      }
    }

    return ChatSession(
      sessionId: map['sessionId']?.toString() ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
      messages: parsedMessages,
      title: map['title']?.toString() ?? 'New Chat',
    );
  }
}

@HiveType(typeId: 1)
class ChatMessage extends HiveObject {
  @HiveField(0)
  late String userMessage;

  @HiveField(1)
  late String botResponse;

  @HiveField(2)
  String? attachmentUrl;

  @HiveField(3)
  String? attachmentType;

  @HiveField(4)
  String? attachmentName;

  ChatMessage({
    required this.userMessage,
    required this.botResponse,
    this.attachmentUrl,
    this.attachmentType,
    this.attachmentName,
  });

  Map<String, dynamic> toMap() {
    return {
      'userMessage': userMessage,
      'botResponse': botResponse,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'attachmentName': attachmentName,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      userMessage: map['userMessage']?.toString() ?? '',
      botResponse: map['botResponse']?.toString() ?? '',
      attachmentUrl: map['attachmentUrl']?.toString(),
      attachmentType: map['attachmentType']?.toString(),
      attachmentName: map['attachmentName']?.toString(),
    );
  }
}
