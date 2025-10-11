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
  // Garantit que l'environnement Flutter est bien initialisé avant toute
  // interaction avec les plugins natifs ou les Singletons.
  WidgetsFlutterBinding.ensureInitialized();

  // Construit la configuration applicative puis déclenche un chargement
  // asynchrone des paramètres (lecture d'assets, variables d'environnement, etc.).
  final AppConfig config = AppConfig();
  await config.load();

  // Prépare l'injecteur de dépendances global avec la configuration et un logger
  // console ; ce registre sera réutilisé dans toute l'application.
  ServiceLocator.configure(
    config: config,
    logger: ConsoleAppLogger(),
  );

  // Ajoute au conteneur IoC toutes les dépendances nécessaires à la création
  // de personnage ; cela enrichit la configuration réalisée juste avant.
  registerCharacterCreationModule();

  // Lance l'application en enveloppant l'arbre de widgets d'un ProviderScope
  // Riverpod afin de rendre les providers accessibles partout.
  runApp(const ProviderScope(child: Sw5eApp()));
}
