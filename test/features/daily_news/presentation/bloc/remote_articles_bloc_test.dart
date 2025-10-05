import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/core/resources/data_state.dart';
import 'package:sw5e_manager/features/daily_news/domain/entities/article_entity.dart';
import 'package:sw5e_manager/features/daily_news/domain/usecases/get_articles.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_bloc.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_event.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_state.dart';

class MockGetArticles extends Mock implements GetArticles {}

class FakeGetArticlesParams extends Fake implements GetArticlesParams {}

void main() {
  late MockGetArticles usecase;

  setUpAll(() {
    registerFallbackValue(FakeGetArticlesParams());
  });

  setUp(() {
    usecase = MockGetArticles();
  });

  blocTest<RemoteArticlesBloc, RemoteArticlesState>(
    'emits [Loading, Success] when usecase returns DataSuccess',
    build: () {
      when(() => usecase(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess<List<ArticleEntity>>([
                ArticleEntity(title: 'A'),
              ]));
      return RemoteArticlesBloc(usecase);
    },
    act: (bloc) => bloc.add(const RemoteArticlesRequested(country: 'us')),
    expect: () => [
      const RemoteArticlesLoading(),
      isA<RemoteArticlesSuccess>().having((s) => s.articles.first.title, 'first.title', 'A'),
    ],
    verify: (_) => verify(() => usecase(params: any(named: 'params'))).called(1),
  );

  blocTest<RemoteArticlesBloc, RemoteArticlesState>(
    'emits [Loading, Failure] when usecase returns DataFailed',
    build: () {
      when(() => usecase(params: any(named: 'params')))
          .thenAnswer((_) async => DataFailed(Exception('boom')));
      return RemoteArticlesBloc(usecase);
    },
    act: (bloc) => bloc.add(const RemoteArticlesRequested()),
    expect: () => [
      const RemoteArticlesLoading(),
      isA<RemoteArticlesFailure>(),
    ],
  );
}
