class NewsArticle {
  final String? author;
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;
  final String? source;

  NewsArticle({
    this.author,
    required this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      author: json['author'] as String?,
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String?,
      url: json['url'] as String?,
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      content: json['content'] as String?,
      source: json['source'] != null
          ? (json['source'] is Map
                ? (json['source'] as Map<String, dynamic>)['name'] as String?
                : json['source'] as String?)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
      'source': source,
    };
  }
}

class NewsResponse {
  final String status;
  final int totalResults;
  final List<NewsArticle> articles;

  NewsResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] as String? ?? 'error',
      totalResults: json['totalResults'] as int? ?? 0,
      articles:
          (json['articles'] as List<dynamic>?)
              ?.map(
                (article) =>
                    NewsArticle.fromJson(article as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
