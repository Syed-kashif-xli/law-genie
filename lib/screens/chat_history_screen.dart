import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/features/chat/chat_page.dart';
import 'package:myapp/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider()..loadChatSessions(),
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A032A),
            appBar: AppBar(
              title: const Text('Chat History',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF19173A),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () =>
                      _showClearConfirmationDialog(context, chatProvider),
                ),
              ],
            ),
            body: chatProvider.chatSessions.isEmpty
                ? const Center(
                    child: Text(
                      'No chat history found.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: chatProvider.chatSessions.length,
                    itemBuilder: (context, index) {
                      final session = chatProvider.chatSessions[index];
                      return Card(
                        color: const Color(0xFF19173A),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            session.messages.first.userMessage,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            DateFormat.yMd().add_jm().format(session.timestamp),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AIChatPage(chatSession: session),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  void _showClearConfirmationDialog(
      BuildContext context, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Chat History?'),
          content:
              const Text('Are you sure you want to delete all chat history?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Clear'),
              onPressed: () {
                chatProvider.clearChatHistory();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
