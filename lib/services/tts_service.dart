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
        // Prioritize voices that sound more human
        // "Network" usually implies online/high-quality on Android
        // "Enhanced" or "Siri" usually implies high-quality on iOS
        final preferredVoice = voices.firstWhere(
          (v) {
            final name = v['name'].toString().toLowerCase();
            return name.contains('network') ||
                name.contains('enhanced') ||
                name.contains('premium') ||
                name.contains('siri');
          },
          orElse: () => null,
        );

        if (preferredVoice != null) {
          await _flutterTts.setVoice({
            "name": preferredVoice["name"],
            "locale": preferredVoice["locale"]
          });
        } else {
          // Fallback: try to find any en-US voice if the default isn't great
          final usVoice = voices.firstWhere(
            (v) => v['locale'].toString().contains('en-US'),
            orElse: () => null,
          );
          if (usVoice != null) {
            await _flutterTts.setVoice(
                {"name": usVoice["name"], "locale": usVoice["locale"]});
          }
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
