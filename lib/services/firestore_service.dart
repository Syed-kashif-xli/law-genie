import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/timeline_event.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a stream of timeline events
  Stream<List<TimelineEvent>> getTimelineEvents() {
    return _db.collection('timeline').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => TimelineEvent.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Add a new timeline event
  Future<void> addTimelineEvent(TimelineEvent event) {
    return _db.collection('timeline').add(event.toMap());
  }

  // Update a timeline event
  Future<void> updateTimelineEvent(TimelineEvent event) {
    return _db.collection('timeline').doc(event.id).update(event.toMap());
  }

  // Delete a timeline event
  Future<void> deleteTimelineEvent(String id) {
    return _db.collection('timeline').doc(id).delete();
  }

  // Save terms and conditions acceptance
  Future<void> saveTermsAcceptance(String userId) {
    return _db.collection('user_acceptance').add({
      'acceptedAt': FieldValue.serverTimestamp(),
      'userId': userId,
    });
  }
}
