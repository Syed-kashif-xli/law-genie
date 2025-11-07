
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
}
