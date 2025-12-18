import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

/// Usage limits configuration (DEFAULTS)
/// These are used if no dynamic limit is set in Firestore system/limits.
class UsageLimits {
  // Daily Limits (Free Users) - Defaults
  static const int dailyAiQueries = 10;
  static const int dailyCaseFinder = 5;
  static const int dailyRiskAnalysis = 3;
  static const int dailyTranslator = 20;
  static const int dailyCourtOrders = 10;
  static const int dailyScanToPdf = 10;
  static const int dailyDocuments = 5;

  // Monthly Limits (Free Users) - Defaults
  static const int monthlyAiQueries = 100;
  static const int monthlyCaseFinder = 50;
  static const int monthlyRiskAnalysis = 30;
  static const int monthlyTranslator = 200;
  static const int monthlyCourtOrders = 100;
  static const int monthlyScanToPdf = 100;
  static const int monthlyDocuments = 50;
  static const int monthlyCases = 50;
  static const int monthlyAiVoice = 100;
  static const int monthlyBareActs = 1000;
  static const int monthlyChatHistory = 100;
  // Certified Copy default is handled in provider (20)
  static const int monthlyDiary = 100;

  // Premium Multiplier
  static const int premiumMultiplier = 50;
}

class UsageProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<DocumentSnapshot>? _usageSubscription;
  StreamSubscription<DocumentSnapshot>? _systemLimitsSubscription;

  String get _userId => _auth.currentUser?.uid ?? 'anonymous';
  bool get _isAuthenticated => _userId != 'anonymous';

  // --- State Variables ---
  bool _isPremium = false;
  bool _isLoading = true;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;

  // --- Dynamic System Limits (Daily & Monthly) ---

  // Daily
  int _dailyAiQueriesSystem = UsageLimits.dailyAiQueries;
  int _dailyCaseFinderSystem = UsageLimits.dailyCaseFinder;
  int _dailyRiskAnalysisSystem = UsageLimits.dailyRiskAnalysis;
  int _dailyTranslatorSystem = UsageLimits.dailyTranslator;
  int _dailyCourtOrdersSystem = UsageLimits.dailyCourtOrders;
  int _dailyScanToPdfSystem = UsageLimits.dailyScanToPdf;
  int _dailyDocumentsSystem = UsageLimits.dailyDocuments;

  // Monthly
  int _monthlyAiQueriesSystem = UsageLimits.monthlyAiQueries;
  int _monthlyCaseFinderSystem = UsageLimits.monthlyCaseFinder;
  int _monthlyRiskAnalysisSystem = UsageLimits.monthlyRiskAnalysis;
  int _monthlyTranslatorSystem = UsageLimits.monthlyTranslator;
  int _monthlyCourtOrdersSystem = UsageLimits.monthlyCourtOrders;
  int _monthlyScanToPdfSystem = UsageLimits.monthlyScanToPdf;
  int _monthlyDocumentsSystem = UsageLimits.monthlyDocuments;
  int _monthlyCasesSystem = UsageLimits.monthlyCases;
  int _monthlyAiVoiceSystem = UsageLimits.monthlyAiVoice;
  int _monthlyBareActsSystem = UsageLimits.monthlyBareActs;
  int _monthlyChatHistorySystem = UsageLimits.monthlyChatHistory;
  int _monthlyDiarySystem = UsageLimits.monthlyDiary;
  int _certifiedCopySystemLimit = 20; // Default

  // --- Usage Counts (User Specific) ---
  // Daily Counts
  int _dailyAiQueries = 0;
  int _dailyCaseFinder = 0;
  int _dailyRiskAnalysis = 0;
  int _dailyTranslator = 0;
  int _dailyCourtOrders = 0;
  int _dailyScanToPdf = 0;
  int _dailyDocuments = 0;

  // Monthly Counts
  int _monthlyAiQueries = 0;
  int _monthlyCaseFinder = 0;
  int _monthlyRiskAnalysis = 0;
  int _monthlyTranslator = 0;
  int _monthlyCourtOrders = 0;
  int _monthlyScanToPdf = 0;
  int _monthlyDocuments = 0;
  int _monthlyCases = 0;
  int _monthlyAiVoice = 0;
  int _monthlyBareActs = 0;
  int _monthlyChatHistory = 0;
  int _monthlyCertifiedCopy = 0;
  int _monthlyDiary = 0;

  // --- Getters: Usage ---

  // Daily Usage
  int get dailyAiQueriesUsage => _dailyAiQueries;
  int get dailyCaseFinderUsage => _dailyCaseFinder;
  int get dailyRiskAnalysisUsage => _dailyRiskAnalysis;
  int get dailyTranslatorUsage => _dailyTranslator;
  int get dailyCourtOrdersUsage => _dailyCourtOrders;
  int get dailyScanToPdfUsage => _dailyScanToPdf;
  int get dailyDocumentsUsage => _dailyDocuments;

  // Monthly Usage
  int get aiQueriesUsage => _monthlyAiQueries;
  int get caseFinderUsage => _monthlyCaseFinder;
  int get riskAnalysisUsage => _monthlyRiskAnalysis;
  int get translatorUsage => _monthlyTranslator;
  int get courtOrdersUsage => _monthlyCourtOrders;
  int get scanToPdfUsage => _monthlyScanToPdf;
  int get documentsUsage => _monthlyDocuments;
  int get casesUsage => _monthlyCases;
  int get aiVoiceUsage => _monthlyAiVoice;
  int get bareActsUsage => _monthlyBareActs;
  int get chatHistoryUsage => _monthlyChatHistory;
  int get certifiedCopyUsage => _monthlyCertifiedCopy;
  int get diaryUsage => _monthlyDiary;

  // --- Getters: Dynamic Limits ---
  // If Premium, multiply System Limit by 50.

  // Daily Limits
  int get dailyAiQueriesLimit =>
      _isPremium ? _dailyAiQueriesSystem * 50 : _dailyAiQueriesSystem;
  int get dailyCaseFinderLimit =>
      _isPremium ? _dailyCaseFinderSystem * 50 : _dailyCaseFinderSystem;
  int get dailyRiskAnalysisLimit =>
      _isPremium ? _dailyRiskAnalysisSystem * 50 : _dailyRiskAnalysisSystem;
  int get dailyTranslatorLimit =>
      _isPremium ? _dailyTranslatorSystem * 50 : _dailyTranslatorSystem;
  int get dailyCourtOrdersLimit =>
      _isPremium ? _dailyCourtOrdersSystem * 50 : _dailyCourtOrdersSystem;
  int get dailyScanToPdfLimit =>
      _isPremium ? _dailyScanToPdfSystem * 50 : _dailyScanToPdfSystem;
  int get dailyDocumentsLimit =>
      _isPremium ? _dailyDocumentsSystem * 50 : _dailyDocumentsSystem;

  // Monthly Limits
  int get aiQueriesLimit =>
      _isPremium ? _monthlyAiQueriesSystem * 50 : _monthlyAiQueriesSystem;
  int get caseFinderLimit =>
      _isPremium ? _monthlyCaseFinderSystem * 50 : _monthlyCaseFinderSystem;
  int get riskAnalysisLimit =>
      _isPremium ? _monthlyRiskAnalysisSystem * 50 : _monthlyRiskAnalysisSystem;
  int get translatorLimit =>
      _isPremium ? _monthlyTranslatorSystem * 50 : _monthlyTranslatorSystem;
  int get courtOrdersLimit =>
      _isPremium ? _monthlyCourtOrdersSystem * 50 : _monthlyCourtOrdersSystem;
  int get scanToPdfLimit =>
      _isPremium ? _monthlyScanToPdfSystem * 50 : _monthlyScanToPdfSystem;
  int get documentsLimit =>
      _isPremium ? _monthlyDocumentsSystem * 50 : _monthlyDocumentsSystem;
  int get casesLimit =>
      _isPremium ? _monthlyCasesSystem * 50 : _monthlyCasesSystem;
  int get aiVoiceLimit =>
      _isPremium ? _monthlyAiVoiceSystem * 50 : _monthlyAiVoiceSystem;
  int get bareActsLimit =>
      _isPremium ? _monthlyBareActsSystem * 50 : _monthlyBareActsSystem;
  int get chatHistoryLimit =>
      _isPremium ? _monthlyChatHistorySystem * 50 : _monthlyChatHistorySystem;
  int get diaryLimit =>
      _isPremium ? _monthlyDiarySystem * 50 : _monthlyDiarySystem;

  // Special Certified Copy Logic (System -> Limits)
  int get certifiedCopyLimit =>
      _isPremium ? _certifiedCopySystemLimit * 50 : _certifiedCopySystemLimit;

  UsageProvider() {
    _init();
  }

  void _init() {
    // Start listening to System Limits immediately
    _subscribeToSystemLimits();

    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        debugPrint(
          'UsageProvider: Auth state changed. User entered: ${user.uid}',
        );
        // 1. Fetch Premium Status
        await _syncPremiumStatus();
        // 2. Start Realtime Listener for Usage
        _subscribeToFirestore();
      } else {
        debugPrint('UsageProvider: User logged out.');
        _cancelSubscription();
        _resetLocalState();
        notifyListeners();
      }
    });
  }

  Future<void> reload() async {
    await _syncPremiumStatus();
    if (_usageSubscription == null) {
      _subscribeToFirestore();
    }
  }

  void _cancelSubscription() {
    _usageSubscription?.cancel();
    _usageSubscription = null;
  }

  // Fetches GLOBAL dynamic limits from system/limits
  void _subscribeToSystemLimits() {
    _systemLimitsSubscription?.cancel();
    _systemLimitsSubscription = _firestore
        .collection('system')
        .doc('limits')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          debugPrint('UsageProvider: Updating System Limits from Firestore...');

          // Helper
          int _parse(String key, int defaultVal) {
            final val = data[key];
            if (val is num) return val.toInt();
            return defaultVal;
          }

          // Daily Limits Parsing
          _dailyAiQueriesSystem =
              _parse('dailyAiQueries', UsageLimits.dailyAiQueries);
          _dailyCaseFinderSystem =
              _parse('dailyCaseFinder', UsageLimits.dailyCaseFinder);
          _dailyRiskAnalysisSystem =
              _parse('dailyRiskAnalysis', UsageLimits.dailyRiskAnalysis);
          _dailyTranslatorSystem =
              _parse('dailyTranslator', UsageLimits.dailyTranslator);
          _dailyCourtOrdersSystem =
              _parse('dailyCourtOrders', UsageLimits.dailyCourtOrders);
          _dailyScanToPdfSystem =
              _parse('dailyScanToPdf', UsageLimits.dailyScanToPdf);
          _dailyDocumentsSystem =
              _parse('dailyDocuments', UsageLimits.dailyDocuments);

          // Monthly Limits Parsing
          _monthlyAiQueriesSystem =
              _parse('monthlyAiQueries', UsageLimits.monthlyAiQueries);
          _monthlyCaseFinderSystem =
              _parse('monthlyCaseFinder', UsageLimits.monthlyCaseFinder);
          _monthlyRiskAnalysisSystem =
              _parse('monthlyRiskAnalysis', UsageLimits.monthlyRiskAnalysis);
          _monthlyTranslatorSystem =
              _parse('monthlyTranslator', UsageLimits.monthlyTranslator);
          _monthlyCourtOrdersSystem =
              _parse('monthlyCourtOrders', UsageLimits.monthlyCourtOrders);
          _monthlyScanToPdfSystem =
              _parse('monthlyScanToPdf', UsageLimits.monthlyScanToPdf);
          _monthlyDocumentsSystem =
              _parse('monthlyDocuments', UsageLimits.monthlyDocuments);
          _monthlyCasesSystem =
              _parse('monthlyCases', UsageLimits.monthlyCases);
          _monthlyAiVoiceSystem =
              _parse('monthlyAiVoice', UsageLimits.monthlyAiVoice);
          _monthlyBareActsSystem =
              _parse('monthlyBareActs', UsageLimits.monthlyBareActs);
          _monthlyChatHistorySystem =
              _parse('monthlyChatHistory', UsageLimits.monthlyChatHistory);
          _monthlyDiarySystem =
              _parse('monthlyDiary', UsageLimits.monthlyDiary);

          // Certified Copy (Supports 'Count', 'Limit', or 'certifiedCopy')
          _certifiedCopySystemLimit = (data['Count'] as num?)?.toInt() ??
              (data['Limit'] as num?)?.toInt() ??
              (data['certifiedCopy'] as num?)?.toInt() ??
              20;

          debugPrint(
              'UsageProvider: System Limits Updated. CertifiedCopy: $_certifiedCopySystemLimit');
          notifyListeners();
        }
      }
    }, onError: (e) {
      debugPrint('UsageProvider: Error fetching system limits: $e');
    });
  }

  // --- Real-time Usage Update (No changes to logic, just variables) ---
  void _subscribeToFirestore() {
    if (!_isAuthenticated) return;

    _cancelSubscription();

    _usageSubscription = _firestore
        .collection('users')
        .doc(_userId)
        .collection('usage')
        .doc('stats')
        .snapshots()
        .listen(
      (snapshot) async {
        if (!snapshot.exists) {
          await _initializeFirestoreDoc();
          return;
        }

        final data = snapshot.data();
        if (data == null) return;
        _isLoading = false;

        // Date-Based Reset Logic
        final serverMonth = data['month'] as String?;
        final serverDailyDate = data['lastDailyReset'] as String?;
        final today = DateTime.now().toIso8601String().split('T')[0];
        final currentMonth =
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

        bool needsResetUpdate = false;
        Map<String, dynamic> resetUpdateData = {};

        if (serverDailyDate != today) {
          resetUpdateData['daily'] = _getInitialDailyMap();
          resetUpdateData['lastDailyReset'] = today;
          needsResetUpdate = true;
        }

        if (serverMonth != currentMonth) {
          resetUpdateData['monthly'] = _getInitialMonthlyMap();
          resetUpdateData['month'] = currentMonth;
          needsResetUpdate = true;
        }

        if (needsResetUpdate) {
          await _firestore
              .collection('users')
              .doc(_userId)
              .collection('usage')
              .doc('stats')
              .set(resetUpdateData, SetOptions(merge: true));
          return;
        }

        // Parse Usage data
        final daily = data['daily'] as Map<String, dynamic>? ?? {};
        int getDaily(String key) {
          final flat = data['daily.$key'];
          if (flat is num) return flat.toInt();
          return (daily[key] as num?)?.toInt() ?? 0;
        }

        _dailyAiQueries = getDaily('aiQueries');
        _dailyCaseFinder = getDaily('caseFinder');
        _dailyRiskAnalysis = getDaily('riskAnalysis');
        _dailyTranslator = getDaily('translator');
        _dailyCourtOrders = getDaily('courtOrders');
        _dailyScanToPdf = getDaily('scanToPdf');
        _dailyDocuments = getDaily('documents');

        final monthly = data['monthly'] as Map<String, dynamic>? ?? {};
        int getMonthly(String key) {
          final flat = data['monthly.$key'];
          if (flat is num) return flat.toInt();
          return (monthly[key] as num?)?.toInt() ?? 0;
        }

        _monthlyAiQueries = getMonthly('aiQueries');
        _monthlyCaseFinder = getMonthly('caseFinder');
        _monthlyRiskAnalysis = getMonthly('riskAnalysis');
        _monthlyTranslator = getMonthly('translator');
        _monthlyCourtOrders = getMonthly('courtOrders');
        _monthlyScanToPdf = getMonthly('scanToPdf');
        _monthlyDocuments = getMonthly('documents');
        _monthlyCases = getMonthly('cases');
        _monthlyAiVoice = getMonthly('aiVoice');
        _monthlyBareActs = getMonthly('bareActs');
        _monthlyChatHistory = getMonthly('chatHistory');
        _monthlyCertifiedCopy = getMonthly('certifiedCopy');
        _monthlyDiary = getMonthly('diary');

        notifyListeners();
      },
      onError: (e) {
        debugPrint('UsageProvider: Firestore stream error: $e');
      },
    );
  }

  // --- Check Logic (Uses Dynamic Getters) ---

  String? canUseFeature(String featureName) {
    if (featureName == 'aiQueries' && _dailyAiQueries >= dailyAiQueriesLimit)
      return 'Daily limit reached for AI Chat.';
    if (featureName == 'caseFinder' && _dailyCaseFinder >= dailyCaseFinderLimit)
      return 'Daily limit reached for Case Finder.';
    if (featureName == 'riskAnalysis' &&
        _dailyRiskAnalysis >= dailyRiskAnalysisLimit)
      return 'Daily limit reached for Risk Analysis.';
    if (featureName == 'translator' && _dailyTranslator >= dailyTranslatorLimit)
      return 'Daily limit reached for Translator.';
    if (featureName == 'courtOrders' &&
        _dailyCourtOrders >= dailyCourtOrdersLimit)
      return 'Daily limit reached for Court Orders.';
    if (featureName == 'scanToPdf' && _dailyScanToPdf >= dailyScanToPdfLimit)
      return 'Daily limit reached for Scanner.';
    if (featureName == 'documents' && _dailyDocuments >= dailyDocumentsLimit)
      return 'Daily limit reached for Documents.';

    if (featureName == 'aiQueries' && _monthlyAiQueries >= aiQueriesLimit)
      return 'Monthly limit reached for AI Chat.';
    if (featureName == 'caseFinder' && _monthlyCaseFinder >= caseFinderLimit)
      return 'Monthly limit reached for Case Finder.';
    if (featureName == 'riskAnalysis' &&
        _monthlyRiskAnalysis >= riskAnalysisLimit)
      return 'Monthly limit reached for Risk Analysis.';
    if (featureName == 'translator' && _monthlyTranslator >= translatorLimit)
      return 'Monthly limit reached for Translator.';
    if (featureName == 'courtOrders' && _monthlyCourtOrders >= courtOrdersLimit)
      return 'Monthly limit reached for Court Orders.';
    if (featureName == 'scanToPdf' && _monthlyScanToPdf >= scanToPdfLimit)
      return 'Monthly limit reached for Scanner.';
    if (featureName == 'documents' && _monthlyDocuments >= documentsLimit)
      return 'Monthly limit reached for Documents.';
    if (featureName == 'cases' && _monthlyCases >= casesLimit)
      return 'Monthly limit reached for Cases.';
    if (featureName == 'aiVoice' && _monthlyAiVoice >= aiVoiceLimit)
      return 'Monthly limit reached for AI Voice.';
    if (featureName == 'bareActs' && _monthlyBareActs >= bareActsLimit)
      return 'Monthly limit reached for Bare Acts.';
    if (featureName == 'chatHistory' && _monthlyChatHistory >= chatHistoryLimit)
      return 'Monthly limit reached for Chat History.';
    if (featureName == 'certifiedCopy' &&
        _monthlyCertifiedCopy >= certifiedCopyLimit)
      return 'Monthly limit reached for Certified Copy.';
    if (featureName == 'diary' && _monthlyDiary >= diaryLimit)
      return 'Monthly limit reached for Legal Diary.';

    return null;
  }

  // --- Incrementers ---

  Future<void> incrementAiQueries() async =>
      await _incrementFirestore('aiQueries', daily: true);
  Future<void> incrementCaseFinder() async =>
      await _incrementFirestore('caseFinder', daily: true);
  Future<void> incrementRiskAnalysis() async =>
      await _incrementFirestore('riskAnalysis', daily: true);
  Future<void> incrementTranslator() async =>
      await _incrementFirestore('translator', daily: true);
  Future<void> incrementCourtOrders() async =>
      await _incrementFirestore('courtOrders', daily: true);
  Future<void> incrementScanToPdf() async =>
      await _incrementFirestore('scanToPdf', daily: true);
  Future<void> incrementDocuments() async =>
      await _incrementFirestore('documents', daily: true);

  Future<void> incrementCases() async =>
      await _incrementFirestore('cases', daily: false);
  Future<void> incrementAiVoice() async =>
      await _incrementFirestore('aiVoice', daily: false);
  Future<void> incrementBareActs() async =>
      await _incrementFirestore('bareActs', daily: false);
  Future<void> incrementChatHistory() async =>
      await _incrementFirestore('chatHistory', daily: false);
  Future<void> incrementCertifiedCopy() async =>
      await _incrementFirestore('certifiedCopy', daily: false);
  Future<void> incrementDiary() async =>
      await _incrementFirestore('diary', daily: false);

  Future<void> _incrementFirestore(String featureKey,
      {required bool daily}) async {
    if (!_isAuthenticated) return;
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final currentMonth =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

      Map<String, dynamic> updates = {
        'lastUpdated': FieldValue.serverTimestamp(),
        'month': currentMonth,
        'monthly': {featureKey: FieldValue.increment(1)},
      };

      if (daily) {
        updates['lastDailyReset'] = today;
        updates['daily'] = {featureKey: FieldValue.increment(1)};
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('usage')
          .doc('stats')
          .set(updates, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UsageProvider: Error incrementing usage: $e');
    }
  }

  Future<void> _initializeFirestoreDoc() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final currentMonth =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('usage')
          .doc('stats')
          .set({
        'month': currentMonth,
        'lastDailyReset': today,
        'daily': _getInitialDailyMap(),
        'monthly': _getInitialMonthlyMap(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('UsageProvider: Failed to create usage doc: $e');
    }
  }

  Future<void> _syncPremiumStatus() async {
    if (!_isAuthenticated) return;
    try {
      final userDoc = await _firestore.collection('users').doc(_userId).get();
      if (userDoc.exists) {
        bool premiumStatus = userDoc.data()?['isPremium'] ?? false;
        if (_isPremium != premiumStatus) {
          _isPremium = premiumStatus;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error syncing premium status: $e');
    }
  }

  Future<void> upgradeToPremium() async {
    if (!_isAuthenticated) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .set({'isPremium': true}, SetOptions(merge: true));
      await _syncPremiumStatus();
    } catch (e) {
      debugPrint('Error upgrading: $e');
    }
  }

  void _resetLocalState() {
    _dailyAiQueries = 0;
    _dailyCaseFinder = 0;
    _dailyRiskAnalysis = 0;
    _dailyTranslator = 0;
    _dailyCourtOrders = 0;
    _dailyScanToPdf = 0;
    _dailyDocuments = 0;
    _monthlyAiQueries = 0;
    _monthlyCaseFinder = 0;
    _monthlyRiskAnalysis = 0;
    _monthlyTranslator = 0;
    _monthlyCourtOrders = 0;
    _monthlyScanToPdf = 0;
    _monthlyDocuments = 0;
    _monthlyCases = 0;
    _monthlyAiVoice = 0;
    _monthlyBareActs = 0;
    _monthlyChatHistory = 0;
    _monthlyCertifiedCopy = 0;
    _monthlyDiary = 0;
    _isPremium = false;
  }

  Map<String, int> _getInitialDailyMap() => {
        'aiQueries': 0,
        'caseFinder': 0,
        'riskAnalysis': 0,
        'translator': 0,
        'courtOrders': 0,
        'scanToPdf': 0,
        'documents': 0,
      };

  Map<String, int> _getInitialMonthlyMap() => {
        'aiQueries': 0,
        'caseFinder': 0,
        'riskAnalysis': 0,
        'translator': 0,
        'courtOrders': 0,
        'scanToPdf': 0,
        'documents': 0,
        'cases': 0,
        'aiVoice': 0,
        'bareActs': 0,
        'chatHistory': 0,
        'certifiedCopy': 0,
        'diary': 0,
      };
}
