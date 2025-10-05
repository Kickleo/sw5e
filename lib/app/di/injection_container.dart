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

Future<void> initializeDependencies() async {
  // HTTP
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ));
    return dio;
  });

  // API service
  sl.registerLazySingleton<NewsApiService>(() => NewsApiService(sl<Dio>()));

  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Repository
  sl.registerLazySingleton<ArticleRepository>(() => ArticleRepositoryImpl(sl()));

  // Usecase
  sl.registerLazySingleton<GetArticles>(() => GetArticles(sl()));

  // BLoC
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));

  sl.registerLazySingleton<ArticlesLocalDataSource>(
    () => ArticlesLocalDataSourceImpl(sl<AppDatabase>()),
  );

  // Re-register the repo so it gets both remote + local DS
  sl.unregister<ArticleRepository>();
  sl.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(sl(), sl()), // (remote, local)
  );

}