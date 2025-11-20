import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TtsStreamService {
  final String _apiKey = 'YOUR_ELEVENLABS_API_KEY'; // Replace with your ElevenLabs API key
  final String _voiceId = '21m00Tcm4TlvDq8ikWAM'; // Example voice ID

  Future<Stream<List<int>>> textToSpeechStream(String text) async {
    final url = Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$_voiceId/stream');

    final headers = {
      'Content-Type': 'application/json',
      'xi-api-key': _apiKey,
    };

    final body = jsonEncode({
      'text': text,
      'model_id': 'eleven_monolingual_v1',
      'voice_settings': {
        'stability': 0.5,
        'similarity_boost': 0.5,
      },
    });

    final request = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = body;

    final response = await request.send();

    if (response.statusCode == 200) {
      return response.stream;
    } else {
      throw Exception('Failed to stream text to speech: ${response.reasonPhrase}');
    }
  }
}
