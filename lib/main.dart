import 'package:flutter/material.dart';
import 'package:sw5e_manager/app/app.dart';
import 'package:sw5e_manager/app/di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const AppRoot());
}
