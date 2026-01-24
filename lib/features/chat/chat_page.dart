import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mime/mime.dart';
import 'package:myapp/features/home/providers/usage_provider.dart';
import 'package:myapp/utils/usage_limit_helper.dart';
import 'package:myapp/services/ad_service.dart';

import 'package:myapp/models/chat_model.dart' as my_models;
import 'package:myapp/providers/chat_provider.dart';
import 'package:myapp/services/pdf_service.dart';
import '../documents/document_viewer_page.dart';

class AIChatPage extends StatefulWidget {
  final my_models.ChatSession? chatSession;
  const AIChatPage({super.key, this.chatSession});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _Message {
  final String text;
  final bool isUser;
  bool hasAnimated;

  _Message(
      {required this.text, required this.isUser, this.hasAnimated = false});
}

class _DocumentMessage {
  final String title;
  final String content;

  _DocumentMessage({required this.title, required this.content});
}

class _AttachmentMessage {
  final File? file;
  final String? text;
  final String? imageUrl;
  final String? type; // 'image' or 'document'
  final String? name;
  _AttachmentMessage(
      {this.file, this.text, this.imageUrl, this.type, this.name});
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _messages = [];
  File? _selectedFile;
  late final GenerativeModel _model;
  late final ChatSession _chat;
  late String _sessionId;
  late ChatProvider _chatProvider;
  int _messagesSinceLastAd = 0;
  static const int _messagesBeforeAd = 5;
  bool _historyIncremented = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initGenerativeModel();
    _loadSession();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _saveChatSession();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _initGenerativeModel() async {
    _model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(
          'You are Law Genie, a friendly, intelligent, and empathetic Indian Legal AI Assistant. '
          'Your goal is to help users clearly understand their legal issues under Indian law with compassion and accuracy.\n\n'
          '**Critical Instruction on Greetings:**\n'
          '*   **Do NOT** start every response with "Hello", "Hi", or "Namaste". Only greet the user if it is the very first interaction or if they explicitly greet you.\n'
          '*   **Remember Context:** Treat this as an ongoing conversation. Refer back to what the user told you earlier (e.g., "As you mentioned earlier...").\n\n'
          '**Core Persona:**\n'
          '*   **Warm & Friendly:** Be approachable. Talk like a helpful, knowledgeable friend, not a robot.\n'
          '*   **Empathetic & Supportive:** Acknowledge the user\'s situation validly. (e.g., "That sounds stressful, I\'m here to help.").\n'
          '*   **Smart & Analytical:** Don\'t just answer; analyze. If facts are missing, ask clarifying questions.\n'
          '*   **Neutral & Professional:** Explain the law simply but do not take sides.\n\n'
          '**Instructions:**\n'
          '1.  **Understand & Empathize:** acknowledgement of their issue (without repetitive hello).\n'
          '2.  **Clarify (If needed):** If the query is vague, ask 1-2 specific follow-up questions.\n'
          '3.  **Explain the Law:** Provide accurate legal information based on Indian Acts, Sections, and case laws. Explain them in simple language.\n'
          '4.  **Actionable Guidance:** Provide easy step-by-step guidance.\n'
          '5.  **Conciseness:** Keep responses concise (120–250 words).\n\n'
          '**Constraints:**\n'
          '*   **Indian Law Only.**\n'
          '*   **Do NOT** act as a lawyer or promise court success.\n'
          '*   **Do NOT** make up laws or judgments.\n'
          '*   **Do NOT** provide real-time data unless certain.\n\n'
          '**Mandatory Footer:**\n'
          'You **MUST** end every response with this exact line:\n'
          '"⚠️ Disclaimer: This is general legal information for awareness and not a substitute for professional legal advice."'),
    );

    // Load chat history
    final history = widget.chatSession?.messages
            .map((m) {
              return [
                Content.text(m.userMessage),
                Content.model([TextPart(m.botResponse)])
              ];
            })
            .expand((x) => x)
            .toList() ??
        [];

    _chat = _model.startChat(history: history);
  }

