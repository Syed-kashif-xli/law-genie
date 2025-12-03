// ignore_for_file: avoid_print
import 'package:http/http.dart' as http;

void main() async {
  final urls = [
    'https://www.livelaw.in/rss.xml',
    'https://www.livelaw.in/feed',
    'https://www.barandbench.com/feed',
  ];

  for (final url in urls) {
    try {
      print('Checking $url...');
      final response = await http.get(Uri.parse(url));
      print('Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Content type: ${response.headers['content-type']}');
        print('Body snippet: ${response.body.substring(0, 200)}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
