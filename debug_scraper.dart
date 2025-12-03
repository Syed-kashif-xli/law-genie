// ignore_for_file: avoid_print
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

void main() async {
  print('Testing Indian Kanoon connection...');
  try {
    final url = Uri.parse('https://indiankanoon.org/search/?formInput=privacy');
    final response = await http.get(
      url,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      },
    );

    print('Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Body length: ${response.body.length}');
      final document = html_parser.parse(response.body);
      final results = document.querySelectorAll('.result');
      print('Found ${results.length} results via CSS selector .result');

      if (results.isNotEmpty) {
        print(
            'First result title: ${results.first.querySelector('.result_title a')?.text}');
      } else {
        print('HTML Snippet: ${response.body.substring(0, 500)}');
      }
    } else {
      print('Failed to load page.');
    }
  } catch (e) {
    print('Error: $e');
  }

  print('\nTesting LiveLaw connection...');
  try {
    final url = Uri.parse('https://www.livelaw.in/?s=privacy');
    final response = await http.get(
      url,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      },
    );

    print('Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Body length: ${response.body.length}');
      final document = html_parser.parse(response.body);
      final articles = document.querySelectorAll('article');
      print('Found ${articles.length} articles via CSS selector article');
    }
  } catch (e) {
    print('Error: $e');
  }
}
