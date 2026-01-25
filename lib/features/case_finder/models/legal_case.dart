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

  final String? cnrNumber;
  final String? status;
  final String? nextHearingDate;
  final String? petitioner;
  final String? respondent;

  // New Fields for Detailed View
  final String? caseType;
  final String? registrationNumber;
  final String? registrationDate;
  final String? firstHearingDate;
  final String? caseStage;
  final String? petitionerAdvocate;
  final String? respondentAdvocate;

  // Extra Fields found in HTML blobs
  final String? acts;
  final List<String>? extraPetitioners;
  final List<String>? extraRespondents;

  // New Detailed History and Orders
  final List<HearingRecord>? hearingHistory;
  final List<OrderRecord>? interimOrders;
  final List<OrderRecord>? finalOrders;
  final List<TransferRecord>? transfers;

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
    this.caseType,
    this.registrationNumber,
    this.registrationDate,
    this.firstHearingDate,
    this.caseStage,
    this.petitionerAdvocate,
    this.respondentAdvocate,
    this.acts,
    this.extraPetitioners,
    this.extraRespondents,
    this.hearingHistory,
    this.interimOrders,
    this.finalOrders,
    this.transfers,
  });

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
      caseType: json['caseType'],
      registrationNumber: json['registrationNumber'],
      registrationDate: json['registrationDate'],
      firstHearingDate: json['firstHearingDate'],
      caseStage: json['caseStage'],
      petitionerAdvocate: json['petitionerAdvocate'],
      respondentAdvocate: json['respondentAdvocate'],
      acts: json['acts'],
      extraPetitioners: json['extraPetitioners'] != null
          ? List<String>.from(json['extraPetitioners'])
          : null,
      extraRespondents: json['extraRespondents'] != null
          ? List<String>.from(json['extraRespondents'])
          : null,
      hearingHistory: json['hearingHistory'] != null
          ? (json['hearingHistory'] as List)
              .map((e) => HearingRecord.fromJson(e))
              .toList()
          : null,
      interimOrders: json['interimOrders'] != null
          ? (json['interimOrders'] as List)
              .map((e) => OrderRecord.fromJson(e))
              .toList()
          : null,
      finalOrders: json['finalOrders'] != null
          ? (json['finalOrders'] as List)
              .map((e) => OrderRecord.fromJson(e))
              .toList()
          : null,
      transfers: json['transfers'] != null
          ? (json['transfers'] as List)
              .map((e) => TransferRecord.fromJson(e))
              .toList()
          : null,
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
      'caseType': caseType,
      'registrationNumber': registrationNumber,
      'registrationDate': registrationDate,
      'firstHearingDate': firstHearingDate,
      'caseStage': caseStage,
      'petitionerAdvocate': petitionerAdvocate,
      'respondentAdvocate': respondentAdvocate,
      'acts': acts,
      'extraPetitioners': extraPetitioners,
      'extraRespondents': extraRespondents,
      'hearingHistory': hearingHistory?.map((e) => e.toJson()).toList(),
      'interimOrders': interimOrders?.map((e) => e.toJson()).toList(),
      'finalOrders': finalOrders?.map((e) => e.toJson()).toList(),
      'transfers': transfers?.map((e) => e.toJson()).toList(),
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

class HearingRecord {
  final String judge;
  final String businessOnDate;
  final String hearingDate;
  final String purpose;

  HearingRecord({
    required this.judge,
    required this.businessOnDate,
    required this.hearingDate,
    required this.purpose,
  });

  factory HearingRecord.fromJson(Map<String, dynamic> json) => HearingRecord(
        judge: json['judge'],
        businessOnDate: json['businessOnDate'],
        hearingDate: json['hearingDate'],
        purpose: json['purpose'],
      );

  Map<String, dynamic> toJson() => {
        'judge': judge,
        'businessOnDate': businessOnDate,
        'hearingDate': hearingDate,
        'purpose': purpose,
      };
}

class OrderRecord {
  final String orderNumber;
  final String orderDate;
  final String orderDetails;
  final String? pdfUrl;

  OrderRecord({
    required this.orderNumber,
    required this.orderDate,
    required this.orderDetails,
    this.pdfUrl,
  });

  factory OrderRecord.fromJson(Map<String, dynamic> json) => OrderRecord(
        orderNumber: json['orderNumber'],
        orderDate: json['orderDate'],
        orderDetails: json['orderDetails'],
        pdfUrl: json['pdfUrl'],
      );

  Map<String, dynamic> toJson() => {
        'orderNumber': orderNumber,
        'orderDate': orderDate,
        'orderDetails': orderDetails,
        'pdfUrl': pdfUrl,
      };
}

class TransferRecord {
  final String transferDate;
  final String fromCourt;
  final String toCourt;

  TransferRecord({
    required this.transferDate,
    required this.fromCourt,
    required this.toCourt,
  });

  factory TransferRecord.fromJson(Map<String, dynamic> json) => TransferRecord(
        transferDate: json['transferDate'],
        fromCourt: json['fromCourt'],
        toCourt: json['toCourt'],
      );

  Map<String, dynamic> toJson() => {
        'transferDate': transferDate,
        'fromCourt': fromCourt,
        'toCourt': toCourt,
      };
}
