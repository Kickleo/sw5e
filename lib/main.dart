import 'package:flutter/material.dart';
import 'package:sw5e_manager/app/home_nav.dart';
import 'package:sw5e_manager/di/character_creation_module.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await registerCharacterCreationModule(); // DI : catalogue + repo + use case
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SW5e Manager',
      theme: ThemeData(useMaterial3: true),
      home: const HomeNav(),
    );
  }
}

class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Bootstrap OK')),
    );
  }
}
