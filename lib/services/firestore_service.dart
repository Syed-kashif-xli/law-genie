import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
      // User already exists - UPDATE only necessary fields
      debugPrint('FirestoreService: Updating existing user ${user.uid}');
      await userRef.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        // Update other fields ONLY if they are not null in the new object
        if (user.displayName != null) 'displayName': user.displayName,
        if (user.photoUrl != null) 'photoUrl': user.photoUrl,
        if (user.phoneNumber != null) 'phoneNumber': user.phoneNumber,
        if (user.email != null) 'email': user.email,
        // NEVER update createdAt for existing users
      });
    } else {
      // New user - CREATE with all fields
      debugPrint('FirestoreService: Creating new user ${user.uid}');
      final userData = user.toMap();
      // Ensure createdAt is set for new users
      if (userData['createdAt'] == null) {
        userData['createdAt'] = FieldValue.serverTimestamp();
      }
      // Also set lastLoginAt for new users
      userData['lastLoginAt'] = FieldValue.serverTimestamp();

      // Set a professional default name for new users (like phone logins)
      if (userData['displayName'] == null ||
          userData['displayName'].toString().isEmpty) {
        userData['displayName'] = 'Genie Legal Pro';
      }

      await userRef.set(userData);
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
          final t1 = a.data()['createdAt'] as Timestamp?;
          final t2 = b.data()['createdAt'] as Timestamp?;
          if (t1 == null && t2 == null) return 0;
          if (t1 == null) return 1;
          if (t2 == null) return -1;
          return t2.compareTo(t1);
        });

        return OrderModel.fromMap(docs.first.data(), docs.first.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user latest order: $e');
      return null;
    }
  }

  // Get all orders for a user
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      final docs = querySnapshot.docs;
      // Sort by createdAt descending
      docs.sort((a, b) {
        final t1 = a.data()['createdAt'] as Timestamp;
        final t2 = b.data()['createdAt'] as Timestamp;
        return t2.compareTo(t1);
      });

      return docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('Error fetching user orders: $e');
      return [];
    }
  }

  // --- Daily Limit Methods (Certified Copy Separate System) ---

  // Stream for live limit updates
  Stream<Map<String, dynamic>?> getCertifiedCopyLimitStream() {
    return _db.collection('system').doc('limits').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (data.containsKey('count limits')) {
          final limitsMap = data['count limits'] as Map<String, dynamic>;
          if (limitsMap.containsKey('certifiedCopy')) {
            return limitsMap['certifiedCopy'] as Map<String, dynamic>;
          }
        }
      }
      return null;
    });
  }

  // Check if daily limit is reached
  Future<bool> checkDailyLimit() async {
    try {
      final docRef = _db.collection('system').doc('limits');
      final doc = await docRef.get();

      if (!doc.exists) return true; // Default to allow if config missing

      final data = doc.data()!;
      if (!data.containsKey('count limits')) return true;

      final limitsMap = data['count limits'] as Map<String, dynamic>;
      final ccMap = limitsMap['certifiedCopy'] as Map<String, dynamic>?;

      if (ccMap == null) return true;

      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final storedDate = ccMap['date'] as String?;
      final count = ccMap['count'] as int? ?? 0;
      final limit = ccMap['limit'] as int? ?? 20;

      if (storedDate == todayStr) {
        if (count >= limit) {
          return false;
        }
      }
      // If date is old, we assume it will reset on next increment, so allow.
      return true;
    } catch (e) {
      debugPrint('Error checking daily limit: $e');
      return true;
    }
  }

  // Increase the daily limit count
  Future<void> increaseLimitCount() async {
    final docRef = _db.collection('system').doc('limits');
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    try {
      await _db.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        // Default structure
        Map<String, dynamic> newCcMap = {
          'date': todayStr,
          'count': 1,
          'limit': 20
        };

        if (doc.exists) {
          final data = doc.data()!;
          final limitsMap =
              Map<String, dynamic>.from(data['count limits'] ?? {});
          final ccMap =
              Map<String, dynamic>.from(limitsMap['certifiedCopy'] ?? {});

          final storedDate = ccMap['date'] as String?;
          int currentCount = ccMap['count'] as int? ?? 0;
          int currentLimit = ccMap['limit'] as int? ?? 20;

          if (storedDate == todayStr) {
            newCcMap = {
              'date': todayStr,
              'count': currentCount + 1,
              'limit': currentLimit
            };
          } else {
            // Reset for new day
            newCcMap = {'date': todayStr, 'count': 1, 'limit': currentLimit};
          }

          limitsMap['certifiedCopy'] = newCcMap;
          transaction.update(docRef, {'count limits': limitsMap});
        } else {
          // Create doc if missing
          transaction.set(docRef, {
            'count limits': {'certifiedCopy': newCcMap}
          });
        }
      });
    } catch (e) {
      debugPrint('Error increasing limit count: $e');
    }
  }

  // Update Order Preview Status
  Future<void> updateOrderPreviewStatus(String orderId, String status) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'previewStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating order preview status: $e');
    }
  }

  // Update Order Status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }

  // Update Order with Final Payment Details
  Future<void> updateOrderFinalPayment({
    required String orderId,
    required double amount,
    required String paymentId,
    required String email,
    required String phone,
  }) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': 'completed',
        'finalPayment': {
          'amount': amount,
          'paymentId': paymentId,
          'email': email,
          'phone': phone,
          'paidAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating order final payment: $e');
    }
  }

  // Update Order with Final File URL
  Future<void> updateOrderFinalFile(String orderId, String fileUrl) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'finalFileUrl': fileUrl,
        'finalFileSentAt': FieldValue.serverTimestamp(),
        'status': 'completed', // Ensure status is completed
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating order final file: $e');
    }
  }
}
