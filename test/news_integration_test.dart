import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/services/news_service.dart';

void main() {
  test('Fetch Legal News returns articles', () async {
    final service = NewsService();
    final articles = await service.fetchLegalNews();

    expect(articles, isNotEmpty);
    for (var article in articles) {
      print('Title: ${article.title}');
      print('URL: ${article.url}');
      print('Image: ${article.imageUrl}');
      expect(article.title, isNotEmpty);
      expect(article.url, isNotEmpty);
    }
  });
}
