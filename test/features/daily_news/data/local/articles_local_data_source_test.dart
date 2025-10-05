import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/features/daily_news/data/data_sources/local/articles_local_data_source.dart';
import 'package:sw5e_manager/features/daily_news/data/data_sources/local/db/app_database.dart';
import 'package:sw5e_manager/features/daily_news/data/models/article_model.dart';

void main() {
  late AppDatabase db;
  late ArticlesLocalDataSource ds;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    ds = ArticlesLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('saveAll then getAll returns inserted items', () async {
    final items = [
      const ArticleModel(title: 'One'),
      const ArticleModel(title: 'Two'),
    ];

    await ds.saveAll(items);
    final out = await ds.getAll();

    expect(out.length, 2);
    expect(out.first.title, 'One');
  });

  test('clear removes all', () async {
    await ds.saveAll([const ArticleModel(title: 'Keep?')]);
    await ds.clear();
    final out = await ds.getAll();
    expect(out, isEmpty);
  });
}
