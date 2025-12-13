import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/case_model.dart';

import 'package:firebase_auth/firebase_auth.dart';

class CaseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

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
    if (_userId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    try {
      _setLoading(true);
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cases')
          .orderBy('creationDate', descending: true)
          .get();
      _cases =
          snapshot.docs.map((doc) => Case.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint("Error fetching cases: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<DocumentReference?> addCase(Case caseItem) async {
    if (_userId == null) {
      debugPrint("Error adding case: User ID is null");
      return null;
    }
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cases')
          .add(caseItem.toMap());
      await fetchCases();
      return docRef;
    } catch (e) {
      debugPrint("Error adding case: $e");
      rethrow; // Rethrow to let UI know
    }
  }

  Future<void> updateCase(Case caseItem) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cases')
          .doc(caseItem.id)
          .update(caseItem.toMap());
      await fetchCases();
    } catch (e) {
      debugPrint("Error updating case: $e");
      rethrow;
    }
  }

  Future<void> deleteCase(String caseId) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cases')
          .doc(caseId)
          .delete();
      await fetchCases();
    } catch (e) {
      debugPrint("Error deleting case: $e");
    }
  }
}
