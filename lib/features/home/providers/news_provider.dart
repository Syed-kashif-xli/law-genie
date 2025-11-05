import 'package:flutter/material.dart';
import 'package:myapp/features/home/models/news_article.dart';
import 'package:myapp/services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();
  List<NewsArticle> _news = [];
  bool _isLoading = false;

  List<NewsArticle> get news => _news;
  bool get isLoading => _isLoading;

  Future<void> fetchNews() async {
    _isLoading = true;
    notifyListeners();

    try {
      _news = await _newsService.fetchLegalNews();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
