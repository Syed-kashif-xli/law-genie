import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Enum to represent the status of a timeline event
enum TimelineStatus {
  completed,
  ongoing,
  upcoming,
}

// Model for a single event in the case timeline
class TimelineEvent {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final TimelineStatus status;
  final IconData icon;
  final DateTime? reminderDate;

  TimelineEvent({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    required this.icon,
    this.reminderDate,
  });

  // Convert a TimelineEvent into a Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'status': status.toString(),
      'icon': icon.codePoint,
      'reminderDate': reminderDate != null ? Timestamp.fromDate(reminderDate!) : null,
    };
  }

  // Create a TimelineEvent from a Map
  factory TimelineEvent.fromMap(Map<String, dynamic> map, String documentId) {
    return TimelineEvent(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      status: TimelineStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => TimelineStatus.upcoming,
      ),
      icon: IconData(map['icon'] ?? Icons.error.codePoint,
          fontFamily: 'MaterialIcons'),
      reminderDate: map['reminderDate'] != null ? (map['reminderDate'] as Timestamp).toDate() : null,
    );
  }

  // CopyWith method to update fields
  TimelineEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimelineStatus? status,
    IconData? icon,
    DateTime? reminderDate,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      icon: icon ?? this.icon,
      reminderDate: reminderDate ?? this.reminderDate,
    );
  }
}
