import 'package:flutter/material.dart';
import 'package:sw5e_manager/app/di/injection_container.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const MyApp());
}