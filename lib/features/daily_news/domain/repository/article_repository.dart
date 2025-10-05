import 'package:sw5e_manager/core/resources/data_state.dart';
import '../entities/article_entity.dart';

abstract class ArticleRepository {
  Future<DataState<List<ArticleEntity>>> getTopHeadlines({
    String? country,
    String? category,
  });
}