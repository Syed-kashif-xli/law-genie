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

  // Premium Users (Unlimited)
  static const int premiumLimit = 999999;
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
  int get aiQueriesLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.monthlyAiQueries;
  int get caseFinderLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.monthlyCaseFinder;
  int get riskAnalysisLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.monthlyRiskAnalysis;
  int get translatorLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.monthlyTranslator;
  int get courtOrdersLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.monthlyCourtOrders;
  int get scanToPdfLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.monthlyScanToPdf;
  int get documentsLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.monthlyDocuments;
  int get casesLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.monthlyCases;
  int get aiVoiceLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.monthlyAiVoice;
  int get bareActsLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.monthlyBareActs;
  int get chatHistoryLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.monthlyChatHistory;
  int get certifiedCopyLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.monthlyCertifiedCopy;
  int get diaryLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.monthlyDiary;

  // Daily Limits
  int get dailyAiQueriesLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.dailyAiQueries;
  int get dailyCaseFinderLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.dailyCaseFinder;
  int get dailyRiskAnalysisLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.dailyRiskAnalysis;
  int get dailyTranslatorLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.dailyTranslator;
  int get dailyCourtOrdersLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.dailyCourtOrders;
  int get dailyScanToPdfLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.dailyScanToPdf;
  int get dailyDocumentsLimit =>
      _isPremium ? UsageLimits.premiumLimit : UsageLimits.dailyDocuments;

  UsageProvider() {
    _init();
  }

  Future<void> _init() async {
    // Open Hive solely as a fallback/cache
    _box = await Hive.openBox('usage_stats_v2');

    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        debugPrint(
            'UsageProvider: Auth state changed. User entered: ${user.uid}');
        // Immediately start listening to Firestore
        _subscribeToFirestore();
        // Also check if premium status is synced
        await _syncPremiumStatus();
      } else {
        debugPrint('UsageProvider: Auth state changed. User logged out.');
        _cancelSubscription();
        _resetLocalState();
        notifyListeners();
      }
    });

    if (_isAuthenticated) {
      _subscribeToFirestore();
      await _syncPremiumStatus();
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

    // Cancel any existing subscription
    _cancelSubscription();

    _usageSubscription = _firestore
        .collection('usage_stats')
        .doc(_userId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) {
        // Create the doc if it doesn't exist
        await _initializeFirestoreDoc();
        return;
      }

      final data = snapshot.data();
      if (data == null) return;

      _isLoading = false;

      // Dates checking
      final serverMonth = data['month'] as String?;
      final serverDailyDate = data['lastDailyReset'] as String?;

      final today = DateTime.now().toIso8601String().split('T')[0];
      final currentMonth =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

      bool needsUpdate = false;
      Map<String, dynamic> updateData = {};

      // 1. Check Daily Reset
      if (serverDailyDate != today) {
        // It's a new day (or data is missing). Reset daily counts in logic.
        // We will trigger a firestore update to clear them.
        updateData['daily'] = {}; // Clear daily map
        updateData['lastDailyReset'] = today;
        needsUpdate = true;
        // Optimization: We can treat local _daily vars as 0 immediately
        _resetLocalDailyVars();
      } else {
        // It is today, read daily counts
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
        // It's a new month. Reset monthly counts.
        updateData['monthly'] = {}; // Clear monthly map
        updateData['month'] = currentMonth;
        needsUpdate = true;
        _resetLocalMonthlyVars();
      } else {
        // It is current month, read monthly counts

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
      _saveToHive(); // Backup to Hive for offline start

      if (needsUpdate) {
        await _firestore
            .collection('usage_stats')
            .doc(_userId)
            .set(updateData, SetOptions(merge: true));
      }
    }, onError: (e) {
      debugPrint('UsageProvider: Firestore stream error: $e');
    });
  }

  Future<void> _initializeFirestoreDoc() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final currentMonth =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

    await _firestore.collection('usage_stats').doc(_userId).set({
      'month': currentMonth,
      'lastDailyReset': today,
      'daily': {},
      'monthly': {},
      'lastUpdated': FieldValue.serverTimestamp(),
    });
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

  // Re-uses reload logic for manual checking (though stream is auto)
  Future<void> reload() async {
    // We don't really need to do anything as the stream is active.
    // However, if the stream is dead, we can retry.
    if (_usageSubscription == null) {
      _subscribeToFirestore();
    }
    // Also sync premium status just in case
    await _syncPremiumStatus();
  }

  String? canUseFeature(String featureName) {
    if (_isPremium) return null;

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

  // Helper for increments (API)
  Future<void> _increment(String featureKey, {bool daily = false}) async {
    // We increment in Firestore. The stream will update our local vars automatically.
    // However, to make UI feel instant, we CAN pre-increment locally, but
    // since the stream is fast enough usually, sticking to Firestore is safer for sync.
    // If we want instant feedback, we can do optimistic update?
    // Let's rely on stream for correctness, but maybe safe for quick UI.
    // Actually, `snapshot` from Firestore includes potential local writes immediately!
    // So writing to Firestore IS optimistic locally automatically.

    await _incrementFirestore(featureKey, daily: daily);
  }

  Future<void> _incrementFirestore(String featureKey,
      {required bool daily}) async {
    if (!_isAuthenticated) return;
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final currentMonth =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

      Map<String, dynamic> updates = {
        'lastUpdated': FieldValue.serverTimestamp(),
        // Ensure we reinforce date correctness on every write
        'month': currentMonth,
        'lastDailyReset': today,
        'monthly.$featureKey': FieldValue.increment(1),
      };

      if (daily) {
        updates['daily.$featureKey'] = FieldValue.increment(1);
      }

      await _firestore.collection('usage_stats').doc(_userId).set(
            updates,
            SetOptions(merge: true),
          );
    } catch (e) {
      debugPrint('Error incrementing usage in Firestore: $e');
    }
  }

  // --- Hive Backup (For offline init speed before stream connects) ---

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

  // Specific Incrementers
  Future<void> incrementAiQueries() async =>
      await _increment('aiQueries', daily: true);
  Future<void> incrementCaseFinder() async =>
      await _increment('caseFinder', daily: true);
  Future<void> incrementRiskAnalysis() async =>
      await _increment('riskAnalysis', daily: true);
  Future<void> incrementTranslator() async =>
      await _increment('translator', daily: true);
  Future<void> incrementCourtOrders() async =>
      await _increment('courtOrders', daily: true);
  Future<void> incrementScanToPdf() async =>
      await _increment('scanToPdf', daily: true);
  Future<void> incrementDocuments() async =>
      await _increment('documents', daily: true);

  Future<void> incrementCases() async => await _increment('cases');
  Future<void> incrementAiVoice() async => await _increment('aiVoice');
  Future<void> incrementBareActs() async => await _increment('bareActs');
  Future<void> incrementChatHistory() async => await _increment('chatHistory');
  Future<void> incrementCertifiedCopy() async =>
      await _increment('certifiedCopy');
  Future<void> incrementDiary() async => await _increment('diary');

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
