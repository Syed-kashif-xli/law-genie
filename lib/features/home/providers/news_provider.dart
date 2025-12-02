import 'package:flutter/material.dart';
import 'package:myapp/features/home/models/news_article.dart';
import 'package:myapp/services/news_service.dart';
import 'package:myapp/services/notification_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();
  List<NewsArticle> _news = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NewsArticle> get news => _news;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNews({bool forceRefresh = false}) async {
    if (!forceRefresh && _news.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _news = await _newsService.fetchLegalNews();

      // Trigger notification if news found
      if (_news.isNotEmpty) {
        final latestNews = _news.first;
        NotificationService().showNotification(
          id: 100, // Fixed ID for now, or use random
          title: 'New Legal News',
          body: latestNews.title,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
