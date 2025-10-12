/// Point d'entrée de l'application.
///
/// Les étapes exécutées ici se concentrent sur la préparation des dépendances
/// partagées avant de lancer l'interface utilisateur Flutter. Chaque
/// instruction du `main` répond à une responsabilité précise :
///
/// - initialiser les bindings Flutter afin de pouvoir utiliser les services de
///   plateforme (lecteur d'assets, préférences, etc.) ;
/// - charger le fichier `.env` qui pilote les clés API et options d'exécution ;
/// - enregistrer ces objets de configuration ainsi qu'un logger dans l'outil
///   d'injection `GetIt` partagé par toutes les couches ;
/// - installer les dépendances spécifiques au module « création de personnage »
///   (use cases, repositories) pour que les widgets puissent les résoudre ;
/// - lancer l'interface via un [ProviderScope] Riverpod qui expose les
///   providers globaux à l'ensemble de l'arbre de widgets.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw5e_manager/app/app.dart';
import 'package:sw5e_manager/common/config/app_config.dart';
import 'package:sw5e_manager/common/di/service_locator.dart';
import 'package:sw5e_manager/common/logging/console_app_logger.dart';
import 'package:sw5e_manager/di/character_creation_module.dart';

/// Prépare l'infrastructure applicative puis démarre l'UI.
///
/// 1. Initialise Flutter pour pouvoir utiliser les APIs de plateforme.
/// 2. Charge la configuration applicative depuis les assets.
/// 3. Configure l'injecteur de dépendances partagé avec un logger console.
/// 4. Enregistre le module de création de personnage dans l'injecteur.
/// 5. Lance l'application sous un [ProviderScope] Riverpod.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppConfig config = AppConfig();
  // Charge les variables d'environnement (.env) : elles définissent par
  // exemple les URLs d'API ou flags d'activation de fonctionnalités.
  await config.load();

  ServiceLocator.configure(
    config: config,
    // Le logger console sert de point d'entrée unique pour suivre la vie du
    // wizard en environnement de développement.
    logger: ConsoleAppLogger(),
  );

  // Injection des cas d'usage et repositories nécessaires à l'assistant de
  // création de personnage. Sans cet appel, le router et les BLoC ne
  // trouveraient pas leurs dépendances lors de la résolution `GetIt`.
  registerCharacterCreationModule();

  runApp(const ProviderScope(child: Sw5eApp()));
}
