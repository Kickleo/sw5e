import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sw5e_manager/app/di/injection_container.dart' show initializeDependencies;
import 'package:sw5e_manager/features/daily_news/presentation/pages/articles_page.dart';

final sl = GetIt.instance;

void main() {
  setUpAll(() async {
    // Either register the full graph:
    await initializeDependencies();

    // Or register just a stub bloc factory if you prefer:
    // sl.registerFactory<RemoteArticlesBloc>(() => FakeRemoteArticlesBloc());
  });

  tearDownAll(() async {
    await sl.reset();
  });

  testWidgets('ArticlesPage renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ArticlesPage()));
    await tester.pump(); // allow initial frame
    expect(find.byType(Scaffold), findsOneWidget);
  });
}