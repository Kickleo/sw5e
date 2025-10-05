import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
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

  // Repository
  sl.registerLazySingleton<ArticleRepository>(() => ArticleRepositoryImpl(sl()));

  // Usecase
  sl.registerLazySingleton<GetArticles>(() => GetArticles(sl()));

  // BLoC
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));
}