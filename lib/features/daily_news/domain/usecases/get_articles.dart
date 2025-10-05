import 'package:sw5e_manager/core/resources/data_state.dart';
import 'package:sw5e_manager/core/usecases/usecase.dart';
import 'package:sw5e_manager/features/daily_news/domain/entities/article_entity.dart';
import 'package:sw5e_manager/features/daily_news/domain/repository/article_repository.dart';

class GetArticlesParams {
  final String? country;
  final String? category;
  const GetArticlesParams({this.country, this.category});
}

class GetArticles extends Usecase<DataState<List<ArticleEntity>>, GetArticlesParams> {
  final ArticleRepository _repo;
  GetArticles(this._repo);

  @override
  Future<DataState<List<ArticleEntity>>> call({required GetArticlesParams params}) {
    return _repo.getTopHeadlines(
      country: params.country,
      category: params.category,
    );
  }
}