import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sw5e_manager/core/constants/constants.dart';
import 'package:sw5e_manager/core/resources/data_state.dart';
import 'package:sw5e_manager/features/daily_news/data/data_sources/local/articles_local_data_source.dart';
import 'package:sw5e_manager/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:sw5e_manager/features/daily_news/data/models/article_model.dart';
import 'package:sw5e_manager/features/daily_news/domain/entities/article_entity.dart';
import 'package:sw5e_manager/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _api;
  final ArticlesLocalDataSource _local;

  ArticleRepositoryImpl(this._api, this._local);

  @override
  Future<DataState<List<ArticleEntity>>> getTopHeadlines({
    String? country,
    String? category,
  }) async {
    try {
      final http = await _api.getTopHeadlines(
        apiKey: newsApiKey,
        country: country ?? defaultCountry,
        category: category ?? defaultCategory,
      );

      if (http.response.statusCode == HttpStatus.ok) {
        final models = http.data.articles;                // List<ArticleModel>
        await _local.saveAll(models);                     // write-through cache
        final entities = ArticleModel.toEntities(models); // map → domain
        return DataSuccess(entities);
      }

      return DataFailed(
        HttpException(
          'HTTP ${http.response.statusCode}: ${http.response.statusMessage}',
          uri: http.response.requestOptions.uri,
        ),
      );
    } on DioException catch (e, st) {
      final cached = await _local.getAll();
      if (cached.isNotEmpty) {
        return DataSuccess(ArticleModel.toEntities(cached));
      }
      return DataFailed(e, st); // ✅ convert to failure when no cache
    } catch (e, st) {
      return DataFailed(e, st);
    }
  }
}