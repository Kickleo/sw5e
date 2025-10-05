import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sw5e_manager/core/constants/constants.dart';
import 'package:sw5e_manager/core/resources/data_state.dart';
import 'package:sw5e_manager/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:sw5e_manager/features/daily_news/data/models/article_model.dart';
import 'package:sw5e_manager/features/daily_news/domain/entities/article_entity.dart';
import 'package:sw5e_manager/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _api;
  ArticleRepositoryImpl(this._api);

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
        final models = http.data.articles; // List<ArticleModel>
        final entities = ArticleModel.toEntities(models);
        return DataSuccess(entities);
      }

      return DataFailed(
        DioException(
          requestOptions: http.response.requestOptions,
          response: http.response,
          type: DioExceptionType.badResponse,
          error: http.response.statusMessage,
        ),
      );
    } on DioException catch (e, st) {
      return DataFailed(e, st);
    } catch (e, st) {
      return DataFailed(e, st);
    }
  }
}