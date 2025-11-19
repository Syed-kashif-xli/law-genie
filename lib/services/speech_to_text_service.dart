import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechToTextService with ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  Future<void> initialize() async {
    await _speechToText.initialize();
    notifyListeners();
  }

  void startListening() {
    if (!_speechToText.isListening) {
      _speechToText.listen(onResult: _onSpeechResult);
      _isListening = true;
      notifyListeners();
    }
  }

  void stopListening() {
    if (_speechToText.isListening) {
      _speechToText.stop();
      _isListening = false;
      notifyListeners();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    notifyListeners();
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }
}
