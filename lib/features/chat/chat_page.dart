import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _Message {
  final String text;
  final bool isUser;

  _Message({required this.text, required this.isUser});
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  final List<_Message> _messages = [
    _Message(
      text: "Hello! I'm Law Genie, your AI legal assistant. How can I help you today?",
      isUser: false,
    ),
  ];
  bool _speechEnabled = false;
  File? _selectedFile;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
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

  void _sendMessage(String text) {
    if (text.isEmpty && _selectedFile == null) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _textController.clear();
      _isTyping = true;
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _messages.add(_Message(
          text: "I am processing your request...",
          isUser: false,
        ));
        _isTyping = false;
      });
    });
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return _messages.map((message) {
            return pw.Container(
              alignment: message.isUser ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(10),
                margin: const pw.EdgeInsets.symmetric(vertical: 4),
                decoration: pw.BoxDecoration(
                  color: message.isUser ? PdfColors.blue100 : PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text(message.text),
              ),
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
      print("Error generating or opening PDF: $e");
    }
  }

  void _shareChat() {
    final String chatHistory = _messages.map((m) => "${m.isUser ? 'You' : 'Law Genie'}: ${m.text}").join('\n\n');
    Share.share(chatHistory, subject: 'Chat History with Law Genie');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0B2E),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return message.isUser
                    ? _UserMessageBubble(message: message)
                    : _AIMessageBubble(message: message);
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 8),
                  Text("Law Genie is typing..."),
                ],
              ),
            ),
          _buildChatInputArea(context),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1A0B2E),
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
            color: Colors.deepPurple.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'AI Online',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
        color: Color(0xFF1A0B2E),
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
                border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                style: const TextStyle(color: Colors.white), // Makes the input text visible
                decoration: InputDecoration(
                  hintText: 'Ask your legal question...',
                  hintStyle: GoogleFonts.poppins(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  colors: [Colors.blue, Colors.purple],
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
            color: Colors.deepPurple,
            shape: BoxShape.circle,
          ),
          child: const Icon(Iconsax.flash_1, color: Colors.white, size: 24),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.0),
               border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                        color: isPlaying ? Colors.deepPurple : Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPlaying ? 'Playing...' : 'Listen',
                        style: TextStyle(
                          fontSize: 12,
                          color: isPlaying ? Colors.deepPurple : Colors.white70,
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
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}
