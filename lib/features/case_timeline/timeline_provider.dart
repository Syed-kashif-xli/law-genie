import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/timeline_event.dart';

class TimelineProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'cases'; // Now targeting the 'cases' collection

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
    _setLoading(true);

    // Cancel any existing listener to avoid multiple streams
    await _timelineSubscription?.cancel();

    try {
      _timelineSubscription = _firestore
          .collection(_collectionPath)
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
  Future<DocumentReference> addTimelineEvent(String caseId, TimelineEvent event) async {
    try {
      return await _firestore
          .collection(_collectionPath)
          .doc(caseId)
          .collection('timeline')
          .add(event.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing timeline event in a specific case
  Future<void> updateTimelineEvent(String caseId, TimelineEvent event) async {
    if (event.id == null) return;
    try {
      await _firestore
          .collection(_collectionPath)
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
    try {
      await _firestore
          .collection(_collectionPath)
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
