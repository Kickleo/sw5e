import 'package:dio/dio.dart';
import 'package:sw5e_manager/core/constants/constants.dart';
import 'package:retrofit/retrofit.dart';
import 'package:sw5e_manager/features/daily_news/data/models/article.dart';


part 'news_api_service.g.dart';

@RestApi(baseUrl: newsAPIBaseURL)
abstract class NewsApiService{
  factory NewsApiService(Dio dio) = _NewsApiService;

  @GET('top-headlines')
  Future<HttpResponse<List<ArticleModel>>> getNewsArticles({
    @Query('apiKey') String ? apikey,
    @Query('country') String ? country,
    @Query('category') String ? category,
  });
}