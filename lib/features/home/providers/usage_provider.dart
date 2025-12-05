import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UsageProvider extends ChangeNotifier {
  late Box _box;
  UsageProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox('usage_stats');
    _loadUsage();
    notifyListeners();
  }

  // Subscription Status
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  void _loadUsage() {
    _isPremium = _box.get('isPremium', defaultValue: false);
    _aiQueriesUsage = _box.get('aiQueriesUsage', defaultValue: 0);
    _casesUsage = _box.get('casesUsage', defaultValue: 1);
    _scanToPdfUsage = _box.get('scanToPdfUsage', defaultValue: 0);
    _documentsUsage = _box.get('documentsUsage', defaultValue: 0);
    _riskAnalysisUsage = _box.get('riskAnalysisUsage', defaultValue: 0);
    _aiVoiceUsage = _box.get('aiVoiceUsage', defaultValue: 0);
    _caseFinderUsage = _box.get('caseFinderUsage', defaultValue: 0);
    _courtOrdersUsage = _box.get('courtOrdersUsage', defaultValue: 0);
    _translatorUsage = _box.get('translatorUsage', defaultValue: 0);
    _bareActsUsage = _box.get('bareActsUsage', defaultValue: 0);
    _chatHistoryUsage = _box.get('chatHistoryUsage', defaultValue: 0);
    _certifiedCopyUsage = _box.get('certifiedCopyUsage', defaultValue: 0);
  }

  Future<void> upgradeToPremium() async {
    _isPremium = true;
    await _box.put('isPremium', true);
    notifyListeners();
  }

  // Helper to get limit based on status
  int _getLimit(int baseLimit) => _isPremium ? 999999 : baseLimit;

  // AI Queries
  int _aiQueriesUsage = 0;
  final int _baseAiQueriesLimit = 500;
  int get aiQueriesLimit => _getLimit(_baseAiQueriesLimit);

  // Cases
  int _casesUsage = 1;
  final int _baseCasesLimit = 50;
  int get casesLimit => _getLimit(_baseCasesLimit);

  // Scan to PDF
  int _scanToPdfUsage = 0;
  final int _baseScanToPdfLimit = 50;
  int get scanToPdfLimit => _getLimit(_baseScanToPdfLimit);

  // Documents
  int _documentsUsage = 0;
  final int _baseDocumentsLimit = 20;
  int get documentsLimit => _getLimit(_baseDocumentsLimit);

  // Risk Analysis
  int _riskAnalysisUsage = 0;
  final int _baseRiskAnalysisLimit = 10;
  int get riskAnalysisLimit => _getLimit(_baseRiskAnalysisLimit);

  // AI Voice
  int _aiVoiceUsage = 0;
  final int _baseAiVoiceLimit = 100;
  int get aiVoiceLimit => _getLimit(_baseAiVoiceLimit);

  // Getters
  int get aiQueriesUsage => _aiQueriesUsage;
  int get casesUsage => _casesUsage;
  int get scanToPdfUsage => _scanToPdfUsage;
  int get documentsUsage => _documentsUsage;
  int get riskAnalysisUsage => _riskAnalysisUsage;
  int get aiVoiceUsage => _aiVoiceUsage;

  // Case Finder
  int _caseFinderUsage = 0;
  final int _baseCaseFinderLimit = 50;
  int get caseFinderLimit => _getLimit(_baseCaseFinderLimit);
  int get caseFinderUsage => _caseFinderUsage;

  // Court Orders
  int _courtOrdersUsage = 0;
  final int _baseCourtOrdersLimit = 30;
  int get courtOrdersLimit => _getLimit(_baseCourtOrdersLimit);
  int get courtOrdersUsage => _courtOrdersUsage;

  // Translator
  int _translatorUsage = 0;
  final int _baseTranslatorLimit = 100;
  int get translatorLimit => _getLimit(_baseTranslatorLimit);
  int get translatorUsage => _translatorUsage;

  // Bare Acts
  int _bareActsUsage = 0;
  final int _baseBareActsLimit = 1000;
  int get bareActsLimit => _getLimit(_baseBareActsLimit);
  int get bareActsUsage => _bareActsUsage;

  // Chat History
  int _chatHistoryUsage = 0;
  final int _baseChatHistoryLimit = 100;
  int get chatHistoryLimit => _getLimit(_baseChatHistoryLimit);
  int get chatHistoryUsage => _chatHistoryUsage;

  // Certified Copy
  int _certifiedCopyUsage = 0;
  final int _baseCertifiedCopyLimit = 10;
  int get certifiedCopyLimit => _getLimit(_baseCertifiedCopyLimit);
  int get certifiedCopyUsage => _certifiedCopyUsage;

  // Methods to increment usage - check against dynamic limit
  void incrementAiQueries() {
    if (_aiQueriesUsage < aiQueriesLimit) {
      _aiQueriesUsage++;
      _box.put('aiQueriesUsage', _aiQueriesUsage);
      notifyListeners();
    }
  }

  void incrementAiVoice() {
    if (_aiVoiceUsage < aiVoiceLimit) {
      _aiVoiceUsage++;
      _box.put('aiVoiceUsage', _aiVoiceUsage);
      notifyListeners();
    }
  }

  void incrementCases() {
    if (_casesUsage < casesLimit) {
      _casesUsage++;
      _box.put('casesUsage', _casesUsage);
      notifyListeners();
    }
  }

  void incrementScanToPdf() {
    if (_scanToPdfUsage < scanToPdfLimit) {
      _scanToPdfUsage++;
      _box.put('scanToPdfUsage', _scanToPdfUsage);
      notifyListeners();
    }
  }

  void incrementDocuments() {
    if (_documentsUsage < documentsLimit) {
      _documentsUsage++;
      _box.put('documentsUsage', _documentsUsage);
      notifyListeners();
    }
  }

  void incrementRiskAnalysis() {
    if (_riskAnalysisUsage < riskAnalysisLimit) {
      _riskAnalysisUsage++;
      _box.put('riskAnalysisUsage', _riskAnalysisUsage);
      notifyListeners();
    }
  }

  void incrementCourtOrders() {
    if (_courtOrdersUsage < courtOrdersLimit) {
      _courtOrdersUsage++;
      _box.put('courtOrdersUsage', _courtOrdersUsage);
      notifyListeners();
    }
  }

  void incrementTranslator() {
    if (_translatorUsage < translatorLimit) {
      _translatorUsage++;
      _box.put('translatorUsage', _translatorUsage);
      notifyListeners();
    }
  }

  void incrementBareActs() {
    if (_bareActsUsage < bareActsLimit) {
      _bareActsUsage++;
      _box.put('bareActsUsage', _bareActsUsage);
      notifyListeners();
    }
  }

  void incrementChatHistory() {
    if (_chatHistoryUsage < chatHistoryLimit) {
      _chatHistoryUsage++;
      _box.put('chatHistoryUsage', _chatHistoryUsage);
      notifyListeners();
    }
  }

  void incrementCaseFinder() {
    if (_caseFinderUsage < caseFinderLimit) {
      _caseFinderUsage++;
      _box.put('caseFinderUsage', _caseFinderUsage);
      notifyListeners();
    }
  }

  void incrementCertifiedCopy() {
    if (_certifiedCopyUsage < certifiedCopyLimit) {
      _certifiedCopyUsage++;
      _box.put('certifiedCopyUsage', _certifiedCopyUsage);
      notifyListeners();
    }
  }
}
