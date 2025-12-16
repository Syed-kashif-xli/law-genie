import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

/// Usage limits configuration
class UsageLimits {
  // Daily Limits (Free Users)
  static const int dailyAiQueries = 10;
  static const int dailyCaseFinder = 5;
  static const int dailyRiskAnalysis = 3;
  static const int dailyTranslator = 20;
  static const int dailyCourtOrders = 10;
  static const int dailyScanToPdf = 10;
  static const int dailyDocuments = 5;

  // Monthly Limits (Free Users)
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
  // static const int monthlyCertifiedCopy = 20; // Removed - handled dynamically
  static const int monthlyDiary = 100;

  // Premium Limits (50x of Free Limits)
  // Daily
  static const int premiumDailyAiQueries = dailyAiQueries * 50;
  static const int premiumDailyCaseFinder = dailyCaseFinder * 50;
  static const int premiumDailyRiskAnalysis = dailyRiskAnalysis * 50;
  static const int premiumDailyTranslator = dailyTranslator * 50;
  static const int premiumDailyCourtOrders = dailyCourtOrders * 50;
  static const int premiumDailyScanToPdf = dailyScanToPdf * 50;
  static const int premiumDailyDocuments = dailyDocuments * 50;

  // Monthly
  static const int premiumMonthlyAiQueries = monthlyAiQueries * 50;
  static const int premiumMonthlyCaseFinder = monthlyCaseFinder * 50;
  static const int premiumMonthlyRiskAnalysis = monthlyRiskAnalysis * 50;
  static const int premiumMonthlyTranslator = monthlyTranslator * 50;
  static const int premiumMonthlyCourtOrders = monthlyCourtOrders * 50;
  static const int premiumMonthlyScanToPdf = monthlyScanToPdf * 50;
  static const int premiumMonthlyDocuments = monthlyDocuments * 50;
  static const int premiumMonthlyCases = monthlyCases * 50;
  static const int premiumMonthlyAiVoice = monthlyAiVoice * 50;
  static const int premiumMonthlyBareActs = monthlyBareActs * 50;
  static const int premiumMonthlyChatHistory = monthlyChatHistory * 50;
  // static const int premiumMonthlyCertifiedCopy = monthlyCertifiedCopy * 50; // Removed - handled dynamically
  static const int premiumMonthlyDiary = monthlyDiary * 50;
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

  // Dynamic Limits from System
  int _certifiedCopySystemLimit = 20; // Default fallback

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

  // --- Getters ---

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

  // Limits (Dynamic based on Premium)
  int get aiQueriesLimit => _isPremium
      ? UsageLimits.premiumMonthlyAiQueries
      : UsageLimits.monthlyAiQueries;
  int get caseFinderLimit => _isPremium
      ? UsageLimits.premiumMonthlyCaseFinder
      : UsageLimits.monthlyCaseFinder;
  int get riskAnalysisLimit => _isPremium
      ? UsageLimits.premiumMonthlyRiskAnalysis
      : UsageLimits.monthlyRiskAnalysis;
  int get translatorLimit => _isPremium
      ? UsageLimits.premiumMonthlyTranslator
      : UsageLimits.monthlyTranslator;
  int get courtOrdersLimit => _isPremium
      ? UsageLimits.premiumMonthlyCourtOrders
      : UsageLimits.monthlyCourtOrders;
  int get scanToPdfLimit => _isPremium
      ? UsageLimits.premiumMonthlyScanToPdf
      : UsageLimits.monthlyScanToPdf;
  int get documentsLimit => _isPremium
      ? UsageLimits.premiumMonthlyDocuments
      : UsageLimits.monthlyDocuments;
  int get casesLimit =>
      _isPremium ? UsageLimits.premiumMonthlyCases : UsageLimits.monthlyCases;
  int get aiVoiceLimit => _isPremium
      ? UsageLimits.premiumMonthlyAiVoice
      : UsageLimits.monthlyAiVoice;
  int get bareActsLimit => _isPremium
      ? UsageLimits.premiumMonthlyBareActs
      : UsageLimits.monthlyBareActs;
  int get chatHistoryLimit => _isPremium
      ? UsageLimits.premiumMonthlyChatHistory
      : UsageLimits.monthlyChatHistory;

  // DYNAMIC LIMIT FOR CERTIFIED COPY (System -> Limits)
  int get certifiedCopyLimit =>
      _isPremium ? _certifiedCopySystemLimit * 50 : _certifiedCopySystemLimit;

  int get diaryLimit =>
      _isPremium ? UsageLimits.premiumMonthlyDiary : UsageLimits.monthlyDiary;

