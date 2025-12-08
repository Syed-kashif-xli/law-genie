class BareAct {
  final String id;
  final String title;
  final String category;
  final String pdfUrl;
  final String year;

  BareAct({
    required this.id,
    required this.title,
    required this.category,
    required this.pdfUrl,
    required this.year,
  });

  factory BareAct.fromMap(Map<String, dynamic> map, String documentId) {
    return BareAct(
      id: documentId,
      title: map['title'] ?? '',
      category: map['category'] ?? 'Uncategorized',
      pdfUrl: map['pdfUrl'] ?? '',
      year: map['year'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'pdfUrl': pdfUrl,
      'year': year,
    };
  }
}