  void _loadSession() {
    if (widget.chatSession != null) {
      _sessionId = widget.chatSession!.sessionId;
      for (var message in widget.chatSession!.messages) {
        if (message.attachmentUrl != null) {
          _messages.add(_AttachmentMessage(
            file: null,
            text: message.userMessage,
            imageUrl: message.attachmentUrl,
            type: message.attachmentType,
            name: message.attachmentName,
          ));
        } else {
          _messages.add(_Message(text: message.userMessage, isUser: true));
        }
        _messages.add(_Message(
            text: message.botResponse, isUser: false, hasAnimated: true));
      }
    } else {
      _sessionId = const Uuid().v4();
      // Default welcome message removed as requested
    }
    _scrollToBottom();
  }

  Future<void> _generatePdf() async {
    if (_messages.length <= 1) return;

    final chatMessages = <my_models.ChatMessage>[];
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i] is _Message && (_messages[i] as _Message).isUser) {
        final userMessage = _messages[i] as _Message;
        if (i + 1 < _messages.length &&
            _messages[i + 1] is _Message &&
            !(_messages[i + 1] as _Message).isUser) {
          final botMessage = _messages[i + 1] as _Message;
          chatMessages.add(my_models.ChatMessage(
            userMessage: userMessage.text,
            botResponse: botMessage.text,
          ));
        }
      }
    }

    if (chatMessages.isEmpty) return;

    final session = my_models.ChatSession(
      sessionId: _sessionId,
      timestamp: DateTime.now(),
      messages: chatMessages,
      title: widget.chatSession?.title ?? 'Chat Export',
    );

    await PdfService.generateChatPdf(session);
  }

  Future<void> _saveChatSession() async {
    debugPrint(
        'DEBUG: _saveChatSession called. Messages count: ${_messages.length}');

    if (_messages.length <= 1) {
      debugPrint('DEBUG: Not enough messages to save.');
      return;
    }

    final chatMessages = <my_models.ChatMessage>[];
    String? firstUserMessage;

    // Helper to extract data from dynamic message types
    (String, bool, String?, String?, String?)? extractData(dynamic msg) {
      if (msg is _Message) {
        return (msg.text, msg.isUser, null, null, null);
      } else if (msg is _AttachmentMessage) {
        return (
          "${msg.text ?? ''} [Attachment]",
          true,
          msg.imageUrl,
          msg.type,
          msg.name
        );
      } else if (msg is _DocumentMessage) {
        return (
          "Document: ${msg.title}\n${msg.content}",
          false,
          null,
          null,
          null
        );
      }
      return null;
    }

    for (int i = 0; i < _messages.length; i++) {
      final currentData = extractData(_messages[i]);
      if (currentData == null) continue;

      if (currentData.$2) {
        // isUser
        final userText = currentData.$1;
        final imageUrl = currentData.$3;
        final type = currentData.$4;
        final name = currentData.$5;

        firstUserMessage ??= userText;

        // Look ahead for bot response
        if (i + 1 < _messages.length) {
          final nextData = extractData(_messages[i + 1]);
          if (nextData != null && !nextData.$2) {
            // !isUser (Bot)
            chatMessages.add(my_models.ChatMessage(
              userMessage: userText,
              botResponse: nextData.$1,
              attachmentUrl: imageUrl,
              attachmentType: type,
              attachmentName: name,
            ));
          }
        }
      }
    }

    debugPrint('DEBUG: Chat messages to save: ${chatMessages.length}');

    if (chatMessages.isNotEmpty) {
      String title = widget.chatSession?.title ?? 'New Chat';
      if (widget.chatSession == null && firstUserMessage != null) {
        title = firstUserMessage.length > 30
            ? '${firstUserMessage.substring(0, 30)}...'
            : firstUserMessage;
      }

      final session = my_models.ChatSession(
        sessionId: _sessionId,
        timestamp: DateTime.now(),
        messages: chatMessages,
        title: title,
      );
      debugPrint('DEBUG: Saving session: ${session.sessionId}, Title: $title');

      if (widget.chatSession == null && !_historyIncremented) {
        debugPrint('DEBUG: Incrementing Chat History Usage (New Session)');
        Provider.of<UsageProvider>(context, listen: false)
            .incrementChatHistory();
        _historyIncremented = true;
      }

      try {
        await _chatProvider.addChatSession(session);
      } catch (e) {
        debugPrint('ERROR: Failed to save chat session: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save chat: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      debugPrint('DEBUG: No valid chat pairs to save. Check message types.');
      // Debug print types
      for (var m in _messages) {
        debugPrint('DEBUG: Msg Type: ${m.runtimeType}');
      }
    }
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    await Permission.microphone.request();
    setState(() {});
  }

  void _startListening() async {
    if (await Permission.microphone.request().isGranted) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {});
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required for voice input.'),
        ),
      );
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _textController.text = result.recognizedWords;
    });
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'txt'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<String?> _uploadFile(File file) async {
    try {
      final userId = Provider.of<ChatProvider>(context, listen: false).userId;
      if (userId == null) return null;

      final fileName = file.path.split('/').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_attachments')
          .child(userId)
          .child('${timestamp}_$fileName');

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  void _sendMessage(String text) async {
    if (text.isEmpty && _selectedFile == null) {
      return;
    }

    // Check Usage Limits
    final canSendMessage = await UsageLimitHelper.checkAndShowLimit(
      context,
      'aiChat',
      customTitle: 'AI Chat Limit Reached',
    );
    if (!canSendMessage) return;

    if (!mounted) return;

    final usageProvider = Provider.of<UsageProvider>(context, listen: false);

    String userMessage = text;
    File? attachedFile = _selectedFile;
    String? uploadedUrl;
    String? attachmentType;
    String? attachmentName;

    if (attachedFile != null) {
      attachmentName = attachedFile.path.split('/').last;
      final extension = attachmentName.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
        attachmentType = 'image';
      } else {
        attachmentType = 'document';
      }
    }

    // Optimistic UI update
    setState(() {
      if (attachedFile != null) {
        _messages.add(_AttachmentMessage(
          file: attachedFile,
          text: text,
          type: attachmentType,
          name: attachmentName,
        ));
      } else {
        _messages
            .add(_Message(text: userMessage, isUser: true, hasAnimated: true));
      }
      _textController.clear();
      _selectedFile = null;
      _messages.add(_TypingIndicator());
      _scrollToBottom();
    });

    try {
      final content = <Content>[];

      if (attachedFile != null) {
        // Upload file in background
        uploadedUrl = await _uploadFile(attachedFile);

        // Update the last message
        final index = _messages.indexWhere(
            (m) => m is _AttachmentMessage && m.file == attachedFile);
        if (index != -1) {
          _messages[index] = _AttachmentMessage(
            file: attachedFile,
            text: text,
            imageUrl: uploadedUrl,
            type: attachmentType,
            name: attachmentName,
          );
        }

        final mimeType =
            lookupMimeType(attachedFile.path) ?? 'application/octet-stream';

        if (attachmentType == 'image' || mimeType == 'application/pdf') {
          final prompt =
              "Analyze the following attachment and question. The file might be compressed, so clarity may not be perfect. Do your best to accurately analyze the visual content. If there's any text, extract it. If the image is too blurry, politely ask the user to send a clearer version. Always combine the analysis of the image and the user's question to provide a smart, professional, and helpful answer, like a real legal assistant would. Question: $userMessage";
          content.add(Content.multi([
            TextPart(prompt),
            InlineDataPart(mimeType, await attachedFile.readAsBytes()),
          ]));
        } else {
          // For other documents, just send text prompt for now as Gemini API direct file support is limited without File API
          // Or we could try to extract text if it's a text file.
          // For now, we'll just inform the model about the file name.
          content.add(Content.text(
              "User attached a file named '$attachmentName'. Question: $userMessage"));
        }
      } else {
        content.add(Content.text(userMessage));
      }

      var response = await _chat.sendMessage(content.first);
      var responseText = response.text;

      setState(() {
        _messages.removeWhere((element) => element is _TypingIndicator);
        _handleAIResponse(responseText ?? "");
        _scrollToBottom();
        usageProvider.incrementAiQueries();
        _saveChatSession();

        // Increment message count and show ad if needed
        _messagesSinceLastAd++;
        if (_messagesSinceLastAd >= _messagesBeforeAd) {
          _messagesSinceLastAd = 0;
          _showInterstitialAd();
        }
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((element) => element is _TypingIndicator);
        _messages.add(_Message(
            text: 'Error: ${e.toString()}', isUser: false, hasAnimated: true));
        _scrollToBottom();
      });
    }
  }

  Future<void> _showInterstitialAd() async {
    await AdService.loadAndShowInterstitialAd(
      onAdDismissed: () {
        // Ad dismissed, continue chatting
      },
      onAdFailedToLoad: () {
        // Ad failed, continue anyway
      },
    );
  }

  void _handleAIResponse(String responseText) {
    final docStartIndex = responseText.indexOf('[START_DOCUMENT:');
    final docEndIndex = responseText.indexOf('[END_DOCUMENT]');

    if (docStartIndex != -1 && docEndIndex != -1) {
      final titleStartIndex = docStartIndex + '[START_DOCUMENT:'.length;
      final titleEndIndex = responseText.indexOf(']', titleStartIndex);
      final title = responseText.substring(titleStartIndex, titleEndIndex);
      final content =
          responseText.substring(titleEndIndex + 1, docEndIndex).trim();
      _messages.add(_DocumentMessage(title: title, content: content));
    } else {
      _messages.add(_Message(text: responseText, isUser: false));
    }
    _scrollToBottom();
  }

  void _shareChat() {
    final String chatHistory = _messages
        .map((m) {
          if (m is _Message) {
            return "${m.isUser ? 'You' : 'Law Genie'}: ${m.text}";
          } else if (m is _DocumentMessage) {
            return "Law Genie: [Generated Document: ${m.title}]";
          } else if (m is _AttachmentMessage) {
            return "You: [Attachment: ${m.name ?? 'File'}] ${m.text ?? ''}";
          }
          return null;
        })
        .where((item) => item != null)
        .join('\n\n');
    // ignore: deprecated_member_use
    Share.share(chatHistory, subject: 'Chat History with Law Genie');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[_messages.length - 1 - index];
                  if (message is _Message) {
                    return message.isUser
                        ? _UserMessageBubble(message: message)
                        : _AIMessageBubble(message: message);
                  } else if (message is _DocumentMessage) {
                    return _DocumentMessageBubble(message: message);
                  } else if (message is _AttachmentMessage) {
                    return _AttachmentMessageBubble(message: message);
                  } else if (message is _TypingIndicator) {
                    return const _TypingIndicatorBubble();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            if (_selectedFile != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.grey[200],
                child: Row(
                  children: [
                    const Icon(Iconsax.document),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_selectedFile!.path.split('/').last)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            _buildChatInputArea(context),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF19173A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left, size: 30, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        'Law Genie',
                        textStyle: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        speed: const Duration(milliseconds: 200),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                ),
                Text(
                  'Your Legal Companion',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // AI Online badge removed
        IconButton(
          icon: const Icon(Icons.download_outlined, color: Colors.white),
          onPressed: _generatePdf,
          constraints: const BoxConstraints(), // Compact icon button
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _shareChat,
          constraints: const BoxConstraints(), // Compact icon button
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildChatInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF151038).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border:
            Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: IconButton(
                icon: const Icon(Iconsax.attach_square, color: Colors.white70),
                onPressed: _pickFile,
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: TextField(
                  controller: _textController,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Ask Law Genie...',
                    hintStyle: GoogleFonts.poppins(color: Colors.white38),
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _speechToText.isListening
                              ? Iconsax.microphone_2
                              : Iconsax.microphone,
                          color: _speechToText.isListening
                              ? const Color(0xFF02F1C3)
                              : Colors.white54,
                          size: 20),
                      onPressed: _speechToText.isNotListening
                          ? _startListening
                          : _stopListening,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF02F1C3), Color(0xFF00C7A0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF02F1C3).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Iconsax.send_2, color: Color(0xFF0A032A)),
                onPressed: () => _sendMessage(_textController.text),
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator {}

class _TypingIndicatorBubble extends StatelessWidget {
  const _TypingIndicatorBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12, bottom: 4),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFF19173A),
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF02F1C3).withValues(alpha: 0.3),
                  width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF02F1C3).withValues(alpha: 0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                height: 28,
                width: 28,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF19173A).withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.zero,
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  '...',
                  textStyle: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 0.5,
                  ),
                  speed: const Duration(milliseconds: 200),
                ),
              ],
              repeatForever: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _AIMessageBubble extends StatefulWidget {
  final _Message message;
  const _AIMessageBubble({required this.message});

  @override
  State<_AIMessageBubble> createState() => _AIMessageBubbleState();
}

