
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:uuid/uuid.dart';

import 'package:myapp/models/chat_model.dart' as my_models;
import 'package:myapp/providers/chat_provider.dart';
import '../documents/document_viewer_page.dart';

const String _apiKey = 'AIzaSyC6NWmWsSowYUpYMOKCJ2EO1fD8-9UXB6s';

class AIChatPage extends StatefulWidget {
  final my_models.ChatSession? chatSession;
  const AIChatPage({super.key, this.chatSession});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _Message {
  final String text;
  final bool isUser;

  _Message({required this.text, required this.isUser});
}

class _DocumentMessage {
  final String title;
  final String content;

  _DocumentMessage({required this.title, required this.content});
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  final List<dynamic> _messages = [];
  File? _selectedFile;
  late final GenerativeModel _model;
  late final ChatSession _chat;
  late String _sessionId;
  late ChatProvider _chatProvider;

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
    super.dispose();
  }

  Future<void> _initGenerativeModel() async {
    final geminiPrompt = await rootBundle.loadString('GEMINI.md');
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.text(geminiPrompt),
    );
    _chat = _model.startChat();
  }

  void _loadSession() {
    if (widget.chatSession != null) {
      _sessionId = widget.chatSession!.sessionId;
      for (var message in widget.chatSession!.messages) {
        _messages.add(_Message(text: message.userMessage, isUser: true));
        _messages.add(_Message(text: message.botResponse, isUser: false));
      }
    } else {
      _sessionId = const Uuid().v4();
      _messages.add(_Message(
        text:
            "🧞‍♂️ I’m Law Genie — your Indian AI Legal Assistant.",
        isUser: false,
      ));
    }
  }

  void _saveChatSession() {
    if (_messages.length > 1) {
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

      if (chatMessages.isNotEmpty) {
        final session = my_models.ChatSession(
          sessionId: _sessionId,
          timestamp: DateTime.now(),
          messages: chatMessages,
        );
        _chatProvider.addChatSession(session);
      }
    }
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _textController.text = result.recognizedWords;
    });
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _sendMessage('File: ${_selectedFile!.path.split('/').last}');
      });
    }
  }

  void _sendMessage(String text) async {
    if (text.isEmpty && _selectedFile == null) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _textController.clear();
      _messages.add(_TypingIndicator());
    });

    try {
      var response = await _chat.sendMessage(Content.text(text));
      var responseText = response.text;

      setState(() {
        _messages.removeWhere((element) => element is _TypingIndicator);
        _handleAIResponse(responseText ?? "");
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((element) => element is _TypingIndicator);
        _messages.add(_Message(text: 'Error: ${e.toString()}', isUser: false));
      });
    }
  }

  void _handleAIResponse(String responseText) {
    final docStartIndex = responseText.indexOf('[START_DOCUMENT:');
    final docEndIndex = responseText.indexOf('[END_DOCUMENT]');

    if (docStartIndex != -1 && docEndIndex != -1) {
      final titleStartIndex = docStartIndex + '[START_DOCUMENT:'.length;
      final titleEndIndex = responseText.indexOf(']', titleStartIndex);
      final title = responseText.substring(titleStartIndex, titleEndIndex);
      final content = responseText.substring(titleEndIndex + 1, docEndIndex).trim();
      _messages.add(_DocumentMessage(title: title, content: content));
    } else {
      _messages.add(_Message(text: responseText, isUser: false));
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    final List<String?> messagesToExport = _messages.map((m) {
      if (m is _Message) {
        return "${m.isUser ? 'You' : 'Law Genie'}: ${m.text}";
      } else if (m is _DocumentMessage) {
        return "Law Genie: [Generated Document: ${m.title}]";
      }
      return null;
    }).where((item) => item != null).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return messagesToExport.map((message) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(10),
              margin: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Text(message!),
            );
          }).toList();
        },
      ),
    );

    try {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/chat_history.pdf");
      await file.writeAsBytes(await pdf.save());
      OpenFile.open(file.path);
    } catch (e) {
      // Handle error
      // ignore: avoid_print
      print("Error generating or opening PDF: $e");
    }
  }

  void _shareChat() {
    final String chatHistory = _messages.map((m) {
      if (m is _Message) {
        return "${m.isUser ? 'You' : 'Law Genie'}: ${m.text}";
      } else if (m is _DocumentMessage) {
        return "Law Genie: [Generated Document: ${m.title}]";
      }
      return null;
    }).where((item) => item != null).join('\n\n');
    Share.share(chatHistory, subject: 'Chat History with Law Genie');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A032A),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                if (message is _Message) {
                  return message.isUser
                      ? _UserMessageBubble(message: message)
                      : _AIMessageBubble(message: message);
                } else if (message is _DocumentMessage) {
                  return _DocumentMessageBubble(message: message);
                } else if (message is _TypingIndicator) {
                  return const _TypingIndicatorBubble();
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildChatInputArea(context),
        ],
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Law Genie',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Ready to assist you',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF02F1C3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'AI Online',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0A032A),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.download_outlined, color: Colors.white),
          onPressed: _generatePdf,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _shareChat,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildChatInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: Color(0xFF19173A),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 10,
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(51)),
              ),
              child: IconButton(
                icon: const Icon(Icons.attach_file, color: Colors.white),
                onPressed: _pickFile,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(
                    color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask your legal question...',
                  hintStyle: GoogleFonts.poppins(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                        BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFF02F1C3)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _speechToText.isListening ? Icons.mic : Icons.mic_off,
                        color: Colors.white),
                    onPressed: _speechToText.isNotListening
                        ? _startListening
                        : _stopListening,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF02F1C3), Color(0xFF0A032A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Iconsax.send_2, color: Colors.white),
                onPressed: () => _sendMessage(_textController.text),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 4),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF19173A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.flash_1, color: Colors.white, size: 24),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF19173A),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  '...',
                  textStyle: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 300),
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

class _AIMessageBubbleState extends State<_AIMessageBubble> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;

  Future<void> _speak() async {
    setState(() => isPlaying = true);
    await flutterTts.speak(widget.message.text);
    flutterTts.setCompletionHandler(() {
      setState(() => isPlaying = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 4),
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFF19173A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Iconsax.flash_1, color: Colors.white, size: 24),
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
                  widget.message.text,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _speak,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '21:52', // This should be dynamic
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        isPlaying ? Iconsax.pause : Iconsax.volume_high,
                        size: 16,
                        color: isPlaying ? const Color(0xFF02F1C3) : Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPlaying ? 'Playing...' : 'Listen',
                        style: TextStyle(
                          fontSize: 12,
                          color: isPlaying ? const Color(0xFF02F1C3) : Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
            margin: const EdgeInsets.only(top: 8, bottom: 8, left: 80),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF02F1C3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.poppins(color: const Color(0xFF0A032A), fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}

class _AIMessageBubble extends StatefulWidget {
  final _Message message;
  const _AIMessageBubble({required this.message});

  @override
  State<_AIMessageBubble> createState() => _AIMessageBubbleState();
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
                        builder: (context) =>
                            DocumentViewerPage(document: message.content),
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
