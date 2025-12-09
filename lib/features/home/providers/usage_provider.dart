import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsageProvider extends ChangeNotifier {
  late Box _box;

  UsageProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox('usage_stats');
    // Listen to auth changes to reload usage when user switches
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _loadUsage();
      notifyListeners();
    });
    _loadUsage();
    notifyListeners();
  }

  // Helper to get current user ID
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
  String _getUserKey(String key) => '${_userId}_$key';

  // Subscription Status
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  // Usage Fields
  int _aiQueriesUsage = 0;
  int _casesUsage = 0;
  int _scanToPdfUsage = 0;
  int _documentsUsage = 0;
  int _riskAnalysisUsage = 0;
  int _aiVoiceUsage = 0;
  int _caseFinderUsage = 0;
  int _courtOrdersUsage = 0;
  int _translatorUsage = 0;
  int _bareActsUsage = 0;
  int _chatHistoryUsage = 0;
  int _certifiedCopyUsage = 0;

  // Limits
  final int _baseAiQueriesLimit = 500;
  final int _baseCasesLimit = 50;
  final int _baseScanToPdfLimit = 50;
  final int _baseDocumentsLimit = 20;
  final int _baseRiskAnalysisLimit = 10;
  final int _baseAiVoiceLimit = 100;
  final int _baseCaseFinderLimit = 50;
  final int _baseCourtOrdersLimit = 30;
  final int _baseTranslatorLimit = 100;
  final int _baseBareActsLimit = 1000;
  final int _baseChatHistoryLimit = 100;
  final int _baseCertifiedCopyLimit = 10;

  // Helper to get limit based on status
  int _getLimit(int baseLimit) => _isPremium ? 999999 : baseLimit;

  // Getters
  int get aiQueriesUsage => _aiQueriesUsage;
  int get aiQueriesLimit => _getLimit(_baseAiQueriesLimit);

  int get casesUsage => _casesUsage;
  int get casesLimit => _getLimit(_baseCasesLimit);

  int get scanToPdfUsage => _scanToPdfUsage;
  int get scanToPdfLimit => _getLimit(_baseScanToPdfLimit);

  int get documentsUsage => _documentsUsage;
  int get documentsLimit => _getLimit(_baseDocumentsLimit);

  int get riskAnalysisUsage => _riskAnalysisUsage;
  int get riskAnalysisLimit => _getLimit(_baseRiskAnalysisLimit);

  int get aiVoiceUsage => _aiVoiceUsage;
  int get aiVoiceLimit => _getLimit(_baseAiVoiceLimit);

  int get caseFinderUsage => _caseFinderUsage;
  int get caseFinderLimit => _getLimit(_baseCaseFinderLimit);

  int get courtOrdersUsage => _courtOrdersUsage;
  int get courtOrdersLimit => _getLimit(_baseCourtOrdersLimit);

  int get translatorUsage => _translatorUsage;
  int get translatorLimit => _getLimit(_baseTranslatorLimit);

  int get bareActsUsage => _bareActsUsage;
  int get bareActsLimit => _getLimit(_baseBareActsLimit);

  int get chatHistoryUsage => _chatHistoryUsage;
  int get chatHistoryLimit => _getLimit(_baseChatHistoryLimit);

  int get certifiedCopyUsage => _certifiedCopyUsage;
  int get certifiedCopyLimit => _getLimit(_baseCertifiedCopyLimit);

  void _loadUsage() {
    if (!_box.isOpen) return;

    _isPremium = _box.get(_getUserKey('isPremium'), defaultValue: false);

    // Check for daily reset
    final lastResetStr = _box.get(_getUserKey('lastResetDate'));
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    if (lastResetStr != todayStr) {
      _resetAllUsage(todayStr);
    } else {
      _aiQueriesUsage =
          _box.get(_getUserKey('aiQueriesUsage'), defaultValue: 0);
      _casesUsage = _box.get(_getUserKey('casesUsage'), defaultValue: 0);
      _scanToPdfUsage =
          _box.get(_getUserKey('scanToPdfUsage'), defaultValue: 0);
      _documentsUsage =
          _box.get(_getUserKey('documentsUsage'), defaultValue: 0);
      _riskAnalysisUsage =
          _box.get(_getUserKey('riskAnalysisUsage'), defaultValue: 0);
      _aiVoiceUsage = _box.get(_getUserKey('aiVoiceUsage'), defaultValue: 0);
      _caseFinderUsage =
          _box.get(_getUserKey('caseFinderUsage'), defaultValue: 0);
      _courtOrdersUsage =
          _box.get(_getUserKey('courtOrdersUsage'), defaultValue: 0);
      _translatorUsage =
          _box.get(_getUserKey('translatorUsage'), defaultValue: 0);
      _bareActsUsage = _box.get(_getUserKey('bareActsUsage'), defaultValue: 0);
      _chatHistoryUsage =
          _box.get(_getUserKey('chatHistoryUsage'), defaultValue: 0);
      _certifiedCopyUsage =
          _box.get(_getUserKey('certifiedCopyUsage'), defaultValue: 0);
    }
  }

  Future<void> _resetAllUsage(String todayStr) async {
    await _box.put(_getUserKey('lastResetDate'), todayStr);

    _aiQueriesUsage = 0;
    _casesUsage = 0;
    _scanToPdfUsage = 0;
    _documentsUsage = 0;
    _riskAnalysisUsage = 0;
    _aiVoiceUsage = 0;
    _caseFinderUsage = 0;
    _courtOrdersUsage = 0;
    _translatorUsage = 0;
    _bareActsUsage = 0;
    _chatHistoryUsage = 0;
    _certifiedCopyUsage = 0;

    await _box.put(_getUserKey('aiQueriesUsage'), 0);
    await _box.put(_getUserKey('casesUsage'), 0);
    await _box.put(_getUserKey('scanToPdfUsage'), 0);
    await _box.put(_getUserKey('documentsUsage'), 0);
    await _box.put(_getUserKey('riskAnalysisUsage'), 0);
    await _box.put(_getUserKey('aiVoiceUsage'), 0);
    await _box.put(_getUserKey('caseFinderUsage'), 0);
    await _box.put(_getUserKey('courtOrdersUsage'), 0);
    await _box.put(_getUserKey('translatorUsage'), 0);
    await _box.put(_getUserKey('bareActsUsage'), 0);
    await _box.put(_getUserKey('chatHistoryUsage'), 0);
    await _box.put(_getUserKey('certifiedCopyUsage'), 0);

    notifyListeners();
  }

  Future<void> upgradeToPremium() async {
    _isPremium = true;
    await _box.put(_getUserKey('isPremium'), true);
    notifyListeners();
  }

  // Increment Methods
  void incrementAiQueries() {
    if (_aiQueriesUsage < aiQueriesLimit) {
      _aiQueriesUsage++;
      _box.put(_getUserKey('aiQueriesUsage'), _aiQueriesUsage);
      notifyListeners();
    }
  }

  void incrementCases() {
    if (_casesUsage < casesLimit) {
      _casesUsage++;
      _box.put(_getUserKey('casesUsage'), _casesUsage);
      notifyListeners();
    }
  }

  void incrementScanToPdf() {
    if (_scanToPdfUsage < scanToPdfLimit) {
      _scanToPdfUsage++;
      _box.put(_getUserKey('scanToPdfUsage'), _scanToPdfUsage);
      notifyListeners();
    }
  }

  void incrementDocuments() {
    if (_documentsUsage < documentsLimit) {
      _documentsUsage++;
      _box.put(_getUserKey('documentsUsage'), _documentsUsage);
      notifyListeners();
    }
  }

  void incrementRiskAnalysis() {
    if (_riskAnalysisUsage < riskAnalysisLimit) {
      _riskAnalysisUsage++;
      _box.put(_getUserKey('riskAnalysisUsage'), _riskAnalysisUsage);
      notifyListeners();
    }
  }

  void incrementAiVoice() {
    if (_aiVoiceUsage < aiVoiceLimit) {
      _aiVoiceUsage++;
      _box.put(_getUserKey('aiVoiceUsage'), _aiVoiceUsage);
      notifyListeners();
    }
  }

  void incrementCaseFinder() {
    if (_caseFinderUsage < caseFinderLimit) {
      _caseFinderUsage++;
      _box.put(_getUserKey('caseFinderUsage'), _caseFinderUsage);
      notifyListeners();
    }
  }

  void incrementCourtOrders() {
    if (_courtOrdersUsage < courtOrdersLimit) {
      _courtOrdersUsage++;
      _box.put(_getUserKey('courtOrdersUsage'), _courtOrdersUsage);
      notifyListeners();
    }
  }

  void incrementTranslator() {
    if (_translatorUsage < translatorLimit) {
      _translatorUsage++;
      _box.put(_getUserKey('translatorUsage'), _translatorUsage);
      notifyListeners();
    }
  }

  void incrementBareActs() {
    if (_bareActsUsage < bareActsLimit) {
      _bareActsUsage++;
      _box.put(_getUserKey('bareActsUsage'), _bareActsUsage);
      notifyListeners();
    }
  }

  void incrementChatHistory() {
    if (_chatHistoryUsage < chatHistoryLimit) {
      _chatHistoryUsage++;
      _box.put(_getUserKey('chatHistoryUsage'), _chatHistoryUsage);
      notifyListeners();
    }
  }

  void incrementCertifiedCopy() {
    if (_certifiedCopyUsage < certifiedCopyLimit) {
      _certifiedCopyUsage++;
      _box.put(_getUserKey('certifiedCopyUsage'), _certifiedCopyUsage);
      notifyListeners();
    }
  }
}
