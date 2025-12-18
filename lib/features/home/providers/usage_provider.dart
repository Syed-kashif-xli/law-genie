import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class UsageProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<DocumentSnapshot>? _usageSubscription;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  StreamSubscription<DocumentSnapshot>? _freeLimitsSubscription;
  StreamSubscription<DocumentSnapshot>? _premiumLimitsSubscription;

  String get _userId => _auth.currentUser?.uid ?? 'anonymous';
  bool get _isAuthenticated => _userId != 'anonymous';

  // --- State Variables ---
  bool _isPremium = false;
  bool _isLoading = true;
  String _currentPlan = "free";

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String get planName => _isPremium ? 'Premium Plan' : 'Free Plan';

  // --- Limits Storage ---
  Map<String, dynamic> _freeLimits = {};
  Map<String, dynamic> _premiumLimits = {};

  // --- User Counts ---
  Map<String, int> _dailyUsage = {};
  Map<String, int> _monthlyUsage = {};

  UsageProvider() {
    _init();
  }

  Future<void> reload() async {
    debugPrint('UsageProvider: Manual reload triggered');
    _subscribeToUserUsage();
  }

  void _init() {
    debugPrint('UsageProvider: Initializing Proactive Setup...');
    _bootstrapFirestore();
    _subscribeToLimitsConfig();

    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        _ensureUserDocumentExists(); // Create user profile if missing
        _subscribeToPlan();
        _subscribeToUserUsage();
      } else {
        _cancelSubscriptions();
        _resetLocalState();
        notifyListeners();
      }
    });

    if (_auth.currentUser != null) {
      _ensureUserDocumentExists();
      _subscribeToPlan();
      _subscribeToUserUsage();
    }
  }

  // --- 1. USERS COLLECTION (Proactive Creation) ---
  Future<void> _ensureUserDocumentExists() async {
    if (!_isAuthenticated) return;
    try {
      final userDoc = await _firestore.collection('users').doc(_userId).get();
      if (!userDoc.exists) {
        debugPrint('UsageProvider: Creating NEW user profile for $_userId');
        await _firestore.collection('users').doc(_userId).set({
          'plan': 'free',
          'createdAt': FieldValue.serverTimestamp(),
          'premiumExpiry': null,
          'isPremium': false, // Backward compatibility
        });
      }
    } catch (e) {
      debugPrint('UsageProvider: Error ensuring user doc: $e');
    }
  }

  // Real-time Plan Sync from users collection
  void _subscribeToPlan() {
    if (!_isAuthenticated) return;
    _userSubscription?.cancel();
    _userSubscription =
        _firestore.collection('users').doc(_userId).snapshots().listen((snap) {
      if (snap.exists) {
        final data = snap.data();
        if (data != null) {
          // Priority 1: 'plan' field, Priority 2: 'isPremium' field
          _currentPlan =
              data['plan'] ?? (data['isPremium'] == true ? 'premium' : 'free');
          _isPremium = (_currentPlan == "premium");
          debugPrint('UsageProvider: Real-time Plan Update -> $_currentPlan');
          notifyListeners();
        }
      }
    });
  }

  // --- 2. USAGE LIMITS CONFIGURATION ---
  Future<void> _bootstrapFirestore() async {
    try {
      final freeSnap =
          await _firestore.collection('usage_limits').doc('free').get();
      if (!freeSnap.exists) {
        debugPrint('UsageProvider: Bootstrapping Global free limits...');
        await _firestore.collection('usage_limits').doc('free').set({
          'aiChat': {'daily': 10, 'monthly': 100},
          'caseFinder': {'daily': 5, 'monthly': 50},
          'translator': {'daily': 20, 'monthly': 200},
          'riskAnalysis': {'daily': 3, 'monthly': 30},
          'courtOrders': {'daily': 10, 'monthly': 100},
          'scanner': {'daily': 30, 'monthly': 1000},
          'documents': {'daily': 5, 'monthly': 50},
          'myCases': {'monthly': 1000},
          'bareActs': {'monthly': 1000},
          'diary': {'monthly': 300},
          'certifiedCopy': {'monthly': 20},
          'chatHistory': {'monthly': 50},
        });
      }

      final premSnap =
          await _firestore.collection('usage_limits').doc('premium').get();
      if (!premSnap.exists) {
        debugPrint('UsageProvider: Bootstrapping Global premium limits...');
        await _firestore.collection('usage_limits').doc('premium').set({
          'aiChat': {'daily': 750, 'monthly': 7500},
          'caseFinder': {'daily': 250, 'monthly': 2500},
          'translator': {'daily': 1000, 'monthly': 10000},
          'riskAnalysis': {'daily': 150, 'monthly': 1500},
          'courtOrders': {'daily': 500, 'monthly': 5000},
          'scanner': {'daily': 500, 'monthly': 10000},
          'documents': {'daily': 25, 'monthly': 2500},
          'myCases': {'monthly': 5000},
          'bareActs': {'monthly': 20000},
          'diary': {'monthly': 15000},
          'certifiedCopy': {'monthly': 1000},
          'chatHistory': {'monthly': 1000},
        });
      }
    } catch (e) {
      debugPrint('UsageProvider: Bootstrap error: $e');
    }
  }

  void _subscribeToLimitsConfig() {
    _freeLimitsSubscription?.cancel();
    _freeLimitsSubscription = _firestore
        .collection('usage_limits')
        .doc('free')
        .snapshots()
        .listen((snap) {
      if (snap.exists) {
        _freeLimits = snap.data() ?? {};
        notifyListeners();
      }
    });

    _premiumLimitsSubscription?.cancel();
    _premiumLimitsSubscription = _firestore
        .collection('usage_limits')
        .doc('premium')
        .snapshots()
        .listen((snap) {
      if (snap.exists) {
        _premiumLimits = snap.data() ?? {};
        notifyListeners();
      }
    });
  }

  // --- 3. USAGE TRACKING (Daily & Monthly) ---
  void _subscribeToUserUsage() {
    if (!_isAuthenticated) return;
    _usageSubscription?.cancel();
    _usageSubscription = _firestore
        .collection('usage')
        .doc(_userId)
        .snapshots()
        .listen((snapshot) async {
      _isLoading = false;
      if (!snapshot.exists) {
        debugPrint(
            'UsageProvider: Usage record missing, initializing map structure...');
        await _initializeUsageDoc();
        return;
      }

      final data = snapshot.data();
      if (data == null) {
        notifyListeners();
        return;
      }

      final today = DateTime.now().toIso8601String().split('T')[0];
      final currentMonth =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

      final dailyMap = data['daily'] as Map? ?? {};
      final monthlyMap = data['monthly'] as Map? ?? {};

      // Smart Reset Check
      final String dReset =
          (dailyMap['lastReset'] ?? dailyMap['LastReset'] ?? "").toString();
      final String mReset =
          (monthlyMap['lastReset'] ?? monthlyMap['LastReset'] ?? "").toString();

      if (dReset != today || mReset != currentMonth) {
        debugPrint(
            'UsageProvider: Resetting counts for new period (Today: $today)');
        await _initializeUsageDoc();
        return;
      }

      _dailyUsage = Map<String, int>.from(dailyMap
          .map((k, v) => MapEntry(k.toString(), (v is num ? v.toInt() : 0))));
      _monthlyUsage = Map<String, int>.from(monthlyMap
          .map((k, v) => MapEntry(k.toString(), (v is num ? v.toInt() : 0))));

      notifyListeners();
    }, onError: (e) {
      debugPrint('UsageProvider: usage collection error: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  // --- Getters & Limit Logic ---
  int getLimit(String feature, {required bool isMonthly}) {
    final config = _isPremium ? _premiumLimits : _freeLimits;
    final featureConfig = config[feature] as Map?;
    if (featureConfig == null) return 0;
    return (featureConfig[isMonthly ? 'monthly' : 'daily'] ?? 0).toInt();
  }

  int getUsageCount(String feature, {required bool isMonthly}) {
    return (isMonthly ? _monthlyUsage[feature] : _dailyUsage[feature]) ?? 0;
  }

  // Mapping UI Getters
  int get aiQueriesUsage => getUsageCount('aiChat', isMonthly: true);
  int get aiQueriesLimit => getLimit('aiChat', isMonthly: true);
  int get dailyAiQueriesUsage => getUsageCount('aiChat', isMonthly: false);
  int get dailyAiQueriesLimit => getLimit('aiChat', isMonthly: false);
  int get caseFinderUsage => getUsageCount('caseFinder', isMonthly: true);
  int get caseFinderLimit => getLimit('caseFinder', isMonthly: true);
  int get dailyCaseFinderUsage => getUsageCount('caseFinder', isMonthly: false);
  int get dailyCaseFinderLimit => getLimit('caseFinder', isMonthly: false);
  int get translatorUsage => getUsageCount('translator', isMonthly: true);
  int get translatorLimit => getLimit('translator', isMonthly: true);
  int get dailyTranslatorUsage => getUsageCount('translator', isMonthly: false);
  int get dailyTranslatorLimit => getLimit('translator', isMonthly: false);
  int get riskAnalysisUsage => getUsageCount('riskAnalysis', isMonthly: true);
  int get riskAnalysisLimit => getLimit('riskAnalysis', isMonthly: true);
  int get dailyRiskAnalysisUsage =>
      getUsageCount('riskAnalysis', isMonthly: false);
  int get dailyRiskAnalysisLimit => getLimit('riskAnalysis', isMonthly: false);
  int get courtOrdersUsage => getUsageCount('courtOrders', isMonthly: true);
  int get courtOrdersLimit => getLimit('courtOrders', isMonthly: true);
  int get dailyCourtOrdersUsage =>
      getUsageCount('courtOrders', isMonthly: false);
  int get dailyCourtOrdersLimit => getLimit('courtOrders', isMonthly: false);
  int get scanToPdfUsage => getUsageCount('scanner', isMonthly: true);
  int get scanToPdfLimit => getLimit('scanner', isMonthly: true);
  int get dailyScanToPdfUsage => getUsageCount('scanner', isMonthly: false);
  int get dailyScanToPdfLimit => getLimit('scanner', isMonthly: false);
  int get documentsUsage => getUsageCount('documents', isMonthly: true);
  int get documentsLimit => getLimit('documents', isMonthly: true);
  int get dailyDocumentsUsage => getUsageCount('documents', isMonthly: false);
  int get dailyDocumentsLimit => getLimit('documents', isMonthly: false);
  int get bareActsUsage => getUsageCount('bareActs', isMonthly: true);
  int get bareActsLimit => getLimit('bareActs', isMonthly: true);
  int get diaryUsage => getUsageCount('diary', isMonthly: true);
  int get diaryLimit => getLimit('diary', isMonthly: true);
  int get chatHistoryUsage => getUsageCount('chatHistory', isMonthly: true);
  int get chatHistoryLimit => getLimit('chatHistory', isMonthly: true);
  int get certifiedCopyUsage => getUsageCount('certifiedCopy', isMonthly: true);
  int get certifiedCopyLimit => getLimit('certifiedCopy', isMonthly: true);
  int get casesUsage => getUsageCount('myCases', isMonthly: true);
  int get casesLimit => getLimit('myCases', isMonthly: true);

  String? canUseFeature(String feature) {
    if (_isLoading) return null;
    int dLimit = getLimit(feature, isMonthly: false);
    int mLimit = getLimit(feature, isMonthly: true);
    if (dLimit > 0 && getUsageCount(feature, isMonthly: false) >= dLimit)
      return 'Daily limit reached.';
    if (mLimit > 0 && getUsageCount(feature, isMonthly: true) >= mLimit)
      return 'Monthly limit reached.';
    return null;
  }

  // --- Increments ---
  Future<void> incrementUsage(String feature, {bool daily = true}) async {
    if (!_isAuthenticated) return;
    try {
      final docRef = _firestore.collection('usage').doc(_userId);
      final updateData = {
        'monthly.$feature': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      if (daily) updateData['daily.$feature'] = FieldValue.increment(1);

      try {
        await docRef.update(updateData);
      } catch (e) {
        await _initializeUsageDoc();
        await docRef.update(updateData);
      }
    } catch (e) {
      debugPrint('UsageProvider: Increment error on $feature: $e');
    }
  }

  Future<void> incrementAiQueries() async =>
      incrementUsage('aiChat', daily: true);
  Future<void> incrementCaseFinder() async =>
      incrementUsage('caseFinder', daily: true);
  Future<void> incrementTranslator() async =>
      incrementUsage('translator', daily: true);
  Future<void> incrementRiskAnalysis() async =>
      incrementUsage('riskAnalysis', daily: true);
  Future<void> incrementCourtOrders() async =>
      incrementUsage('courtOrders', daily: true);
  Future<void> incrementScanToPdf() async =>
      incrementUsage('scanner', daily: true);
  Future<void> incrementDocuments() async =>
      incrementUsage('documents', daily: true);
  Future<void> incrementCases() async =>
      incrementUsage('myCases', daily: false);
  Future<void> incrementBareActs() async =>
      incrementUsage('bareActs', daily: false);
  Future<void> incrementDiary() async => incrementUsage('diary', daily: false);
  Future<void> incrementChatHistory() async =>
      incrementUsage('chatHistory', daily: false);
  Future<void> incrementCertifiedCopy() async =>
      incrementUsage('certifiedCopy', daily: false);

  // Upgrade Plan
  Future<void> upgradeToPremium() async {
    if (!_isAuthenticated) return;
    try {
      await _firestore.collection('users').doc(_userId).set({
        'plan': 'premium',
        'isPremium': true,
        'premiumExpiry':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      }, SetOptions(merge: true));

      // Create a subscription record in order history
      String token =
          'SUB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      await _firestore.collection('orders').add({
        'token': token,
        'userId': _userId,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'details': {
          'type': 'subscription',
          'plan': 'premium',
          'amount': 499,
          'duration': '30 days',
        },
      });

      debugPrint('UsageProvider: Premium upgrade and order record created.');
    } catch (e) {
      debugPrint('Error upgrading user: $e');
    }
  }

  Future<void> _initializeUsageDoc() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final currentMonth =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    try {
      await _firestore.collection('usage').doc(_userId).set({
        'daily': {
          'lastReset': today,
          'aiChat': 0,
          'caseFinder': 0,
          'translator': 0,
          'riskAnalysis': 0,
          'scanner': 0,
          'documents': 0,
          'courtOrders': 0
        },
        'monthly': {
          'lastReset': currentMonth,
          'aiChat': 0,
          'caseFinder': 0,
          'translator': 0,
          'riskAnalysis': 0,
          'scanner': 0,
          'documents': 0,
          'myCases': 0,
          'bareActs': 0,
          'diary': 0,
          'certifiedCopy': 0,
          'chatHistory': 0
        },
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('UsageProvider: Usage init error: $e');
    }
  }

  void _cancelSubscriptions() {
    _usageSubscription?.cancel();
    _userSubscription?.cancel();
    _freeLimitsSubscription?.cancel();
    _premiumLimitsSubscription?.cancel();
  }

  void _resetLocalState() {
    _dailyUsage = {};
    _monthlyUsage = {};
    _isPremium = false;
    _currentPlan = "free";
    _isLoading = true;
  }
}
