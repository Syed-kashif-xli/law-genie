
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/features/case_timeline/timeline_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a stream of timeline events
  Stream<List<TimelineModel>> getTimelineEvents() {
    return _db.collection('timeline').snapshots().map((snapshot) => snapshot.docs.map((doc) => TimelineModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Add a new timeline event
  Future<void> addTimelineEvent(TimelineModel event) {
    return _db.collection('timeline').add(event.toMap());
  }

  // Update a timeline event
  Future<void> updateTimelineEvent(TimelineModel event) {
    return _db.collection('timeline').doc(event.id).update(event.toMap());
  }

  // Delete a timeline event
  Future<void> deleteTimelineEvent(String id) {
    return _db.collection('timeline').doc(id).delete();
  }
}
