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
    if (_userId == null) return;
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
      // Handle error
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCase(Case caseItem) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cases')
          .add(caseItem.toMap());
      fetchCases();
    } catch (e) {
      // Handle error
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
      fetchCases();
    } catch (e) {
      // Handle error
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
      fetchCases();
    } catch (e) {
      // Handle error
    }
  }
}
