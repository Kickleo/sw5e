// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_headlines_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopHeadlinesResponse _$TopHeadlinesResponseFromJson(
  Map<String, dynamic> json,
) => TopHeadlinesResponse(
  status: json['status'] as String?,
  totalResults: (json['totalResults'] as num?)?.toInt(),
  articles: (json['articles'] as List<dynamic>)
      .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TopHeadlinesResponseToJson(
  TopHeadlinesResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'totalResults': instance.totalResults,
  'articles': instance.articles.map((e) => e.toJson()).toList(),
};
