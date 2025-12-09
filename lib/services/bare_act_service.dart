import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../features/bare_acts/models/bare_act.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

class BareActService {
  final CollectionReference _actsCollection =
      FirebaseFirestore.instance.collection('bare_acts');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Cache to avoid frequent reads
  List<BareAct> _cachedActs = [];

  Future<List<BareAct>> getAllActs() async {
    // 1. Try to load from local Hive cache first (FASTEST)
    try {
      final box = await Hive.openBox('bare_acts_cache');

      if (box.isNotEmpty) {
        final List<dynamic> rawList = box.get('acts', defaultValue: []);
        if (rawList.isNotEmpty) {
          _cachedActs = rawList
              .map(
                  (e) => BareAct.fromMap(Map<String, dynamic>.from(e), e['id']))
              .toList();

          // If we have data, sort and return immediately!
          // We will fetch fresh data in background if needed (optional optimization)
          if (_cachedActs.isNotEmpty) {
            _sortActs();
            // Trigger background refresh but don't await it
            _fetchFromStorage().then((freshActs) {
              if (freshActs.isNotEmpty &&
                  freshActs.length != _cachedActs.length) {
                // Determine if we need to update cache
                _cacheActs(freshActs);
              }
            });
            return _cachedActs;
          }
        }
      }
    } catch (e) {
      debugPrint('Hive cache error: $e');
    }

    // 2. If memory cache is already populated (fallback)
    if (_cachedActs.isNotEmpty) return _cachedActs;

    try {
      // 3. If no cache, fetch from Firestore/Storage
      // Try fetching from Firestore first
      final snapshot = await _actsCollection.get();

      if (snapshot.docs.isNotEmpty) {
        _cachedActs = snapshot.docs
            .map((doc) =>
                BareAct.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      } else {
        // Fallback to Firebase Storage
        _cachedActs = await _fetchFromStorage();

        // AUTO-MIGRATION: Save found acts to Firestore for super-fast future access
        // This runs only once when the database is empty.
        if (_cachedActs.isNotEmpty) {
          _populateFirestore(_cachedActs);
        }
      }

      // 4. Save to Hive Cache
      if (_cachedActs.isNotEmpty) {
        await _cacheActs(_cachedActs);
      }

      // Sort
      _sortActs();

      return _cachedActs;
    } catch (e) {
      debugPrint('Error fetching acts: $e');
      return _cachedActs;
    }
  }

  Future<void> _populateFirestore(List<BareAct> acts) async {
    // Firestore batch limit is 500. We have ~535 acts.
    // We must split into chunks.
    const int batchSize = 450;
    for (var i = 0; i < acts.length; i += batchSize) {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      final end = (i + batchSize < acts.length) ? i + batchSize : acts.length;
      final chunk = acts.sublist(i, end);

      for (final act in chunk) {
        // Use a clean ID based on title if possible, or random
        // Here we use the existing act.id (which is the file path).
        // Firestore IDs cannot contain slashes. We must sanitize it.
        final String safeId = act.id.replaceAll('/', '_').replaceAll('.', '_');

        final docRef = _actsCollection.doc(safeId);
        batch.set(docRef, act.toMap());
      }

      try {
        await batch.commit();
        debugPrint('Migrated batch ${i ~/ batchSize + 1} to Firestore');
      } catch (e) {
        debugPrint('Error migrating batch to Firestore: $e');
      }
    }
  }

  Future<void> _cacheActs(List<BareAct> acts) async {
    try {
      final box = await Hive.openBox('bare_acts_cache');
      final List<Map<String, dynamic>> serialized = acts
          .map((a) => {
                'id': a.id,
                'title': a.title,
                'category': a.category,
                'pdfUrl': a.pdfUrl,
                'year': a.year,
              })
          .toList();
      await box.put('acts', serialized);
    } catch (e) {
      debugPrint('Error caching acts: $e');
    }
  }

  Future<List<BareAct>> _fetchFromStorage() async {
    List<BareAct> storageActs = [];
    try {
      final Reference rootRef = _storage.ref().child('bare_acts');
      final ListResult result = await rootRef.listAll();

      // A. Process files in the root 'bare_acts' folder
      for (var fileRef in result.items) {
        storageActs.add(await _createActFromFile(fileRef, 'General'));
      }

      // B. Process subfolders (categories)
      // Note: listAll() on root mainly gets files/prefixes.
      // If there are many folders, this loop might slow down initial fetch.
      // But for <1000 items it should be okay.
      for (var folderRef in result.prefixes) {
        final String categoryName = folderRef.name;

        final ListResult folderResult = await folderRef.listAll();

        for (var fileRef in folderResult.items) {
          storageActs.add(await _createActFromFile(fileRef, categoryName));
        }
      }
    } catch (e) {
      debugPrint('Error fetching from storage: $e');
    }
    return storageActs;
  }

  Future<BareAct> _createActFromFile(Reference fileRef, String category) async {
    // Optimization: DO NOT fetch download URL here. It causes N+1 network requests.
    // We store the fullPath in the pdfUrl field temporarily.
    // The UI will resolve the actual URL when the user clicks on the act.

    final String filename = fileRef.name;

    // Remove .pdf extension for title
    final String title =
        filename.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');

    // Extract year using regex (looks for 4 digits starting with 19 or 20)
    final RegExp yearRegex = RegExp(r'\b(19|20)\d{2}\b');
    final String year = yearRegex.firstMatch(title)?.group(0) ?? '';

    return BareAct(
      id: fileRef.fullPath, // Use path as unique ID
      title: title,
      category: category,
      pdfUrl: fileRef.fullPath, // STORE PATH HERE, NOT URL
      year: year,
    );
  }

  // New method to fetch the actual URL when needed
  Future<String> resolvePdfUrl(BareAct act) async {
    // If it's already a http URL, return it
    if (act.pdfUrl.startsWith('http')) return act.pdfUrl;

    // Otherwise, assume it's a storage path and fetch the URL
    try {
      final ref =
          _storage.ref().child(act.pdfUrl); // act.pdfUrl contains the path now
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error resolving URL for ${act.title}: $e');
      return '';
    }
  }

  void _sortActs() {
    _cachedActs.sort((a, b) {
      // Parse years to int for comparison, handling empty years
      int yearA = int.tryParse(a.year) ?? 0;
      int yearB = int.tryParse(b.year) ?? 0;

      int yearComp = yearB.compareTo(yearA); // Descending
      if (yearComp != 0) return yearComp;
      return a.title.compareTo(b.title);
    });
  }

  Future<List<BareAct>> searchActs(String query) async {
    if (query.isEmpty) {
      return _cachedActs.isNotEmpty ? _cachedActs : getAllActs();
    }

    // Ensure we have data
    if (_cachedActs.isEmpty) await getAllActs();

    final q = query.toLowerCase();
    return _cachedActs
        .where((act) =>
            act.title.toLowerCase().contains(q) ||
            act.category.toLowerCase().contains(q) ||
            act.year.contains(q))
        .toList();
  }

  Future<List<BareAct>> getActsByCategory(String category) async {
    if (_cachedActs.isEmpty) await getAllActs();

    if (category == 'All') return _cachedActs;
    return _cachedActs.where((act) => act.category == category).toList();
  }

  // Categories are derived dynamically
  List<String> getCategories() {
    if (_cachedActs.isEmpty) return ['All'];

    final categories = _cachedActs.map((e) => e.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }
}
