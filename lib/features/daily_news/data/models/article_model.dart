import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/article_entity.dart';

part 'article_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ArticleModel {
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  const ArticleModel({
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleModelFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleModelToJson(this);

  ArticleEntity toEntity() => ArticleEntity(
        author: author,
        title: title,
        description: description,
        url: url,
        urlToImage: urlToImage,
        publishedAt: publishedAt,
        content: content,
      );

  static List<ArticleEntity> toEntities(List<ArticleModel> list) =>
      list.map((m) => m.toEntity()).toList();
}