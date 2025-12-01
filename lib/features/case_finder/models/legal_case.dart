class LegalCase {
  final String id;
  final String title;
  final String court;
  final String caseNumber;
  final DateTime? date;
  final String? summary;
  final String? judgeName;
  final String? url;
  final String? category;

  LegalCase({
    required this.id,
    required this.title,
    required this.court,
    required this.caseNumber,
    this.date,
    this.summary,
    this.judgeName,
    this.url,
    this.category,
    this.cnrNumber,
    this.status,
    this.nextHearingDate,
    this.petitioner,
    this.respondent,
  });

  final String? cnrNumber;
  final String? status;
  final String? nextHearingDate;
  final String? petitioner;
  final String? respondent;

  factory LegalCase.fromJson(Map<String, dynamic> json) {
    return LegalCase(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      court: json['court'] ?? '',
      caseNumber: json['caseNumber'] ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      summary: json['summary'],
      judgeName: json['judgeName'],
      url: json['url'],
      category: json['category'],
      cnrNumber: json['cnrNumber'],
      status: json['status'],
      nextHearingDate: json['nextHearingDate'],
      petitioner: json['petitioner'],
      respondent: json['respondent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'court': court,
      'caseNumber': caseNumber,
      'date': date?.toIso8601String(),
      'summary': summary,
      'judgeName': judgeName,
      'url': url,
      'category': category,
      'cnrNumber': cnrNumber,
      'status': status,
      'nextHearingDate': nextHearingDate,
      'petitioner': petitioner,
      'respondent': respondent,
    };
  }

  String get formattedDate {
    if (date == null) return 'Date not available';
    return '${date!.day}/${date!.month}/${date!.year}';
  }

  String get courtShortName {
    if (court.contains('Supreme Court')) return 'SC';
    if (court.contains('High Court')) return 'HC';
    if (court.contains('Delhi')) return 'Delhi HC';
    if (court.contains('Bombay')) return 'Bombay HC';
    return court;
  }
}