  // Daily Limits
  int get dailyAiQueriesLimit => _isPremium
      ? UsageLimits.premiumDailyAiQueries
      : UsageLimits.dailyAiQueries;
  int get dailyCaseFinderLimit => _isPremium
      ? UsageLimits.premiumDailyCaseFinder
      : UsageLimits.dailyCaseFinder;
  int get dailyRiskAnalysisLimit => _isPremium
      ? UsageLimits.premiumDailyRiskAnalysis
      : UsageLimits.dailyRiskAnalysis;
  int get dailyTranslatorLimit => _isPremium
      ? UsageLimits.premiumDailyTranslator
      : UsageLimits.dailyTranslator;
  int get dailyCourtOrdersLimit => _isPremium
      ? UsageLimits.premiumDailyCourtOrders
      : UsageLimits.dailyCourtOrders;
  int get dailyScanToPdfLimit => _isPremium
      ? UsageLimits.premiumDailyScanToPdf
      : UsageLimits.dailyScanToPdf;
  int get dailyDocumentsLimit => _isPremium
      ? UsageLimits.premiumDailyDocuments
      : UsageLimits.dailyDocuments;

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
    // Note: We keep _systemLimitsSubscription alive as it's global
  }

  void _subscribeToSystemLimits() {
    _systemLimitsSubscription?.cancel();
    _systemLimitsSubscription = _firestore
        .collection('system')
        .doc('limits')
        .snapshots()
        .listen((snapshot) {
      debugPrint(
          'UsageProvider: System Limits Snapshot received. Exists: ${snapshot.exists}');
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          debugPrint('UsageProvider: System Limit Data: $data');
          // Look for 'Count' or 'Limit' (from screenshot) or 'certifiedCopy'
          final val = (data['Count'] as num?)?.toInt() ??
              (data['Limit'] as num?)?.toInt() ??
              (data['certifiedCopy'] as num?)?.toInt();

          if (val != null) {
            _certifiedCopySystemLimit = val;
            debugPrint(
                'UsageProvider: Updated Certified Copy Limit from System: $_certifiedCopySystemLimit');
            notifyListeners();
          } else {
            debugPrint(
                'UsageProvider: "Count" or "Limit" field missing in system/limits');
          }
        }
      } else {
        debugPrint('UsageProvider: system/limits document does not exist.');
      }
    }, onError: (e) {
      debugPrint('UsageProvider: Error fetching system limits: $e');
    });
  }

  // --- Real-time Firestore Subscription & Fetch ---
  // This is the SINGLE SOURCE OF TRUTH.
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
        debugPrint(
          'UsageProvider: Stream received update for User: $_userId',
        );

        if (!snapshot.exists) {
          debugPrint(
            'UsageProvider: No usage doc found. Creating new one directly in Firestore.',
          );
          await _initializeFirestoreDoc();
          return;
        }

        final data = snapshot.data();
        debugPrint('UsageProvider: Data payload: $data');

        if (data == null) return;

        _isLoading = false;

        // --- 1. Check for DATE-BASED RESETS (Lazy Reset Logic) ---
        final serverMonth = data['month'] as String?;
        final serverDailyDate = data['lastDailyReset'] as String?;

        final today = DateTime.now().toIso8601String().split('T')[0];
        final currentMonth =
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

        bool needsResetUpdate = false;
        Map<String, dynamic> resetUpdateData = {};

        if (serverDailyDate != today) {
          debugPrint(
            'UsageProvider: New Day Detected ($today). Resetting Daily Counts on Server.',
          );
          resetUpdateData['daily'] = _getInitialDailyMap();
          resetUpdateData['lastDailyReset'] = today;
          needsResetUpdate = true;
        }

        if (serverMonth != currentMonth) {
          debugPrint(
            'UsageProvider: New Month Detected ($currentMonth). Resetting Monthly Counts on Server.',
          );
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
          return; // Wait for next update
        }

        // --- 2. Update Local State from Firestore Data ---
        // Fix: Check for 'dot-notation' keys first (legacy/current bug data), then nested map
        final daily = data['daily'] as Map<String, dynamic>? ?? {};

        // Helper to get value from flat key OR nested map
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

        debugPrint(
          'UsageProvider: Local state updated. DailyAI: $_dailyAiQueries. CertifiedCopy: $_monthlyCertifiedCopy',
        );
        notifyListeners();
      },
      onError: (e) {
        debugPrint('UsageProvider: Firestore stream error: $e');
      },
    );
  }

  // --- Actions ---

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

  Future<void> _incrementFirestore(
    String featureKey, {
    required bool daily,
  }) async {
    if (!_isAuthenticated) return;

    debugPrint(
      'UsageProvider: Incrementing $featureKey directly in Firestore...',
    );

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final currentMonth =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

      // Use nested maps for updates to ensure they merge into the 'daily'/'monthly' objects
      // instead of creating top-level keys like 'daily.aiQueries'.
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
      debugPrint('UsageProvider: Error incrementing usage in Firestore: $e');
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
      debugPrint('UsageProvider: Created new usage document.');
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
      debugPrint('Error upgrading to premium: $e');
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
