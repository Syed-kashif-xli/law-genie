import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechToTextService with ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  String _status = 'notListening';
  String _error = '';

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  String get status => _status;
  String get error => _error;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _speechToText.initialize(
      onError: (val) {
        _error = val.errorMsg;
        _isListening = false;
        notifyListeners();
      },
      onStatus: (val) {
        _status = val;
        if (val == 'done' || val == 'notListening') {
          _isListening = false;
        } else if (val == 'listening') {
          _isListening = true;
        }
        notifyListeners();
      },
    );
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> startListening() async {
    _lastWords = ''; // Reset words on new listen
    _error = '';

    if (!_isInitialized) {
      await initialize();
    }

    if (!_speechToText.isListening) {
      _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
        ),
      );
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
    if (result.finalResult) {
      _isListening = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }
}
