/// ---------------------------------------------------------------------------
/// Fichier : lib/common/logging/console_app_logger.dart
/// Rôle : Implémenter [AppLogger] en s'appuyant sur le package `logger` pour
///        fournir une sortie console structurée.
/// Dépendances : package `logger`.
/// Exemple d'usage :
///   final logger = ConsoleAppLogger();
///   logger.warn('Offline mode enabled', payload: {'source': 'asset'});
/// ---------------------------------------------------------------------------
library;
import 'package:logger/logger.dart' as logger_package;

import 'package:sw5e_manager/common/logging/app_logger.dart';

/// ConsoleAppLogger = implémentation console simple basée sur `logger`.
class ConsoleAppLogger implements AppLogger {
  /// Construit le logger avec un formateur concis par défaut.
  ConsoleAppLogger()
      : _logger = logger_package.Logger(
          printer: logger_package.PrettyPrinter(methodCount: 0),
        );

  final logger_package.Logger _logger;

  @override
  void info(String message, {Object? payload}) {
    _logger.i(_compose(message, payload: payload));
  }

  @override
  void warn(String message,
      {Object? payload, Object? error, StackTrace? stackTrace}) {
    _logger.w(
      _compose(message, payload: payload),
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void error(String message,
      {Object? payload, Object? error, StackTrace? stackTrace}) {
    _logger.e(
      _compose(message, payload: payload),
      error: error,
      stackTrace: stackTrace,
    );
  }

  String _compose(String message, {Object? payload}) {
    if (payload == null) {
      return message;
    }
    return '$message | payload=$payload';
  }
}
