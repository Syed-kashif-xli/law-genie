
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Enum to represent the status of a timeline event
enum TimelineStatus {
  completed,
  ongoing,
  upcoming,
}

// Model for a single event in the case timeline
class TimelineModel {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final TimelineStatus status;
  final IconData icon;

  TimelineModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    required this.icon,
  });

  // Convert a TimelineModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'status': status.toString(),
      'icon': icon.codePoint,
    };
  }

  // Create a TimelineModel from a Map
  factory TimelineModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TimelineModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      status: TimelineStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => TimelineStatus.upcoming,
      ),
      icon: IconData(map['icon'] ?? Icons.error.codePoint, fontFamily: 'MaterialIcons'),
    );
  }

  // CopyWith method to update fields
  TimelineModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimelineStatus? status,
    IconData? icon,
  }) {
    return TimelineModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      icon: icon ?? this.icon,
    );
  }
}
