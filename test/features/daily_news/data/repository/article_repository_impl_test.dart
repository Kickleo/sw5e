import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/dio.dart';
import 'package:sw5e_manager/core/resources/data_state.dart';
import 'package:sw5e_manager/features/daily_news/data/data_sources/local/articles_local_data_source.dart';
import 'package:sw5e_manager/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:sw5e_manager/features/daily_news/data/models/article_model.dart';
import 'package:sw5e_manager/features/daily_news/data/models/top_headlines_response.dart';
import 'package:sw5e_manager/features/daily_news/data/repository/article_repository_impl.dart';

class MockNewsApiService extends Mock implements NewsApiService {}
class MockArticlesLocalDataSource extends Mock implements ArticlesLocalDataSource {}

void main() {
  late MockNewsApiService remote;
  late MockArticlesLocalDataSource local;
  late ArticleRepositoryImpl repo;

  setUp(() {
    remote = MockNewsApiService();
    local = MockArticlesLocalDataSource();
    repo = ArticleRepositoryImpl(remote, local);
  });

  group('ArticleRepositoryImpl', () {
    test('returns DataSuccess on 200 and writes cache', () async {
      // Arrange
      final models = [
        const ArticleModel(title: 'Hello', description: 'World'),
      ];
      final dto = TopHeadlinesResponse(status: 'ok', totalResults: 1, articles: models);

      final dioResponse = Response(
        requestOptions: RequestOptions(path: '/top-headlines'),
        statusCode: HttpStatus.ok,
        statusMessage: 'OK',
      );

      when(() => remote.getTopHeadlines(
            apiKey: any(named: 'apiKey'),
            country: any(named: 'country'),
            category: any(named: 'category'),
          )).thenAnswer((_) async => HttpResponse(dto, dioResponse));

      when(() => local.saveAll(any())).thenAnswer((_) async {});
      // Act
      final result = await repo.getTopHeadlines(country: 'us', category: 'tech');

      // Assert
      expect(result, isA<DataSuccess>());
      final success = result as DataSuccess;
      expect(success.data.length, 1);
      expect(success.data.first.title, 'Hello');
      verify(() => local.saveAll(models)).called(1);
      verifyNever(() => local.getAll());
    });

    test('on DioException, returns DataSuccess with cached data if available', () async {
      // Arrange
      when(() => remote.getTopHeadlines(
            apiKey: any(named: 'apiKey'),
            country: any(named: 'country'),
            category: any(named: 'category'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: '/top-headlines'),
            type: DioExceptionType.connectionError,
          ));

      final cached = [
        const ArticleModel(title: 'Cached', description: 'Item'),
      ];
      when(() => local.getAll()).thenAnswer((_) async => cached);

      // Act
      final result = await repo.getTopHeadlines();

      // Assert
      expect(result, isA<DataSuccess>());
      final success = result as DataSuccess;
      expect(success.data.first.title, 'Cached');
      verify(() => local.getAll()).called(1);
    });

    test('on DioException and empty cache, returns DataFailed', () async {
      when(() => remote.getTopHeadlines(
            apiKey: any(named: 'apiKey'),
            country: any(named: 'country'),
            category: any(named: 'category'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: '/top-headlines'),
            type: DioExceptionType.connectionError,
          ));

      when(() => local.getAll()).thenAnswer((_) async => <ArticleModel>[]);

      final result = await repo.getTopHeadlines();

      expect(result, isA<DataFailed>());
    });
  });
}