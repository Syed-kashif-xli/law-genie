import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/case_model.dart';

class CaseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'cases';

  List<Case> _cases = [];
  bool _isLoading = false;

  List<Case> get cases => _cases;
  bool get isLoading => _isLoading;

  CaseProvider() {
    fetchCases();
  }

  Future<void> fetchCases() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection(_collectionPath).orderBy('creationDate', descending: true).get();
      _cases = snapshot.docs.map((doc) => Case.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Error fetching cases: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCase(Case newCase) async {
    try {
      final docRef = await _firestore.collection(_collectionPath).add(newCase.toMap());
      final createdCase = Case.fromMap(newCase.toMap(), docRef.id);
      _cases.insert(0, createdCase);
      notifyListeners();
    } catch (e) {
      print("Error adding case: $e");
    }
  }

  Future<void> updateCase(Case updatedCase) async {
    try {
      await _firestore.collection(_collectionPath).doc(updatedCase.id).update(updatedCase.toMap());
      final index = _cases.indexWhere((c) => c.id == updatedCase.id);
      if (index != -1) {
        _cases[index] = updatedCase;
        notifyListeners();
      }
    } catch (e) {
      print("Error updating case: $e");
    }
  }
}
