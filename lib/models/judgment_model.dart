class Judgment {
  final String id;
  final String title;
  final String? date;
  final String? snippet;
  final String? author;
  final String? bench;
  final String? content;
  final String? url;

  Judgment({
    required this.id,
    required this.title,
    this.date,
    this.snippet,
    this.author,
    this.bench,
    this.content,
    this.url,
  });

  factory Judgment.fromMap(Map<String, dynamic> map) {
    return Judgment(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      date: map['date'],
      snippet: map['snippet'],
      author: map['author'],
      bench: map['bench'],
      content: map['content'],
      url: map['url'],
    );
  }
}

class JudgmentCategory {
  final String name;
  final String path;
  final String? description;

  JudgmentCategory({
    required this.name,
    required this.path,
    this.description,
  });
}
