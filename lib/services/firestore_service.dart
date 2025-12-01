import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/timeline_event.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/models/order_model.dart';

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

  // Create or Update User
  Future<void> createOrUpdateUser(UserModel user) async {
    final userRef = _db.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      // Update last login
      await userRef.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        // Update other fields if they are not null in the new object
        if (user.displayName != null) 'displayName': user.displayName,
        if (user.photoUrl != null) 'photoUrl': user.photoUrl,
        if (user.phoneNumber != null) 'phoneNumber': user.phoneNumber,
        if (user.email != null) 'email': user.email,
      });
    } else {
      // Create new user
      await userRef.set(user.toMap());
    }
  }

  // Save terms and conditions acceptance
  Future<void> saveTermsAcceptance(String userId) {
    return _db.collection('users').doc(userId).update({
      'termsAcceptedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get User Data
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // --- Order Methods ---

  // Create Registry Order
  Future<void> createRegistryOrder(OrderModel order) async {
    // Use token as document ID for easy lookup
    await _db.collection('orders').doc(order.token).set(order.toMap());
  }

  // Stream Order by Token
  Stream<OrderModel?> streamOrder(String token) {
    return _db.collection('orders').doc(token).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return OrderModel.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  Future<OrderModel?> getUserLatestOrder(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docs = querySnapshot.docs;
        // Sort by createdAt descending
        docs.sort((a, b) {
          final t1 = a.data()['createdAt'] as Timestamp;
          final t2 = b.data()['createdAt'] as Timestamp;
          return t2.compareTo(t1);
        });

        return OrderModel.fromMap(docs.first.data(), docs.first.id);
      }
      return null;
    } catch (e) {
      print('Error fetching user latest order: $e');
      return null;
    }
  }
}
