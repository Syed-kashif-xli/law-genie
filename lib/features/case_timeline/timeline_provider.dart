import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/timeline_event.dart';

import 'package:firebase_auth/firebase_auth.dart';

class TimelineProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  List<TimelineEvent> _events = [];
  bool _isLoading = true;
  StreamSubscription<QuerySnapshot>? _timelineSubscription;

  List<TimelineEvent> get events => _events;
  bool get isLoading => _isLoading;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Fetch timeline events for a specific case from Firestore
  Future<void> fetchTimelineEvents(String caseId) async {
    if (_userId == null) return;
    _setLoading(true);

    // Cancel any existing listener to avoid multiple streams
    await _timelineSubscription?.cancel();

    try {
      _timelineSubscription = _firestore
          .collection('users')
          .doc(_userId)
          .collection('cases')
          .doc(caseId)
          .collection('timeline') // Access the subcollection
          .orderBy('date', descending: false)
          .snapshots()
          .listen((snapshot) {
        _events = snapshot.docs
            .map((doc) => TimelineEvent.fromMap(doc.data(), doc.id))
            .toList();
        _setLoading(false);
      }, onError: (error) {
        _setLoading(false);
      });
    } catch (e) {
      _setLoading(false);
    }
  }

  // Add a new timeline event to a specific case
  Future<DocumentReference?> addTimelineEvent(
      String caseId, TimelineEvent event) async {
    if (_userId == null) return null;
    try {
      return await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cases')
          .doc(caseId)
          .collection('timeline')
          .add(event.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing timeline event in a specific case
  Future<void> updateTimelineEvent(String caseId, TimelineEvent event) async {
    if (_userId == null || event.id == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cases')
          .doc(caseId)
          .collection('timeline')
          .doc(event.id)
          .update(event.toMap());
    } catch (e) {
      // Handle error
    }
  }

  // Delete a timeline event from a specific case
  Future<void> deleteTimelineEvent(String caseId, String eventId) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cases')
          .doc(caseId)
          .collection('timeline')
          .doc(eventId)
          .delete();
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _timelineSubscription?.cancel();
    super.dispose();
  }
}
