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
  final GeminiService _geminiService = GeminiService();
  final TtsService _ttsService = TtsService();
  AiState _aiState = AiState.idle;

  @override
  void initState() {
    super.initState();
    final speechService = Provider.of<SpeechToTextService>(context, listen: false);
    speechService.addListener(_onSpeechResult);
  }

  @override
  void dispose() {
    Provider.of<SpeechToTextService>(context, listen: false).removeListener(_onSpeechResult);
    _ttsService.stop();
    super.dispose();
  }

  void _onSpeechResult() {
    final speechService = Provider.of<SpeechToTextService>(context, listen: false);
    if (!speechService.isListening && speechService.lastWords.isNotEmpty) {
      _requestAiResponse(speechService.lastWords);
    }
    if (mounted) {
      setState(() {
        _aiState = speechService.isListening ? AiState.listening : AiState.idle;
      });
    }
  }

  Future<void> _requestAiResponse(String prompt) async {
    setState(() => _aiState = AiState.thinking);
    try {
      final response = await _geminiService.generateText(prompt);
      setState(() => _aiState = AiState.speaking);
      await _ttsService.speak(response);
      setState(() => _aiState = AiState.idle);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => _aiState = AiState.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'AI Voice Assistant',
          style: GoogleFonts.lexend(color: const Color(0xFF333333), fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVisualizer(),
            const SizedBox(height: 60),
            _buildMicButton(),
            const SizedBox(height: 20),
            _buildStateLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizer() {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getVisualizerColor().withOpacity(0.1),
        border: Border.all(color: _getVisualizerColor(), width: 3),
      ),
      child: Icon(
        _getVisualizerIcon(),
        color: _getVisualizerColor(),
        size: 80,
      ),
    );
  }

  Widget _buildMicButton() {
    final speechService = Provider.of<SpeechToTextService>(context, listen: false);
    return SizedBox(
      height: 80,
      width: 80,
      child: FloatingActionButton(
        onPressed: () {
          if (_aiState == AiState.idle) {
            speechService.startListening();
          } else if (_aiState == AiState.listening) {
            speechService.stopListening();
          }
        },
        backgroundColor: _getMicButtonColor(),
        elevation: 8,
        child: Icon(
          _aiState == AiState.listening ? Iconsax.stop : Iconsax.microphone,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildStateLabel() {
    String text;
    switch (_aiState) {
      case AiState.listening:
        text = 'Listening...';
        break;
      case AiState.thinking:
        text = 'Thinking...';
        break;
      case AiState.speaking:
        text = 'Speaking...';
        break;
      default:
        text = 'Tap to speak';
    }
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[700]),
    );
  }

  Color _getVisualizerColor() {
    switch (_aiState) {
      case AiState.listening:
        return Colors.blue;
      case AiState.thinking:
        return Colors.orange;
      case AiState.speaking:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getVisualizerIcon() {
    switch (_aiState) {
      case AiState.listening:
        return Iconsax.microphone_2;
      case AiState.thinking:
        return Iconsax.cpu_setting;
      case AiState.speaking:
        return Iconsax.volume_high;
      default:
        return Iconsax.microphone;
    }
  }

  Color _getMicButtonColor() {
    if (_aiState == AiState.listening) {
      return Colors.red.shade400;
    } else if (_aiState == AiState.thinking || _aiState == AiState.speaking) {
      return Colors.grey.shade400;
    } else {
      return Theme.of(context).primaryColor;
    }
  }
}
