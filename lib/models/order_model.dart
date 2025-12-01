import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String token;
  final String userId;
  final String status; // 'received', 'searching', 'found', 'not_found'
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> details;

  OrderModel({
    required this.id,
    required this.token,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'userId': userId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'details': details,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      token: map['token'] ?? '',
      userId: map['userId'] ?? '',
      status: map['status'] ?? 'received',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      details: map['details'] ?? {},
    );
  }
}
