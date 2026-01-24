import 'package:flutter/material.dart';
import 'package:myapp/models/judgment_model.dart';
import 'package:myapp/services/judgment_service.dart';
import 'package:myapp/services/pdf_service.dart';
import 'package:myapp/features/home/providers/usage_provider.dart';
import 'package:provider/provider.dart';

class JudgmentProvider with ChangeNotifier {
  final JudgmentService _service = JudgmentService();

  List<JudgmentCategory> _categories = [];
  List<Judgment> _searchResults = [];
  Judgment? _selectedJudgment;

  bool _isLoading = false;
  bool _isMoreLoading = false;
  bool _isDownloading = false;
  String? _errorMessage;
  int _currentPage = 0;
  bool _hasMore = true;
  String? _currentQuery;

  List<JudgmentCategory> get categories => _categories;
  List<Judgment> get searchResults => _searchResults;
  Judgment? get selectedJudgment => _selectedJudgment;
  bool get isLoading => _isLoading;
  bool get isMoreLoading => _isMoreLoading;
  bool get isDownloading => _isDownloading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> loadCategories() async {
    if (_categories.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _service.fetchCategories();
      debugPrint('JudgmentProvider: categories loaded: ${_categories.length}');
      if (_categories.isEmpty) {
        _errorMessage = "Unable to load categories. Please try again later.";
      }
    } catch (e) {
      debugPrint('JudgmentProvider: categories load error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchJudgments(BuildContext context, String query) async {
    final usageProvider = Provider.of<UsageProvider>(context, listen: false);
    _isLoading = true;
    _errorMessage = null;
    _searchResults = [];
    _currentPage = 0;
    _hasMore = true;
    _currentQuery = query;
    notifyListeners();

    try {
      _searchResults =
          await _service.searchJudgments(query, page: _currentPage);
      if (_searchResults.isEmpty) {
        _errorMessage = "No judgments found for '$query'.";
        _hasMore = false;
      } else {
        // Increment usage
        usageProvider.incrementJudgments();
        if (_searchResults.length < 10) _hasMore = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreJudgments() async {
    if (_isMoreLoading || !_hasMore || _currentQuery == null) return;

    _isMoreLoading = true;
    notifyListeners();

    try {
      _currentPage++;
      final moreResults =
          await _service.searchJudgments(_currentQuery!, page: _currentPage);
      if (moreResults.isEmpty) {
        _hasMore = false;
      } else {
        _searchResults.addAll(moreResults);
        if (moreResults.length < 10) _hasMore = false;
      }
    } catch (e) {
      debugPrint('Error loading more judgments: $e');
    } finally {
      _isMoreLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchJudgmentDetail(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedJudgment = null;
    notifyListeners();

    try {
      _selectedJudgment = await _service.fetchJudgmentDetail(id);
      if (_selectedJudgment == null) {
        _errorMessage =
            "Failed to load judgment details. The source site might be temporarily slow or blocking requests. Please try again in a moment.";
        debugPrint(
            'JudgmentProvider: fetchJudgmentDetail returned null for $id');
      }
    } catch (e) {
      debugPrint('JudgmentProvider: fetchJudgmentDetail EXCEPTION: $e');
      _errorMessage =
          "A network error occurred. Please check your connection and try again.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadJudgment(Judgment judgment) async {
    if (_isDownloading) return;

    _isDownloading = true;
    notifyListeners();

    try {
      Judgment? fullJudgment = judgment;

      // If content is missing, fetch it first
      if (judgment.content == null || judgment.content!.isEmpty) {
        debugPrint('JudgmentProvider: Fetching full content for download...');
        fullJudgment = await _service.fetchJudgmentDetail(judgment.id);
      }

      if (fullJudgment != null && fullJudgment.content != null) {
        await PdfService.generateAndDownloadPdf(fullJudgment);
      } else {
        debugPrint('JudgmentProvider: Could not fetch content for download');
      }
    } catch (e) {
      debugPrint('JudgmentProvider: downloadJudgment error: $e');
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    _errorMessage = null;
    notifyListeners();
  }
}
