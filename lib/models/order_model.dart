import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String token;
  final String userId;
  final String
      status; // 'received', 'searching', 'found', 'not_found', 'completed'
  final String? finalFileUrl;
  final DateTime? finalFileSentAt;
  final String? previewUrl;
  final String? previewStatus; // 'pending', 'sent', 'correct', 'wrong'
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> details;

  OrderModel({
    required this.id,
    required this.token,
    required this.userId,
    required this.status,
    this.previewUrl,
    this.previewStatus,
    this.finalFileUrl,
    this.finalFileSentAt,
    required this.createdAt,
    required this.updatedAt,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'userId': userId,
      'status': status,
      'previewUrl': previewUrl,
      'previewStatus': previewStatus,
      'finalFileUrl': finalFileUrl,
      'finalFileSentAt':
          finalFileSentAt != null ? Timestamp.fromDate(finalFileSentAt!) : null,
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
      previewUrl: map['previewUrl'],
      previewStatus: map['previewStatus'],
      finalFileUrl: map['finalFileUrl'],
      finalFileSentAt: map['finalFileSentAt'] != null
          ? (map['finalFileSentAt'] as Timestamp).toDate()
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      details: map['details'] ?? {},
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, token: $token, status: $status, previewUrl: $previewUrl, finalFileUrl: $finalFileUrl)';
  }
}
