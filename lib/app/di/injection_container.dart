import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sw5e_manager/features/daily_news/data/data_sources/local/articles_local_data_source.dart';
import 'package:sw5e_manager/features/daily_news/data/data_sources/local/db/app_database.dart';
import 'package:sw5e_manager/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:sw5e_manager/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:sw5e_manager/features/daily_news/domain/repository/article_repository.dart';
import 'package:sw5e_manager/features/daily_news/domain/usecases/get_articles.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // HTTP
  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
      )));

  // API service (remote)
  sl.registerLazySingleton<NewsApiService>(() => NewsApiService(sl<Dio>()));

  // Drift DB
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Local data source (cache)
  sl.registerLazySingleton<ArticlesLocalDataSource>(
    () => ArticlesLocalDataSourceImpl(sl<AppDatabase>()),
  );

  // Repository (needs BOTH: remote + local)  ✅ only register once
  sl.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(
      sl<NewsApiService>(),
      sl<ArticlesLocalDataSource>(),
    ),
  );

  // Use case
  sl.registerLazySingleton<GetArticles>(() => GetArticles(sl<ArticleRepository>()));

  // BLoC
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl<GetArticles>()));
}