import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/case_model.dart';

class CaseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'cases';

  List<Case> _cases = [];
  bool _isLoading = true;

  List<Case> get cases => _cases;
  bool get isLoading => _isLoading;

  CaseProvider() {
    fetchCases();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> fetchCases() async {
    try {
      _setLoading(true);
      final snapshot = await _firestore.collection(_collectionPath).orderBy('creationDate', descending: true).get();
      _cases = snapshot.docs.map((doc) => Case.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      // Handle error
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCase(Case caseItem) async {
    try {
      await _firestore.collection(_collectionPath).add(caseItem.toMap());
      fetchCases(); 
    } catch (e) {
      // Handle error
    }
  }

    Future<void> updateCase(Case caseItem) async {
    try {
      await _firestore.collection(_collectionPath).doc(caseItem.id).update(caseItem.toMap());
      fetchCases();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteCase(String caseId) async {
    try {
      await _firestore.collection(_collectionPath).doc(caseId).delete();
      fetchCases();
    } catch (e) {
     // Handle error
    }
  }
}
