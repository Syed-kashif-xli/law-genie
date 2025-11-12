import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/features/case_timeline/timeline_model.dart';

class TimelineProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'timeline';

  List<TimelineModel> _timeline = [];
  bool _isLoading = true;

  List<TimelineModel> get timeline => _timeline;
  bool get isLoading => _isLoading;

  TimelineProvider() {
    _fetchTimelineEvents();
  }

  // Fetch timeline events from Firestore
  Future<void> _fetchTimelineEvents() async {
    try {
      _firestore
          .collection(_collectionPath)
          .orderBy('date', descending: false)
          .snapshots()
          .listen((snapshot) {
        _timeline = snapshot.docs
            .map((doc) => TimelineModel.fromMap(doc.data(), doc.id))
            .toList();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new timeline event to Firestore
  Future<void> addTimelineEvent(TimelineModel event) async {
    try {
      await _firestore.collection(_collectionPath).add(event.toMap());
    } catch (e) {
      // Handle error
    }
  }

  // Update an existing timeline event
  Future<void> updateTimelineEvent(TimelineModel event) async {
    if (event.id == null) return;
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(event.id)
          .update(event.toMap());
    } catch (e) {
      // Handle error
    }
  }

  // Delete a timeline event
  Future<void> deleteTimelineEvent(String id) async {
    try {
      await _firestore.collection(_collectionPath).doc(id).delete();
    } catch (e) {
      // Handle error
    }
  }
}
