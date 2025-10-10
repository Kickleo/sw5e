/// ---------------------------------------------------------------------------
/// Fichier : lib/main.dart
/// Rôle : Point d'entrée Flutter initialisant la configuration, la journalisation
///        et lançant l'application avec Riverpod.
/// Dépendances : Flutter, flutter_riverpod, AppConfig, ServiceLocator, AppLogger.
/// Exemple d'usage : Exécuté automatiquement par `flutter run`.
/// ---------------------------------------------------------------------------
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw5e_manager/app/app.dart';
import 'package:sw5e_manager/common/config/app_config.dart';
import 'package:sw5e_manager/common/di/service_locator.dart';
import 'package:sw5e_manager/common/logging/console_app_logger.dart';
import 'package:sw5e_manager/di/character_creation_module.dart';

/// main = fonction d'initialisation de l'application Flutter.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppConfig config = AppConfig();
  await config.load();

  ServiceLocator.configure(
    config: config,
    logger: ConsoleAppLogger(),
  );

  registerCharacterCreationModule();

  runApp(const ProviderScope(child: Sw5eApp()));
}