class _AIMessageBubbleState extends State<_AIMessageBubble> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;

  Future<void> _speak() async {
    setState(() => isPlaying = true);
    await flutterTts.speak(widget.message.text);
    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 4),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFF19173A),
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color(0xFF02F1C3).withValues(alpha: 0.3),
                width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF02F1C3).withValues(alpha: 0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF19173A).withValues(alpha: 0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.zero,
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.message.hasAnimated)
                  Text(
                    widget.message.text,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  )
                else
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        widget.message.text,
                        textStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        speed: const Duration(milliseconds: 20),
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                    isRepeatingAnimation: false,
                    onFinished: () {
                      setState(() {
                        widget.message.hasAnimated = true;
                      });
                    },
                  ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _speak,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPlaying ? Iconsax.pause : Iconsax.volume_high,
                          size: 14,
                          color: isPlaying
                              ? const Color(0xFF02F1C3)
                              : Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPlaying ? 'Playing' : 'Listen',
                          style: TextStyle(
                            fontSize: 11,
                            color: isPlaying
                                ? const Color(0xFF02F1C3)
                                : Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UserMessageBubble extends StatelessWidget {
  final _Message message;
  const _UserMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8, left: 60),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF02F1C3).withValues(alpha: 0.15),
                  const Color(0xFF02F1C3).withValues(alpha: 0.05)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.zero,
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              border: Border.all(
                color: const Color(0xFF02F1C3).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentMessageBubble extends StatelessWidget {
  final _DocumentMessage message;
  const _DocumentMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 4),
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Color(0xFF19173A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Iconsax.document, color: Colors.white, size: 24),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF19173A),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Here is the document you requested. You can view, edit, or download it.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentViewerPage(
                            documentContent: message.content),
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.eye, size: 18),
                  label: const Text('View Document'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF0A032A),
                    backgroundColor: const Color(0xFF02F1C3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AttachmentMessageBubble extends StatelessWidget {
  final _AttachmentMessage message;
  const _AttachmentMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    bool isImage = message.type == 'image';
    // Fallback detection if type is null (legacy messages)
    if (message.type == null) {
      if (message.file != null) {
        isImage = ['jpg', 'jpeg', 'png', 'gif']
            .any((ext) => message.file!.path.toLowerCase().endsWith(ext));
      } else if (message.imageUrl != null) {
        // Assume image if we have URL but no type, or check extension from URL if possible
        // For now, let's assume it's an image if we don't know better, as that was previous behavior
        isImage = true;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8, left: 80),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF02F1C3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: message.file != null
                        ? Image.file(
                            message.file!,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            message.imageUrl!,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                width: 150,
                                height: 150,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                width: 150,
                                height: 150,
                                child: Icon(Icons.error),
                              );
                            },
                          ),
                  )
                else
                  // Document display
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Iconsax.document_text,
                            color: Color(0xFF0A032A)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            message.name ?? 'Document',
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF0A032A),
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (message.text != null && message.text!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    message.text!,
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF0A032A), fontSize: 15),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
