import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sw5e_manager/core/resources/data_state.dart';
import 'package:sw5e_manager/features/daily_news/domain/usecases/get_articles.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_event.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_state.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticles _getArticles;

  RemoteArticlesBloc(this._getArticles) : super(const RemoteArticlesInitial()) {
    on<RemoteArticlesRequested>(_onRequested);
  }

  Future<void> _onRequested(
    RemoteArticlesRequested event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    emit(const RemoteArticlesLoading());

    final res = await _getArticles(
      params: GetArticlesParams(
        country: event.country,
        category: event.category,
      ),
    );

    switch (res) {
      case DataSuccess(:final data):
        emit(RemoteArticlesSuccess(data));
      case DataFailed(:final error):
        emit(RemoteArticlesFailure(error.toString()));
    }
  }
}