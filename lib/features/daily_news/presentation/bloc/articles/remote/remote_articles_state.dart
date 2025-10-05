import 'package:equatable/equatable.dart';
import 'package:sw5e_manager/features/daily_news/domain/entities/article_entity.dart';

sealed class RemoteArticlesState extends Equatable {
  const RemoteArticlesState();
  @override
  List<Object?> get props => [];
}

class RemoteArticlesInitial extends RemoteArticlesState {
  const RemoteArticlesInitial();
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

class RemoteArticlesSuccess extends RemoteArticlesState {
  final List<ArticleEntity> articles;
  const RemoteArticlesSuccess(this.articles);

  @override
  List<Object?> get props => [articles];
}

class RemoteArticlesFailure extends RemoteArticlesState {
  final String message;
  const RemoteArticlesFailure(this.message);

  @override
  List<Object?> get props => [message];
}