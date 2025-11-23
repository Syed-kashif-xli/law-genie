import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers
        ],
        IosTextToSpeechAudioMode.voicePrompt);
  }

  Future<void> speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts
        .setSpeechRate(0.5); // Slightly slower is often more natural

    // Try to find a better voice
    try {
      final voices = await _flutterTts.getVoices;
      if (voices != null) {
        // Look for voices that might be higher quality
        // This is heuristic; different devices have different voice names
        final preferredVoice = voices.firstWhere(
            (v) =>
                v['name'].toString().contains('Network') ||
                v['name'].toString().contains('Enhanced') ||
                v['name'].toString().contains('Siri'),
            orElse: () => null);

        if (preferredVoice != null) {
          await _flutterTts.setVoice({
            "name": preferredVoice["name"],
            "locale": preferredVoice["locale"]
          });
        }
      }
    } catch (e) {
      print("Error setting voice: $e");
    }

    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
