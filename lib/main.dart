import 'package:flutter/material.dart';
import 'package:sw5e_manager/config/theme/app_themes.dart';
import 'package:sw5e_manager/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:sw5e_manager/injection_container.dart';

Future<void> main() async {
  await initializeDependecies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme(),
      home: const DailyNews(),
    );
  }
}