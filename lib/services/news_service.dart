import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/features/home/models/news_article.dart';

class NewsService {
  final String apiKey = 'e8e3e0745fd143d294c06aa02380eeb9'; // Replace with your NewsAPI key
  final String baseUrl = 'https://newsapi.org/v2/everything';

  Future<List<NewsArticle>> fetchLegalNews() async {
    final response = await http.get(Uri.parse('$baseUrl?q=legal&pageSize=5&apiKey=$apiKey'));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      Iterable list = result['articles'];
      return list.map((article) => NewsArticle.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}
