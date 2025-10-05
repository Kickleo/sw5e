import 'package:sw5e_manager/features/daily_news/data/models/article.dart';

class NewsResponse {
  final String? status;
  final int? totalResults;
  final List<ArticleModel> articles;

  const NewsResponse({
    this.status,
    this.totalResults,
    required this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['articles'] as List<dynamic>? ?? []);
    return NewsResponse(
      status: json['status'] as String?,
      totalResults: json['totalResults'] as int?,
      articles: list
          .whereType<Map<String, dynamic>>()
          .map(ArticleModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'totalResults': totalResults,
    'articles': articles.map((e) => e.toJson()).toList(),
  };
}
