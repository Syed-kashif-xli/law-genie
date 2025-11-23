import 'dart:math' as math;
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

class _AiVoicePageState extends State<AiVoicePage>
    with TickerProviderStateMixin {
  final GeminiService _geminiService = GeminiService();
  final TtsService _ttsService = TtsService();
  AiState _aiState = AiState.idle;
  String _lastUserMessage = "";
  String _lastAiMessage = "";

  late AnimationController _earthController;
  late AnimationController _pulseController;
  late AnimationController _genieFloatController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSession();
  }

  void _setupAnimations() {
    _earthController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _genieFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  void _startSession() {
    _geminiService.startChat();
    // Delay slightly to let UI build, then start listening
    Future.delayed(const Duration(seconds: 1), () {
      _startListening();
    });
  }

  @override
  void dispose() {
    final speechService =
        Provider.of<SpeechToTextService>(context, listen: false);
    speechService.removeListener(_onSpeechResult);
    _ttsService.stop();
    _earthController.dispose();
    _pulseController.dispose();
    _genieFloatController.dispose();
    super.dispose();
  }

  void _startListening() {
    final speechService =
        Provider.of<SpeechToTextService>(context, listen: false);
    speechService.addListener(_onSpeechResult);
    speechService.startListening();
    setState(() {
      _aiState = AiState.listening;
      _pulseController.repeat(reverse: true);
    });
  }

  void _stopListening() {
    final speechService =
        Provider.of<SpeechToTextService>(context, listen: false);
    speechService.stopListening();
    speechService.removeListener(_onSpeechResult);
    _pulseController.stop();
    _pulseController.reset();
  }

  void _onSpeechResult() {
    final speechService =
        Provider.of<SpeechToTextService>(context, listen: false);

    // Check for errors
    if (speechService.error.isNotEmpty) {
      _stopListening();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech Error: ${speechService.error}')),
      );
      setState(() => _aiState = AiState.idle);
      return;
    }

    // Check if service stopped listening externally (timeout, etc)
    if (!speechService.isListening && _aiState == AiState.listening) {
      if (speechService.lastWords.isNotEmpty) {
        _stopListening();
        _handleUserInput(speechService.lastWords);
      } else {
        // Stopped without words (silence), maybe restart or go idle?
        _stopListening();
        setState(() => _aiState = AiState.idle);
      }
    }
  }

  Future<void> _handleUserInput(String input) async {
    setState(() {
      _lastUserMessage = input;
      _aiState = AiState.thinking;
    });

    try {
      final response = await _geminiService.sendMessage(input);
      setState(() {
        _lastAiMessage = response;
        _aiState = AiState.speaking;
      });

      await _ttsService.speak(response);

      // After speaking, go back to listening
      if (mounted) {
        _startListening();
      }
    } catch (e) {
      // Handle error, maybe speak it?
      setState(() => _aiState = AiState.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Starry background (optional, simple gradient for now)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0B1026), Color(0xFF2B32B2)],
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Content
          Column(
            children: [
              const Spacer(flex: 2),
              // Genie Orb
              _buildGenieOrb(),
              const Spacer(flex: 1),
              // Status Text
              _buildStatusText(),
              const SizedBox(height: 20),
              // Transcript (Optional, fades out)
              _buildTranscript(),
              const Spacer(flex: 2),
              // Earth
              _buildEarth(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenieOrb() {
    return AnimatedBuilder(
      animation: Listenable.merge([_genieFloatController, _pulseController]),
      builder: (context, child) {
        double floatOffset = _genieFloatController.value * 20;
        double pulseScale = 1.0;
        Color glowColor = Colors.cyanAccent;

        if (_aiState == AiState.listening) {
          pulseScale = 1.0 + (_pulseController.value * 0.2);
          glowColor = Colors.blueAccent;
        } else if (_aiState == AiState.thinking) {
          pulseScale = 1.0 + (_pulseController.value * 0.1); // Faster pulse?
          glowColor = Colors.purpleAccent;
        } else if (_aiState == AiState.speaking) {
          pulseScale = 1.0 +
              (math.Random().nextDouble() * 0.3); // Simulate voice vibration
          glowColor = Colors.greenAccent;
        }

        return Transform.translate(
          offset: Offset(0, -floatOffset),
          child: Transform.scale(
            scale: pulseScale,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    glowColor.withOpacity(0.8),
                    glowColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.5),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _getIconForState(),
                    color: glowColor.withOpacity(0.8),
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForState() {
    switch (_aiState) {
      case AiState.listening:
        return Iconsax.microphone;
      case AiState.thinking:
        return Iconsax.cpu;
      case AiState.speaking:
        return Iconsax.volume_high;
      default:
        return Iconsax.magic_star;
    }
  }

  Widget _buildStatusText() {
    String text;
    switch (_aiState) {
      case AiState.listening:
        text = "Listening...";
        break;
      case AiState.thinking:
        text = "Thinking...";
        break;
      case AiState.speaking:
        text = "Speaking...";
        break;
      default:
        text = "Tap Earth to Start";
    }
    return Text(
      text,
      style: GoogleFonts.lexend(
        color: Colors.white70,
        fontSize: 18,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTranscript() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        _aiState == AiState.speaking ? _lastAiMessage : _lastUserMessage,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: Colors.white30,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildEarth() {
    return GestureDetector(
      onTap: () {
        if (_aiState == AiState.idle) {
          _startListening();
        } else {
          _stopListening();
          _ttsService.stop();
          setState(() => _aiState = AiState.idle);
        }
      },
      child: AnimatedBuilder(
        animation: _earthController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _earthController.value * 2 * math.pi,
            child: Container(
              height: 400, // Large enough to look like a horizon
              width: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF4CA1AF), // Land/Water light
                    Color(0xFF2C3E50), // Deep ocean
                  ],
                  stops: [0.3, 1.0],
                  center: Alignment(-0.3, -0.3), // Offset highlight
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CA1AF).withOpacity(0.3),
                    blurRadius: 50,
                    spreadRadius: -10,
                    offset: const Offset(0, -20), // Glow upwards
                  ),
                ],
              ),
              child: CustomPaint(
                painter: EarthDetailsPainter(),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Simple painter to add some "continents" or texture to the earth
class EarthDetailsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Draw some random blobs for continents
    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.2,
        size.width * 0.7, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.6,
        size.width * 0.4, size.height * 0.5);
    path.close();

    path.moveTo(size.width * 0.2, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.8,
        size.width * 0.1, size.height * 0.8);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
