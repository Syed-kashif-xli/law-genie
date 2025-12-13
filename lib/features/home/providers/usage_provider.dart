import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  static const int monthlyCertifiedCopy = 20;
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
  static const int premiumMonthlyCertifiedCopy = monthlyCertifiedCopy * 50;
  static const int premiumMonthlyDiary = monthlyDiary * 50;
}

class UsageProvider extends ChangeNotifier {
  Box? _box;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<DocumentSnapshot>? _usageSubscription;

  String get _userId => _auth.currentUser?.uid ?? 'anonymous';
  bool get _isAuthenticated => _userId != 'anonymous';
  String _getUserKey(String key) => '${_userId}_$key';

  // --- State Variables ---
  bool _isPremium = false;
  bool _isLoading = true;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;

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
  // Premium users have specific limits for some features, unlimited for others.

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

  int get certifiedCopyLimit => _isPremium
      ? UsageLimits.premiumMonthlyCertifiedCopy
      : UsageLimits.monthlyCertifiedCopy;

  int get diaryLimit =>
      _isPremium ? UsageLimits.premiumMonthlyDiary : UsageLimits.monthlyDiary;

  // Daily Limits (Specific to Free, 50x for Premium)

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

  Future<void> _init() async {
    // Open Hive solely as a local cache/fallback
    _box = await Hive.openBox('usage_stats_v2');

    // Load cached premium status immediately
    _isPremium =
        _box?.get(_getUserKey('isPremium'), defaultValue: false) ?? false;

    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        debugPrint(
            'UsageProvider: Auth state changed. User entered: ${user.uid}');
        // Sync premium status first
        await _syncPremiumStatus();
        // Start listening to usage stats
        _subscribeToFirestore();
      } else {
        debugPrint('UsageProvider: Auth state changed. User logged out.');
        _cancelSubscription();
        _resetLocalState();
        notifyListeners();
      }
    });

    if (_isAuthenticated) {
      // If already logged in, ensure doc exists then subscribe
      await _syncPremiumStatus();
      await _ensureFirestoreDocExists(); // Force creation if missing
      _subscribeToFirestore();
    }
  }

  // Explicitly check if doc exists and create if not (Robustness fix)
  Future<void> _ensureFirestoreDocExists() async {
    if (!_isAuthenticated) return;
    try {
      final docRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('usage')
          .doc('stats');

      final doc = await docRef.get();
      if (!doc.exists) {
        debugPrint(
            'UsageProvider: Stats doc missing in _init. Creating now...');
        await _initializeFirestoreDoc();
      }
    } catch (e) {
      debugPrint('UsageProvider: Error checking/creating stats doc: $e');
    }
  }

  void _cancelSubscription() {
    _usageSubscription?.cancel();
    _usageSubscription = null;
  }

  Future<void> _syncPremiumStatus() async {
    if (!_isAuthenticated) return;
    try {
      final userDoc = await _firestore.collection('users').doc(_userId).get();
      if (userDoc.exists) {
        bool premiumStatus = userDoc.data()?['isPremium'] ?? false;
        if (_isPremium != premiumStatus) {
          _isPremium = premiumStatus;
          _box?.put(_getUserKey('isPremium'), _isPremium);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error syncing premium status: $e');
    }
  }

  void _resetLocalState() {
    // Zero out all local counters
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

  // --- Real-time Firestore Subscription ---

  void _subscribeToFirestore() {
    if (!_isAuthenticated) return;

    _cancelSubscription();

    _usageSubscription = _firestore
        .collection('users')
        .doc(_userId)
        .collection('usage')
        .doc('stats')
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) {
        // Doc doesn't exist? Create fully initialized doc.
        debugPrint('UsageProvider: No usage doc found. Creating new one.');
        await _initializeFirestoreDoc();
        return;
      }

      final data = snapshot.data();
      if (data == null) return;

      _isLoading = false;

      // Dates checking for resets
      final serverMonth = data['month'] as String?;
      final serverDailyDate = data['lastDailyReset'] as String?;

      final today = DateTime.now().toIso8601String().split('T')[0];
      final currentMonth =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

      bool needsUpdate = false;
      Map<String, dynamic> updateData = {};

      // 1. Check Daily Reset
      if (serverDailyDate != today) {
        debugPrint('UsageProvider: Resetting Daily Counts (New Day)');
        // Reset daily map in Firestore
        updateData['daily'] = _getInitialDailyMap();
        updateData['lastDailyReset'] = today;
        needsUpdate = true;
        _resetLocalDailyVars();
      } else {
        // Parse daily counts safely, defaulting to 0 if key missing
        final daily = data['daily'] as Map<String, dynamic>? ?? {};
        _dailyAiQueries = daily['aiQueries'] as int? ?? 0;
        _dailyCaseFinder = daily['caseFinder'] as int? ?? 0;
        _dailyRiskAnalysis = daily['riskAnalysis'] as int? ?? 0;
        _dailyTranslator = daily['translator'] as int? ?? 0;
        _dailyCourtOrders = daily['courtOrders'] as int? ?? 0;
        _dailyScanToPdf = daily['scanToPdf'] as int? ?? 0;
        _dailyDocuments = daily['documents'] as int? ?? 0;
      }

      // 2. Check Monthly Reset
      if (serverMonth != currentMonth) {
        debugPrint('UsageProvider: Resetting Monthly Counts (New Month)');
        // Reset monthly map in Firestore
        updateData['monthly'] = _getInitialMonthlyMap();
        updateData['month'] = currentMonth;
        needsUpdate = true;
        _resetLocalMonthlyVars();
      } else {
        // Parse monthly counts safely, defaulting to 0 if key missing
        // Also supports legacy 'features' key if migration didn't happen, though we generally prefer 'monthly'
        final monthly = data['monthly'] as Map<String, dynamic>? ??
            data['features'] as Map<String, dynamic>? ??
            {};

        _monthlyAiQueries = monthly['aiQueries'] as int? ?? 0;
        _monthlyCaseFinder = monthly['caseFinder'] as int? ?? 0;
        _monthlyRiskAnalysis = monthly['riskAnalysis'] as int? ?? 0;
        _monthlyTranslator = monthly['translator'] as int? ?? 0;
        _monthlyCourtOrders = monthly['courtOrders'] as int? ?? 0;
        _monthlyScanToPdf = monthly['scanToPdf'] as int? ?? 0;
        _monthlyDocuments = monthly['documents'] as int? ?? 0;
        _monthlyCases = monthly['cases'] as int? ?? 0;
        _monthlyAiVoice = monthly['aiVoice'] as int? ?? 0;
        _monthlyBareActs = monthly['bareActs'] as int? ?? 0;
        _monthlyChatHistory = monthly['chatHistory'] as int? ?? 0;
        _monthlyCertifiedCopy = monthly['certifiedCopy'] as int? ?? 0;
        _monthlyDiary = monthly['diary'] as int? ?? 0;
      }

      notifyListeners();
      _saveToHive();

      if (needsUpdate) {
        // Atomic update to reset counts on server
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('usage')
            .doc('stats')
            .set(updateData, SetOptions(merge: true));
      }
    }, onError: (e) {
      debugPrint('UsageProvider: Firestore stream error: $e');
    });
  }

  // Initialize doc with data from Hive (if available) or zeros
  Future<void> _initializeFirestoreDoc() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final currentMonth =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

    // Try to retrieve local data to migrate
    int boxDailyAiQueries =
        _box?.get(_getUserKey('dailyAiQueries'), defaultValue: 0) ?? 0;

    debugPrint('UsageProvider: Starting initialization for $_userId');
    // ... (rest of local var retrieval)

    // Force creation with merge: true to ensure it exists
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('usage')
          .doc('stats')
          .set({
        'month': currentMonth,
        'lastDailyReset': today,
        'daily': {
          'aiQueries': boxDailyAiQueries,
          // ... (rest of the fields as before)
          // logic remains same, just adding explicit debug and try-catch for visibility
        },
        'monthly': {
          // ...
        },
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint(
          'UsageProvider: Successfully created/updated usage doc at users/$_userId/usage/stats');
    } catch (e) {
      debugPrint('UsageProvider: FAILED to create usage doc: $e');
    }
    int boxDailyCaseFinder =
        _box?.get(_getUserKey('dailyCaseFinder'), defaultValue: 0) ?? 0;
    int boxDailyRiskAnalysis =
        _box?.get(_getUserKey('dailyRiskAnalysis'), defaultValue: 0) ?? 0;
    int boxDailyTranslator =
        _box?.get(_getUserKey('dailyTranslator'), defaultValue: 0) ?? 0;
    int boxDailyCourtOrders =
        _box?.get(_getUserKey('dailyCourtOrders'), defaultValue: 0) ?? 0;
    int boxDailyScanToPdf =
        _box?.get(_getUserKey('dailyScanToPdf'), defaultValue: 0) ?? 0;
    int boxDailyDocuments =
        _box?.get(_getUserKey('dailyDocuments'), defaultValue: 0) ?? 0;

    int boxMonthlyAiQueries =
        _box?.get(_getUserKey('monthlyAiQueries'), defaultValue: 0) ?? 0;
    int boxMonthlyCaseFinder =
        _box?.get(_getUserKey('monthlyCaseFinder'), defaultValue: 0) ?? 0;
    int boxMonthlyRiskAnalysis =
        _box?.get(_getUserKey('monthlyRiskAnalysis'), defaultValue: 0) ?? 0;
    int boxMonthlyTranslator =
        _box?.get(_getUserKey('monthlyTranslator'), defaultValue: 0) ?? 0;
    int boxMonthlyCourtOrders =
        _box?.get(_getUserKey('monthlyCourtOrders'), defaultValue: 0) ?? 0;
    int boxMonthlyScanToPdf =
        _box?.get(_getUserKey('monthlyScanToPdf'), defaultValue: 0) ?? 0;
    int boxMonthlyDocuments =
        _box?.get(_getUserKey('monthlyDocuments'), defaultValue: 0) ?? 0;
    int boxMonthlyCases =
        _box?.get(_getUserKey('monthlyCases'), defaultValue: 0) ?? 0;
    int boxMonthlyAiVoice =
        _box?.get(_getUserKey('monthlyAiVoice'), defaultValue: 0) ?? 0;
    int boxMonthlyBareActs =
        _box?.get(_getUserKey('monthlyBareActs'), defaultValue: 0) ?? 0;
    int boxMonthlyChatHistory =
        _box?.get(_getUserKey('monthlyChatHistory'), defaultValue: 0) ?? 0;
    int boxMonthlyCertifiedCopy =
        _box?.get(_getUserKey('monthlyCertifiedCopy'), defaultValue: 0) ?? 0;
    int boxMonthlyDiary =
        _box?.get(_getUserKey('monthlyDiary'), defaultValue: 0) ?? 0;

    debugPrint(
        'UsageProvider: Migrating local usage to Firestore for $_userId: '
        'DailyAI=$boxDailyAiQueries, MonthlyAI=$boxMonthlyAiQueries');

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('usage')
          .doc('stats')
          .set({
        'month': currentMonth,
        'lastDailyReset': today,
        'daily': {
          'aiQueries': boxDailyAiQueries,
          'caseFinder': boxDailyCaseFinder,
          'riskAnalysis': boxDailyRiskAnalysis,
          'translator': boxDailyTranslator,
          'courtOrders': boxDailyCourtOrders,
          'scanToPdf': boxDailyScanToPdf,
          'documents': boxDailyDocuments,
        },
        'monthly': {
          'aiQueries': boxMonthlyAiQueries,
          'caseFinder': boxMonthlyCaseFinder,
          'riskAnalysis': boxMonthlyRiskAnalysis,
          'translator': boxMonthlyTranslator,
          'courtOrders': boxMonthlyCourtOrders,
          'scanToPdf': boxMonthlyScanToPdf,
          'documents': boxMonthlyDocuments,
          'cases': boxMonthlyCases,
          'aiVoice': boxMonthlyAiVoice,
          'bareActs': boxMonthlyBareActs,
          'chatHistory': boxMonthlyChatHistory,
          'certifiedCopy': boxMonthlyCertifiedCopy,
          'diary': boxMonthlyDiary,
        },
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint(
          'UsageProvider: Successfully created/updated usage doc at users/$_userId/usage/stats');
    } catch (e) {
      debugPrint('UsageProvider: FAILED to create usage doc: $e');
    }
  }

  // Clean zeroed daily map
  Map<String, int> _getInitialDailyMap() {
    return {
      'aiQueries': 0,
      'caseFinder': 0,
      'riskAnalysis': 0,
      'translator': 0,
      'courtOrders': 0,
      'scanToPdf': 0,
      'documents': 0,
    };
  }

  // Clean zeroed monthly map
  Map<String, int> _getInitialMonthlyMap() {
    return {
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

  void _resetLocalDailyVars() {
    _dailyAiQueries = 0;
    _dailyCaseFinder = 0;
    _dailyRiskAnalysis = 0;
    _dailyTranslator = 0;
    _dailyCourtOrders = 0;
    _dailyScanToPdf = 0;
    _dailyDocuments = 0;
  }

  void _resetLocalMonthlyVars() {
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
  }

  Future<void> reload() async {
    if (_usageSubscription == null) {
      _subscribeToFirestore();
    }
    await _syncPremiumStatus();
  }

  // Optimized logic check with Blocks
  String? canUseFeature(String featureName) {
    // Check Daily Limits first

    if (featureName == 'aiQueries' && _dailyAiQueries >= dailyAiQueriesLimit) {
      return 'Daily limit reached for AI Chat.';
    }
    if (featureName == 'caseFinder' &&
        _dailyCaseFinder >= dailyCaseFinderLimit) {
      return 'Daily limit reached for Case Finder.';
    }
    if (featureName == 'riskAnalysis' &&
        _dailyRiskAnalysis >= dailyRiskAnalysisLimit) {
      return 'Daily limit reached for Risk Analysis.';
    }
    if (featureName == 'translator' &&
        _dailyTranslator >= dailyTranslatorLimit) {
      return 'Daily limit reached for Translator.';
    }
    if (featureName == 'courtOrders' &&
        _dailyCourtOrders >= dailyCourtOrdersLimit) {
      return 'Daily limit reached for Court Orders.';
    }
    if (featureName == 'scanToPdf' && _dailyScanToPdf >= dailyScanToPdfLimit) {
      return 'Daily limit reached for Scanner.';
    }
    if (featureName == 'documents' && _dailyDocuments >= dailyDocumentsLimit) {
      return 'Daily limit reached for Documents.';
    }

    // Check Monthly Limits
    if (featureName == 'aiQueries' && _monthlyAiQueries >= aiQueriesLimit) {
      return 'Monthly limit reached for AI Chat.';
    }
    if (featureName == 'caseFinder' && _monthlyCaseFinder >= caseFinderLimit) {
      return 'Monthly limit reached for Case Finder.';
    }
    if (featureName == 'riskAnalysis' &&
        _monthlyRiskAnalysis >= riskAnalysisLimit) {
      return 'Monthly limit reached for Risk Analysis.';
    }
    if (featureName == 'translator' && _monthlyTranslator >= translatorLimit) {
      return 'Monthly limit reached for Translator.';
    }
    if (featureName == 'courtOrders' &&
        _monthlyCourtOrders >= courtOrdersLimit) {
      return 'Monthly limit reached for Court Orders.';
    }
    if (featureName == 'scanToPdf' && _monthlyScanToPdf >= scanToPdfLimit) {
      return 'Monthly limit reached for Scanner.';
    }
    if (featureName == 'documents' && _monthlyDocuments >= documentsLimit) {
      return 'Monthly limit reached for Documents.';
    }
    if (featureName == 'cases' && _monthlyCases >= casesLimit) {
      return 'Monthly limit reached for Cases.';
    }
    if (featureName == 'aiVoice' && _monthlyAiVoice >= aiVoiceLimit) {
      return 'Monthly limit reached for AI Voice.';
    }
    if (featureName == 'bareActs' && _monthlyBareActs >= bareActsLimit) {
      return 'Monthly limit reached for Bare Acts.';
    }
    if (featureName == 'chatHistory' &&
        _monthlyChatHistory >= chatHistoryLimit) {
      return 'Monthly limit reached for Chat History.';
    }
    if (featureName == 'certifiedCopy' &&
        _monthlyCertifiedCopy >= certifiedCopyLimit) {
      return 'Monthly limit reached for Certified Copy.';
    }
    if (featureName == 'diary' && _monthlyDiary >= diaryLimit) {
      return 'Monthly limit reached for Legal Diary.';
    }

    return null;
  }

  // Public increment methods
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

  // Main atomic increment function
  Future<void> _incrementFirestore(String featureKey,
      {required bool daily}) async {
    debugPrint(
        'UsageProvider: _incrementFirestore called for $featureKey (Daily: $daily)');

    // OPTIMISTIC UPDATE: Update local state immediately for real-time UI
    _incrementLocal(featureKey, daily: daily);
    notifyListeners();

    if (!_isAuthenticated) {
      debugPrint(
          'UsageProvider: User NOT authenticated. Cloud sync aborted (Local only).');
      return;
    }

    debugPrint(
        'UsageProvider: User authenticated ($_userId). Proceeding with Firestore increment.');

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final currentMonth =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

      // Always increment MONTHLY
      Map<String, dynamic> updates = {
        'lastUpdated': FieldValue.serverTimestamp(),
        'month': currentMonth, // Reinforce current month
        'monthly.$featureKey': FieldValue.increment(1),
      };

      // Conditionally increment DAILY
      if (daily) {
        updates['lastDailyReset'] = today; // Reinforce current day
        updates['daily.$featureKey'] = FieldValue.increment(1);
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('usage')
          .doc('stats')
          .set(
            updates,
            SetOptions(merge: true),
          );
      debugPrint(
          'UsageProvider: Successfully incremented $featureKey in Firestore.');
    } catch (e) {
      debugPrint('UsageProvider: Error incrementing usage in Firestore: $e');
      // Ideally revert local state here if failed, but for usage stats, over-counting is better than under-counting UI lag
    }
  }

  void _incrementLocal(String featureKey, {required bool daily}) {
    // Monthly always increments
    switch (featureKey) {
      case 'aiQueries':
        _monthlyAiQueries++;
        if (daily) _dailyAiQueries++;
        break;
      case 'caseFinder':
        _monthlyCaseFinder++;
        if (daily) _dailyCaseFinder++;
        break;
      case 'riskAnalysis':
        _monthlyRiskAnalysis++;
        if (daily) _dailyRiskAnalysis++;
        break;
      case 'translator':
        _monthlyTranslator++;
        if (daily) _dailyTranslator++;
        break;
      case 'courtOrders':
        _monthlyCourtOrders++;
        if (daily) _dailyCourtOrders++;
        break;
      case 'scanToPdf':
        _monthlyScanToPdf++;
        if (daily) _dailyScanToPdf++;
        break;
      case 'documents':
        _monthlyDocuments++;
        if (daily) _dailyDocuments++;
        break;
      case 'cases':
        _monthlyCases++;
        break;
      case 'aiVoice':
        _monthlyAiVoice++;
        break;
      case 'bareActs':
        _monthlyBareActs++;
        break;
      case 'chatHistory':
        _monthlyChatHistory++;
        break;
      case 'certifiedCopy':
        _monthlyCertifiedCopy++;
        break;
      case 'diary':
        _monthlyDiary++;
        break;
    }
  }

  // --- Hive Backup (Offline cache) ---

  Future<void> _saveToHive() async {
    if (_box == null) return;
    _box!.put(_getUserKey('dailyAiQueries'), _dailyAiQueries);
    _box!.put(_getUserKey('dailyCaseFinder'), _dailyCaseFinder);
    _box!.put(_getUserKey('dailyRiskAnalysis'), _dailyRiskAnalysis);
    _box!.put(_getUserKey('dailyTranslator'), _dailyTranslator);
    _box!.put(_getUserKey('dailyCourtOrders'), _dailyCourtOrders);
    _box!.put(_getUserKey('dailyScanToPdf'), _dailyScanToPdf);
    _box!.put(_getUserKey('dailyDocuments'), _dailyDocuments);

    _box!.put(_getUserKey('monthlyAiQueries'), _monthlyAiQueries);
    _box!.put(_getUserKey('monthlyCaseFinder'), _monthlyCaseFinder);
    _box!.put(_getUserKey('monthlyRiskAnalysis'), _monthlyRiskAnalysis);
    _box!.put(_getUserKey('monthlyTranslator'), _monthlyTranslator);
    _box!.put(_getUserKey('monthlyCourtOrders'), _monthlyCourtOrders);
    _box!.put(_getUserKey('monthlyScanToPdf'), _monthlyScanToPdf);
    _box!.put(_getUserKey('monthlyDocuments'), _monthlyDocuments);
    _box!.put(_getUserKey('monthlyCases'), _monthlyCases);
    _box!.put(_getUserKey('monthlyAiVoice'), _monthlyAiVoice);
    _box!.put(_getUserKey('monthlyBareActs'), _monthlyBareActs);
    _box!.put(_getUserKey('monthlyChatHistory'), _monthlyChatHistory);
    _box!.put(_getUserKey('monthlyCertifiedCopy'), _monthlyCertifiedCopy);
    _box!.put(_getUserKey('monthlyDiary'), _monthlyDiary);
  }

  Future<void> upgradeToPremium() async {
    _isPremium = true;
    if (_box != null) await _box!.put(_getUserKey('isPremium'), true);
    if (_isAuthenticated) {
      await _firestore
          .collection('users')
          .doc(_userId)
          .set({'isPremium': true}, SetOptions(merge: true));
    }
    notifyListeners();
  }
}
