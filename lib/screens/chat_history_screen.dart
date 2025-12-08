import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:myapp/features/chat/chat_page.dart';
import 'package:myapp/models/chat_model.dart';
import 'package:myapp/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Provider.of<ChatProvider>(context, listen: false)
        ..loadChatSessions(),
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A032A),
            appBar: AppBar(
              title: Text(
                'Chat History',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFF19173A),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Iconsax.arrow_left, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                if (chatProvider.chatSessions.isNotEmpty)
                  IconButton(
                    icon: const Icon(Iconsax.trash, color: Colors.redAccent),
                    onPressed: () =>
                        _showClearAllConfirmationDialog(context, chatProvider),
                  ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await chatProvider.loadChatSessions();
              },
              color: const Color(0xFF02F1C3),
              backgroundColor: const Color(0xFF19173A),
              child: chatProvider.chatSessions.isEmpty
                  ? Stack(
                      children: [
                        ListView(), // Needed for RefreshIndicator to work with empty list
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Iconsax.message_text,
                                  size: 64, color: Colors.white24),
                              const SizedBox(height: 16),
                              Text(
                                'No chat history found.',
                                style: GoogleFonts.poppins(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: chatProvider.chatSessions.length,
                      itemBuilder: (context, index) {
                        final session = chatProvider.chatSessions[index];
                        return _buildChatListItem(
                            context, session, chatProvider);
                      },
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatListItem(
      BuildContext context, ChatSession session, ChatProvider chatProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF19173A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AIChatPage(chatSession: session),
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF02F1C3).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Iconsax.message, color: Color(0xFF02F1C3), size: 24),
        ),
        title: Text(
          session.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          DateFormat('MMM d, y • h:mm a').format(session.timestamp),
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white38),
          color: const Color(0xFF2A2650),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'rename') {
              _showRenameDialog(context, session, chatProvider);
            } else if (value == 'download') {
              chatProvider.downloadChatSession(session);
            } else if (value == 'delete') {
              _showDeleteConfirmationDialog(context, session, chatProvider);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'rename',
              child: Row(
                children: [
                  const Icon(Iconsax.edit, size: 18, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Rename',
                      style: GoogleFonts.poppins(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'download',
              child: Row(
                children: [
                  const Icon(Iconsax.document_download,
                      size: 18, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Download PDF',
                      style: GoogleFonts.poppins(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Iconsax.trash, size: 18, color: Colors.redAccent),
                  const SizedBox(width: 12),
                  Text('Delete',
                      style: GoogleFonts.poppins(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context, ChatSession session, ChatProvider chatProvider) {
    final TextEditingController controller =
        TextEditingController(text: session.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF19173A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Rename Chat',
              style: GoogleFonts.poppins(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter new title',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.5))),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF02F1C3))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  chatProvider.renameChatSession(
                      session.sessionId, controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Save',
                  style: GoogleFonts.poppins(color: const Color(0xFF02F1C3))),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, ChatSession session, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF19173A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Delete Chat?',
              style: GoogleFonts.poppins(color: Colors.white)),
          content: Text(
            'Are you sure you want to delete this chat session?',
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                chatProvider.deleteChatSession(session.sessionId);
                Navigator.pop(context);
              },
              child: Text('Delete',
                  style: GoogleFonts.poppins(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllConfirmationDialog(
      BuildContext context, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF19173A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Clear All History?',
              style: GoogleFonts.poppins(color: Colors.white)),
          content: Text(
            'Are you sure you want to delete ALL chat history? This cannot be undone.',
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                chatProvider.clearChatHistory();
                Navigator.pop(context);
              },
              child: Text('Clear All',
                  style: GoogleFonts.poppins(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}
