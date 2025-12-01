import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UsageProvider extends ChangeNotifier {
  late Box _box;
  bool _isInitialized = false;

  UsageProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox('usage_stats');
    _loadUsage();
    _isInitialized = true;
    notifyListeners();
  }

  void _loadUsage() {
    _aiQueriesUsage = _box.get('aiQueriesUsage', defaultValue: 0);
    _casesUsage = _box.get('casesUsage',
        defaultValue: 1); // Default 1 as per original code
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

  // AI Queries
  int _aiQueriesUsage = 0;
  int _aiQueriesLimit = 500;

  // Cases
  int _casesUsage = 1;
  int _casesLimit = 50;

  // Scan to PDF
  int _scanToPdfUsage = 0;
  int _scanToPdfLimit = 50;

  // Documents
  int _documentsUsage = 0;
  int _documentsLimit = 20;

  // Risk Analysis
  int _riskAnalysisUsage = 0;
  int _riskAnalysisLimit = 10;

  // AI Voice
  int _aiVoiceUsage = 0;
  int _aiVoiceLimit = 100;

  // Getters
  int get aiQueriesUsage => _aiQueriesUsage;
  int get aiQueriesLimit => _aiQueriesLimit;

  int get casesUsage => _casesUsage;
  int get casesLimit => _casesLimit;

  int get scanToPdfUsage => _scanToPdfUsage;
  int get scanToPdfLimit => _scanToPdfLimit;

  int get documentsUsage => _documentsUsage;
  int get documentsLimit => _documentsLimit;

  int get riskAnalysisUsage => _riskAnalysisUsage;
  int get riskAnalysisLimit => _riskAnalysisLimit;

  int get aiVoiceUsage => _aiVoiceUsage;
  int get aiVoiceLimit => _aiVoiceLimit;

  // Case Finder
  int _caseFinderUsage = 0;
  int _caseFinderLimit = 50;

  int get caseFinderUsage => _caseFinderUsage;
  int get caseFinderLimit => _caseFinderLimit;

  // Court Orders
  int _courtOrdersUsage = 0;
  int _courtOrdersLimit = 30;

  // Translator
  int _translatorUsage = 0;
  int _translatorLimit = 100;

  // Bare Acts
  int _bareActsUsage = 0;
  int _bareActsLimit = 1000;

  // Chat History
  int _chatHistoryUsage = 0;
  int _chatHistoryLimit = 100;

  int get courtOrdersUsage => _courtOrdersUsage;
  int get courtOrdersLimit => _courtOrdersLimit;

  int get translatorUsage => _translatorUsage;
  int get translatorLimit => _translatorLimit;

  int get bareActsUsage => _bareActsUsage;
  int get bareActsLimit => _bareActsLimit;

  int get chatHistoryUsage => _chatHistoryUsage;
  int get chatHistoryLimit => _chatHistoryLimit;

  // Methods to increment usage
  void incrementAiQueries() {
    if (_aiQueriesUsage < _aiQueriesLimit) {
      _aiQueriesUsage++;
      _box.put('aiQueriesUsage', _aiQueriesUsage);
      notifyListeners();
    }
  }

  void incrementAiVoice() {
    if (_aiVoiceUsage < _aiVoiceLimit) {
      _aiVoiceUsage++;
      _box.put('aiVoiceUsage', _aiVoiceUsage);
      notifyListeners();
    }
  }

  void incrementCases() {
    if (_casesUsage < _casesLimit) {
      _casesUsage++;
      _box.put('casesUsage', _casesUsage);
      notifyListeners();
    }
  }

  void incrementScanToPdf() {
    if (_scanToPdfUsage < _scanToPdfLimit) {
      _scanToPdfUsage++;
      _box.put('scanToPdfUsage', _scanToPdfUsage);
      notifyListeners();
    }
  }

  void incrementDocuments() {
    if (_documentsUsage < _documentsLimit) {
      _documentsUsage++;
      _box.put('documentsUsage', _documentsUsage);
      notifyListeners();
    }
  }

  void incrementRiskAnalysis() {
    if (_riskAnalysisUsage < _riskAnalysisLimit) {
      _riskAnalysisUsage++;
      _box.put('riskAnalysisUsage', _riskAnalysisUsage);
      notifyListeners();
    }
  }

  void incrementCourtOrders() {
    if (_courtOrdersUsage < _courtOrdersLimit) {
      _courtOrdersUsage++;
      _box.put('courtOrdersUsage', _courtOrdersUsage);
      notifyListeners();
    }
  }

  void incrementTranslator() {
    if (_translatorUsage < _translatorLimit) {
      _translatorUsage++;
      _box.put('translatorUsage', _translatorUsage);
      notifyListeners();
    }
  }

  void incrementBareActs() {
    if (_bareActsUsage < _bareActsLimit) {
      _bareActsUsage++;
      _box.put('bareActsUsage', _bareActsUsage);
      notifyListeners();
    }
  }

  void incrementChatHistory() {
    if (_chatHistoryUsage < _chatHistoryLimit) {
      _chatHistoryUsage++;
      _box.put('chatHistoryUsage', _chatHistoryUsage);
      notifyListeners();
    }
  }

  void incrementCaseFinder() {
    if (_caseFinderUsage < _caseFinderLimit) {
      _caseFinderUsage++;
      _box.put('caseFinderUsage', _caseFinderUsage);
      notifyListeners();
    }
  }

  // Certified Copy
  int _certifiedCopyUsage = 0;
  int _certifiedCopyLimit = 10;

  int get certifiedCopyUsage => _certifiedCopyUsage;
  int get certifiedCopyLimit => _certifiedCopyLimit;

  void incrementCertifiedCopy() {
    if (_certifiedCopyUsage < _certifiedCopyLimit) {
      _certifiedCopyUsage++;
      _box.put('certifiedCopyUsage', _certifiedCopyUsage);
      notifyListeners();
    }
  }
}
