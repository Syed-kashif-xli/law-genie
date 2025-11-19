import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/services/gemini_service.dart';
import 'package:myapp/services/speech_to_text_service.dart';
import 'package:myapp/services/tts_service.dart';
import 'package:provider/provider.dart';

enum AiState {
  idle,
  listening,
  thinking,
  speaking,
}

class AiVoicePage extends StatefulWidget {
  const AiVoicePage({super.key});

  @override
  State<AiVoicePage> createState() => _AiVoicePageState();
}

class _AiVoicePageState extends State<AiVoicePage> {
  final TextEditingController _textController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  AiState _aiState = AiState.idle;

  @override
  void initState() {
    super.initState();
    final speechService = Provider.of<SpeechToTextService>(context, listen: false);
    speechService.addListener(_onSpeechResult);
    _textController.text = speechService.lastWords;
  }

  @override
  void dispose() {
    _textController.dispose();
    Provider.of<SpeechToTextService>(context, listen: false).removeListener(_onSpeechResult);
    Provider.of<TtsService>(context, listen: false).stop();
    super.dispose();
  }

  void _onSpeechResult() {
    final speechService = Provider.of<SpeechToTextService>(context, listen: false);
    if (!speechService.isListening && speechService.lastWords.isNotEmpty) {
      _textController.text = speechService.lastWords;
      _requestAiResponse(speechService.lastWords);
    }
    if (mounted) {
      setState(() {
        _aiState = speechService.isListening ? AiState.listening : AiState.idle;
      });
    }
  }

  Future<void> _requestAiResponse(String prompt) async {
    if (prompt.isEmpty) return;

    setState(() => _aiState = AiState.thinking);

    try {
      final response = await _geminiService.generateText(prompt);
      if (response.isNotEmpty) {
        Provider.of<TtsService>(context, listen: false).speak(response);
        setState(() => _aiState = AiState.speaking);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating response: $e')),
      );
      setState(() => _aiState = AiState.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'AI Voice',
          style: GoogleFonts.lexend(
            color: const Color(0xFF333333),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTextField(),
            const SizedBox(height: 32),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _textController,
        maxLines: 10,
        minLines: 5,
        style: GoogleFonts.lora(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Your spoken words will appear here...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Consumer2<TtsService, SpeechToTextService>(
      builder: (context, ttsService, speechService, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMicButton(speechService),
            const SizedBox(width: 32),
            _buildSpeakerButton(ttsService),
          ],
        );
      },
    );
  }

  Widget _buildMicButton(SpeechToTextService speechService) {
    final isListening = _aiState == AiState.listening;
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isListening ? Colors.red.shade400 : Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: (isListening ? Colors.red.shade400 : Theme.of(context).primaryColor).withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          if (isListening) {
            speechService.stopListening();
          } else {
            speechService.startListening();
          }
        },
        icon: Icon(
          isListening ? Iconsax.stop_circle : Iconsax.microphone,
          color: Colors.white,
          size: 40,
        ),
        tooltip: isListening ? 'Stop Listening' : 'Start Listening',
      ),
    );
  }

  Widget _buildSpeakerButton(TtsService ttsService) {
    final isSpeaking = _aiState == AiState.speaking;
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSpeaking ? Colors.red.shade400 : Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: (isSpeaking ? Colors.red.shade400 : Theme.of(context).primaryColor).withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          if (isSpeaking) {
            ttsService.stop();
            setState(() => _aiState = AiState.idle);
          }
        },
        icon: Icon(
          isSpeaking ? Iconsax.stop : Iconsax.volume_high,
          color: Colors.white,
          size: 40,
        ),
        tooltip: isSpeaking ? 'Stop Speaking' : 'Read Aloud',
      ),
    );
  }
}
