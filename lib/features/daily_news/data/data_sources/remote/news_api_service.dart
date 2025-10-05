import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:sw5e_manager/core/constants/constants.dart';
import '../../../data/models/top_headlines_response.dart';

part 'news_api_service.g.dart';

@RestApi(baseUrl: newsAPIBaseURL)
abstract class NewsApiService {
  factory NewsApiService(Dio dio, {String baseUrl}) = _NewsApiService;

  @GET('top-headlines')
  Future<HttpResponse<TopHeadlinesResponse>> getTopHeadlines({
    @Query('apiKey') required String apiKey,
    @Query('country') String? country,
    @Query('category') String? category,
  });
}