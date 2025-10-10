/// ---------------------------------------------------------------------------
/// Fichier : lib/common/di/service_locator.dart
/// Rôle : Fournir un point centralisé d'injection de dépendances basé sur
///        `get_it` afin de séparer l'enregistrement des dépendances de leur
///        consommation.
/// Dépendances : package `get_it`, configuration [AppConfig], logger [AppLogger].
/// Exemple d'usage :
///   ServiceLocator.configure(config: config, logger: logger);
///   final AppLogger log = ServiceLocator.resolve<AppLogger>();
/// ---------------------------------------------------------------------------
import 'package:get_it/get_it.dart';

import '../config/app_config.dart';
import '../logging/app_logger.dart';

/// ServiceLocator = façade statique autour de l'instance `GetIt` partagée.
class ServiceLocator {
  ServiceLocator._();

  static final GetIt _instance = GetIt.instance;

  /// Configure les dépendances globales de l'application.
  ///
  /// Préconditions : doit être appelée une fois au démarrage (ex. `main`).
  /// Postconditions : [AppConfig] et [AppLogger] sont enregistrés.
  static void configure({required AppConfig config, required AppLogger logger}) {
    if (!_instance.isRegistered<AppConfig>()) {
      _instance.registerSingleton<AppConfig>(config);
    }
    if (!_instance.isRegistered<AppLogger>()) {
      _instance.registerSingleton<AppLogger>(logger);
    }
  }

  /// Récupère une dépendance enregistrée.
  static T resolve<T extends Object>() => _instance<T>();

  /// Vérifie si un type est déjà enregistré dans le conteneur.
  static bool isRegistered<T extends Object>({String? instanceName}) =>
      _instance.isRegistered<T>(instanceName: instanceName);

  /// Enregistre un singleton paresseux (LazySingleton = instance unique créée à
  /// la première résolution).
  static void registerLazySingleton<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    if (_instance.isRegistered<T>(instanceName: instanceName)) {
      return;
    }
    _instance.registerLazySingleton<T>(factoryFunc, instanceName: instanceName);
  }

  /// Enregistre une fabrique (Factory = nouvelle instance à chaque résolution).
  static void registerFactory<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    _instance.registerFactory<T>(factoryFunc, instanceName: instanceName);
  }
}
