import 'package:cloud_firestore/cloud_firestore.dart';

class Case {
  final String? id;
  final String title;
  final String description;
  final String caseNumber;
  final String courtName;
  final List<String> parties;
  final DateTime creationDate;
  final DateTime? nextHearingDate; // Added

  Case({
    this.id,
    required this.title,
    required this.description,
    required this.caseNumber,
    required this.courtName,
    required this.parties,
    required this.creationDate,
    this.nextHearingDate, // Added
  });

  // Factory constructor to create a Case from a Firestore document
  factory Case.fromMap(Map<String, dynamic> map, String id) {
    return Case(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      caseNumber: map['caseNumber'] ?? '',
      courtName: map['courtName'] ?? '',
      parties: List<String>.from(map['parties'] ?? []),
      creationDate: (map['creationDate'] as Timestamp).toDate(),
      nextHearingDate: map['nextHearingDate'] != null
          ? (map['nextHearingDate'] as Timestamp).toDate()
          : null, // Added
    );
  }

  // Method to convert a Case object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'caseNumber': caseNumber,
      'courtName': courtName,
      'parties': parties,
      'creationDate': Timestamp.fromDate(creationDate),
      'nextHearingDate': nextHearingDate != null
          ? Timestamp.fromDate(nextHearingDate!)
          : null, // Added
    };
  }

  Case copyWith({
    String? id,
    String? title,
    String? description,
    String? caseNumber,
    String? courtName,
    List<String>? parties,
    DateTime? creationDate,
    DateTime? nextHearingDate, // Added
  }) {
    return Case(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      caseNumber: caseNumber ?? this.caseNumber,
      courtName: courtName ?? this.courtName,
      parties: parties ?? this.parties,
      creationDate: creationDate ?? this.creationDate,
      nextHearingDate: nextHearingDate ?? this.nextHearingDate,
    );
  }
}
