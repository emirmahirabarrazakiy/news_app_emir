class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String sourceName;
  final String publishedAt;
  final String url;

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'urlToImage': imageUrl,
      'source': {'name': sourceName},
      'publishedAt': publishedAt,
      'url': url,
    };
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    final source = json['source'];
    final sourceName = source is Map ? source['name'] : null;

    return Article(
      title: _stringOrDefault(json['title'], 'Judul tidak tersedia'),
      description: _stringOrDefault(json['description'], ''),
      imageUrl: _stringOrDefault(json['urlToImage'], ''),
      sourceName: _stringOrDefault(sourceName, 'Sumber tidak diketahui'),
      publishedAt: _stringOrDefault(json['publishedAt'], ''),
      url: _stringOrDefault(json['url'], ''),
    );
  }
}

String _stringOrDefault(Object? value, String fallback) {
  return value is String ? value : fallback;
}
