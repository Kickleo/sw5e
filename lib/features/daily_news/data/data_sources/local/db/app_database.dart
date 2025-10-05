import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Table that stores the articles we fetch from the API.
/// You can add indexes/constraints later (e.g., unique on `url`) if you want.
class Articles extends Table {
  IntColumn get id => integer().autoIncrement()(); // local PK
  TextColumn get author => text().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get urlToImage => text().nullable()();
  TextColumn get publishedAt => text().nullable()();
  TextColumn get content => text().nullable()();
}

@DriftDatabase(tables: [Articles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ---- Simple DAO-like helpers ----

  Future<void> replaceAllArticles(List<ArticlesCompanion> rows) async {
    await transaction(() async {
      await delete(articles).go(); // clear table
      await batch((b) {
        b.insertAll(articles, rows, mode: InsertMode.insertOrReplace);
      });
    });
  }

  Future<List<Article>> getAllArticles() => select(articles).get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app.db'));
    // createInBackground keeps the UI responsive on first open
    return NativeDatabase.createInBackground(file);
  });
}