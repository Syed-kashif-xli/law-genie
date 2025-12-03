import 'dart:async';
import 'dart:math' as math;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myapp/services/gemini_service.dart';
import 'package:myapp/services/speech_to_text_service.dart';
import 'package:myapp/services/tts_service.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/home/providers/usage_provider.dart';

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
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  AiState _aiState = AiState.idle;
  String _lastUserMessage = "";
  String _lastAiMessage = "";

  // Animation Controllers
  late AnimationController _galaxyController;
  late AnimationController _pulseController;
  late AnimationController _explosionController;

  // Galaxy Particles
  final List<GalaxyParticle> _particles = [];
  final int _particleCount = 150; // Increased particle count for better sphere
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initGalaxy();
    _startSession();
  }

  void _setupAnimations() {
    _galaxyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Faster rotation
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _explosionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addListener(_updateParticles);
  }

  void _initGalaxy() {
    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      // Spherical distribution using Golden Spiral method for even distribution
      double y = 1 - (i / (_particleCount - 1)) * 2;
      double radius = math.sqrt(1 - y * y);
      double theta = 2.39996322972865332 * i; // Golden angle increment

      double x = math.cos(theta) * radius;
      double z = math.sin(theta) * radius;

      _particles.add(GalaxyParticle(
        originalX: x,
        originalY: y,
        originalZ: z,
        x: x,
        y: y,
        z: z,
        targetX: x,
        targetY: y,
        targetZ: z,
        speed: 0.02 + _random.nextDouble() * 0.05,
      ));
    }
  }

  void _updateParticles() {
    if (_aiState == AiState.thinking || _aiState == AiState.speaking) {
      // Explosion/Reformation cycle
      double progress = _explosionController.value;

      // 0.0 -> 0.5: Explode
      // 0.5 -> 1.0: Reform

      for (var p in _particles) {
        if (progress < 0.5) {
          // Exploding outwards
          double explodeFactor = progress * 4.0; // Scale up explosion
          // Add some noise/randomness to explosion
          p.x = p.originalX * (1 + explodeFactor) +
              (_random.nextDouble() - 0.5) * explodeFactor;
          p.y = p.originalY * (1 + explodeFactor) +
              (_random.nextDouble() - 0.5) * explodeFactor;
          p.z = p.originalZ * (1 + explodeFactor) +
              (_random.nextDouble() - 0.5) * explodeFactor;
        } else {
          // Reforming
          double reformFactor = (1.0 - progress) * 4.0;
          p.x = p.originalX * (1 + reformFactor);
          p.y = p.originalY * (1 + reformFactor);
          p.z = p.originalZ * (1 + reformFactor);
        }
      }
    } else if (_aiState == AiState.listening) {
      // Gentle vibration/pulse in place
      double pulse = _pulseController.value;
      for (var p in _particles) {
        double noise = 0.1 * pulse;
        p.x = p.originalX + (_random.nextDouble() - 0.5) * noise;
        p.y = p.originalY + (_random.nextDouble() - 0.5) * noise;
        p.z = p.originalZ + (_random.nextDouble() - 0.5) * noise;
      }
    } else {
      // Idle: Return to perfect sphere
      for (var p in _particles) {
        p.x = p.originalX;
        p.y = p.originalY;
        p.z = p.originalZ;
      }
    }
  }

  void _startSession() {
    _geminiService.startChat();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _startListening();
    });
  }

  @override
  void dispose() {
    final speechService =
        Provider.of<SpeechToTextService>(context, listen: false);
    speechService.removeListener(_onSpeechResult);
    _ttsService.stop();
    _galaxyController.dispose();
    _pulseController.dispose();
    _explosionController.dispose();
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
      _explosionController.stop();
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

    if (speechService.error.isNotEmpty) {
      _stopListening();
      setState(() => _aiState = AiState.idle);
      return;
    }

    if (!speechService.isListening && _aiState == AiState.listening) {
      if (speechService.lastWords.isNotEmpty) {
        _stopListening();
        _handleUserInput(speechService.lastWords);
      } else {
        _stopListening();
        setState(() => _aiState = AiState.idle);
      }
    }
  }

  Future<void> _handleUserInput(String input) async {
    final usageProvider = Provider.of<UsageProvider>(context, listen: false);
    if (usageProvider.aiVoiceUsage >= usageProvider.aiVoiceLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Free plan limit reached. Upgrade to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _lastUserMessage = input;
      _aiState = AiState.thinking;
      _explosionController.repeat(); // Start explosion cycle
    });

    _logToFirebase("user", input);

    try {
      final stream = await _geminiService.sendMessageStream(input);

      String fullResponse = "";
      setState(() {
        _aiState = AiState.speaking;
        _lastAiMessage = "";
      });

      stream.listen((response) {
        final text = response.text;
        if (text != null) {
          fullResponse += text;
          setState(() {
            _lastAiMessage = fullResponse;
          });
        }
      }, onDone: () async {
        _logToFirebase("ai", fullResponse);
        usageProvider.incrementAiVoice();
        await _ttsService.speak(fullResponse);
        if (mounted) {
          _startListening();
        }
      }, onError: (e) {
        setState(() => _aiState = AiState.idle);
        _explosionController.stop();
      });
    } catch (e) {
      setState(() => _aiState = AiState.idle);
      _explosionController.stop();
    }
  }

  void _showKeyboardInput() {
    final TextEditingController textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A00),
        title: Text(
          'Type your query',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: TextField(
          controller: textController,
          style: GoogleFonts.outfit(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ask something...',
            hintStyle: GoogleFonts.outfit(color: Colors.white54),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent),
            ),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            if (value.trim().isNotEmpty) {
              _handleUserInput(value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (textController.text.trim().isNotEmpty) {
                _handleUserInput(textController.text.trim());
              }
            },
            child: Text('Send',
                style: GoogleFonts.outfit(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  void _logToFirebase(String role, String message) {
    try {
      _database.child('chat_logs').push().set({
        'role': role,
        'message': message,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint("Firebase error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Background Gradient (Gold/Black Radial)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    const Color(0xFF1A1A00), // Very dark gold/olive center
                    Colors.black,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // 2. Galaxy Animation (Centered)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge(
                  [_galaxyController, _explosionController, _pulseController]),
              builder: (context, child) {
                return CustomPaint(
                  painter: GalaxyPainter(
                    particles: _particles,
                    rotation: _galaxyController.value * 2 * math.pi,
                    state: _aiState,
                  ),
                );
              },
            ),
          ),

          // 3. UI Overlay (SafeArea)
          SafeArea(
            child: Column(
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        "I can search new cases |",
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "What Can I Do for\nYou Today?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFF8E1), // Off-white/Gold tint
                          fontSize: 42,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Status / Response Text (Above controls)
                if (_lastUserMessage.isNotEmpty || _lastAiMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    margin: const EdgeInsets.only(bottom: 40),
                    child: Text(
                      _aiState == AiState.speaking
                          ? _lastAiMessage
                          : _lastUserMessage,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                // "Use Keyboard" Button
                GestureDetector(
                  onTap: () {
                    _showKeyboardInput();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.keyboard_outlined,
                            color: Colors.white70, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          "Use Keyboard",
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Bottom Navigation / Controls
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // History / Menu
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Iconsax.note_text,
                            color: Colors.white54),
                        iconSize: 28,
                      ),

                      // Main Action (Mic/Active)
                      GestureDetector(
                        onTap: _aiState == AiState.idle
                            ? _startListening
                            : _stopListening,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _aiState == AiState.listening
                                  ? Colors.cyanAccent.withValues(alpha: 0.5)
                                  : Colors.amber.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_aiState == AiState.listening
                                        ? Colors.cyanAccent
                                        : Colors.amber)
                                    .withValues(alpha: 0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Icon(
                            _aiState == AiState.listening
                                ? Icons.stop
                                : Iconsax.microphone,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),

                      // Settings
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Iconsax.setting_2,
                            color: Colors.white54),
                        iconSize: 28,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GalaxyParticle {
  double originalX, originalY, originalZ; // The home position on the sphere
  double x, y, z; // Current position
  double targetX,
      targetY,
      targetZ; // Target position (not always used directly, but good for lerping)
  double speed;

  GalaxyParticle({
    required this.originalX,
    required this.originalY,
    required this.originalZ,
    required this.x,
    required this.y,
    required this.z,
    required this.targetX,
    required this.targetY,
    required this.targetZ,
    required this.speed,
  });
}

class GalaxyPainter extends CustomPainter {
  final List<GalaxyParticle> particles;
  final double rotation;
  final AiState state;

  GalaxyPainter({
    required this.particles,
    required this.rotation,
    required this.state,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) *
        0.35; // Slightly smaller base radius

    // Dynamic color based on state
    Color baseColor = const Color(0xFFFFD700); // Gold
    if (state == AiState.listening) baseColor = Colors.cyanAccent;
    if (state == AiState.thinking) baseColor = Colors.purpleAccent;
    if (state == AiState.speaking) baseColor = Colors.white;

    final paint = Paint()
      ..color = baseColor
      ..strokeCap = StrokeCap.round;

    final linePaint = Paint()
      ..color = baseColor.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    // Project 3D points to 2D
    List<Offset> projectedPoints = [];
    List<double> zDepths = [];

    // Rotation Matrix (Y-axis)
    final cosR = math.cos(rotation);
    final sinR = math.sin(rotation);

    for (var p in particles) {
      // Rotate around Y axis
      double x = p.x * cosR - p.z * sinR;
      double z = p.x * sinR + p.z * cosR;
      double y = p.y;

      // Add a slight tilt (X-axis rotation) for better 3D effect
      double tilt = 0.3;
      double yRot = y * math.cos(tilt) - z * math.sin(tilt);
      double zRot = y * math.sin(tilt) + z * math.cos(tilt);
      y = yRot;
      z = zRot;

      // Perspective projection
      double fov = 300;
      double scale = fov / (fov + z * radius + 400); // Adjusted perspective

      double px = center.dx +
          x * radius * scale * 2.5; // Scale up to fill screen better
      double py = center.dy + y * radius * scale * 2.5;

      projectedPoints.add(Offset(px, py));
      zDepths.add(z);
    }

    // Draw connections (Plexus effect) - Only when not exploding too much
    // If exploding, reduce connections to avoid mess
    bool isExploding = state == AiState.thinking || state == AiState.speaking;
    double connectionDistance = isExploding ? 40 : 60;

    for (int i = 0; i < projectedPoints.length; i++) {
      for (int j = i + 1; j < projectedPoints.length; j++) {
        double dist = (projectedPoints[i] - projectedPoints[j]).distance;
        if (dist < connectionDistance) {
          double opacity =
              (1 - dist / connectionDistance) * (isExploding ? 0.1 : 0.3);
          canvas.drawLine(
            projectedPoints[i],
            projectedPoints[j],
            linePaint..color = baseColor.withValues(alpha: opacity),
          );
        }
      }
    }

    // Draw particles
    for (int i = 0; i < projectedPoints.length; i++) {
      double z = zDepths[i];
      double size = (2.0 / (1 + z)) * 2;
      if (size < 0.5) size = 0.5;

      // Fade distant particles
      double opacity = 1.0;
      if (z < -0.5) opacity = 0.5;

      paint.color = baseColor.withValues(alpha: opacity);
      canvas.drawCircle(projectedPoints[i], size, paint);

      // Glow
      paint.color = baseColor.withValues(alpha: opacity * 0.3);
      canvas.drawCircle(projectedPoints[i], size * 3, paint);
    }

    // Draw central core glow (only if not exploding completely)
    if (!isExploding) {
      final corePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            baseColor.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.8));
      canvas.drawCircle(center, radius * 0.8, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant GalaxyPainter oldDelegate) => true;
}
