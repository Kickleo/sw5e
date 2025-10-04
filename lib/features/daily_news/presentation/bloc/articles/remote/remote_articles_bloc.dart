import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_event.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_state.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent, RemoteArticleState> {

  RemoteArticlesBloc() : super(const RemoteArticlesLoading());

  void onGetArticle(GetArticles event, Emitter<RemoteArticleState> emit) {
    
  }
}