import 'package:cloud_firestore/cloud_firestore.dart';

class Case {
  final String? id;
  final String title;
  final String description;
  final String caseNumber;
  final String courtName;
  final List<String> parties;
  final DateTime creationDate;

  Case({
    this.id,
    required this.title,
    required this.description,
    required this.caseNumber,
    required this.courtName,
    required this.parties,
    required this.creationDate,
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
  }) {
    return Case(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      caseNumber: caseNumber ?? this.caseNumber,
      courtName: courtName ?? this.courtName,
      parties: parties ?? this.parties,
      creationDate: creationDate ?? this.creationDate,
    );
  }
}
