import 'package:json_annotation/json_annotation.dart';
import 'article_model.dart';

part 'top_headlines_response.g.dart';

@JsonSerializable(explicitToJson: true)
class TopHeadlinesResponse {
  final String? status;
  final int? totalResults;
  final List<ArticleModel> articles;

  const TopHeadlinesResponse({
    this.status,
    this.totalResults,
    required this.articles,
  });

  factory TopHeadlinesResponse.fromJson(Map<String, dynamic> json) =>
      _$TopHeadlinesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TopHeadlinesResponseToJson(this);
}