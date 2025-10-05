import 'package:flutter/material.dart';
import 'package:sw5e_manager/features/daily_news/presentation/pages/articles_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News',
      theme: ThemeData(useMaterial3: true),
      home: const ArticlesPage(),
    );
  }
}