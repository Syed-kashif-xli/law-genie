class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String source;
  final String publishedAt;
  final String? imageUrl;
  final String? content;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    required this.publishedAt,
    this.imageUrl,
    this.content,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      url: json['url'] ?? '',
      source: json['source']?['name'] ?? 'Unknown Source',
      publishedAt: json['publishedAt'] ?? '',
      imageUrl: json['urlToImage'],
      content: json['content'],
    );
  }
}
