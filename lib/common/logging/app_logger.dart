/// ---------------------------------------------------------------------------
/// Fichier : lib/common/logging/app_logger.dart
/// Rôle : Définir l'interface de journalisation utilisée dans l'application pour
///        standardiser les niveaux et formats de logs.
/// Dépendances : Aucune (interface pure, implémentations ailleurs).
/// Exemple d'usage :
///   final logger = ServiceLocator.resolve<AppLogger>();
///   logger.info('Character created');
/// ---------------------------------------------------------------------------
library;

/// AppLogger = contrat de journalisation uniforme (info/warn/error).
abstract class AppLogger {
  /// Journalise une information fonctionnelle.
  void info(String message, {Object? payload});

  /// Journalise un avertissement récupérable.
  void warn(String message, {Object? payload, Object? error, StackTrace? stackTrace});

  /// Journalise une erreur bloquante nécessitant attention.
  void error(String message, {Object? payload, Object? error, StackTrace? stackTrace});
}
