import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sw5e_manager/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:sw5e_manager/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:sw5e_manager/features/daily_news/domain/repository/article_repository.dart';
import 'package:sw5e_manager/features/daily_news/domain/usecases/get_article.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependecies() async {

  sl.registerSingleton<Dio>(Dio());

  sl.registerSingleton<NewsApiService>(NewsApiService(sl<Dio>()));

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl<NewsApiService>())
  );

  sl.registerSingleton<GetArticleUseCase>(
    GetArticleUseCase(sl<ArticleRepository>())
  );

  sl.registerFactory<RemoteArticlesBloc>(
    () => RemoteArticlesBloc(sl<GetArticleUseCase>())
  );
}