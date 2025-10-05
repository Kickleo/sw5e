import 'package:drift/drift.dart';
import 'package:sw5e_manager/features/daily_news/data/data_sources/local/db/app_database.dart';
import 'package:sw5e_manager/features/daily_news/data/models/article_model.dart';

abstract class ArticlesLocalDataSource {
  Future<void> saveAll(List<ArticleModel> items);
  Future<List<ArticleModel>> getAll();
  Future<void> clear();
}

class ArticlesLocalDataSourceImpl implements ArticlesLocalDataSource {
  final AppDatabase db;
  ArticlesLocalDataSourceImpl(this.db);

  @override
  Future<void> saveAll(List<ArticleModel> items) async {
    final rows = items.map((m) => ArticlesCompanion.insert(
      author: Value(m.author),
      title: Value(m.title),
      description: Value(m.description),
      url: Value(m.url),
      urlToImage: Value(m.urlToImage),
      publishedAt: Value(m.publishedAt),
      content: Value(m.content),
    )).toList();

    await db.replaceAllArticles(rows);
  }

  @override
  Future<List<ArticleModel>> getAll() async {
    final list = await db.getAllArticles();
    return list.map((r) => ArticleModel(
      author: r.author,
      title: r.title,
      description: r.description,
      url: r.url,
      urlToImage: r.urlToImage,
      publishedAt: r.publishedAt,
      content: r.content,
    )).toList();
  }

  @override
  Future<void> clear() => db.delete(db.articles).go();
}
