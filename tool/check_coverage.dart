// -----------------------------------------------------------------------------
// Fichier : tool/check_coverage.dart
// Rôle : Vérifier que le rapport coverage/lcov.info atteint un seuil minimal.
// Dépendances : Nécessite l'exécution préalable de `flutter test --coverage`.
// Exemple d'usage : `dart run tool/check_coverage.dart --min 70` dans le pipeline CI.
// -----------------------------------------------------------------------------

import 'dart:convert';
import 'dart:io';

/// CoverageReport = structure représentant le calcul de couverture des lignes.
class CoverageReport {
  CoverageReport({required this.hitLines, required this.foundLines});

  /// Lignes exécutées au moins une fois.
  final int hitLines;

  /// Lignes découvertes dans le rapport.
  final int foundLines;

  /// Pourcentage calculé sur la base des lignes.
  double get linePercentage => foundLines == 0 ? 0 : (hitLines / foundLines) * 100;
}

/// CoverageParseException = erreur levée quand le rapport est illisible ou vide.
class CoverageParseException implements Exception {
  CoverageParseException(this.message);

  /// Message détaillant la cause de l'échec.
  final String message;

  @override
  String toString() => 'CoverageParseException: $message';
}

/// Lit le rapport LCOV et en extrait le total des lignes couvertes / découvertes.
CoverageReport parseLcov(String lcovContent) {
  var hit = 0;
  var found = 0;
  final lines = const LineSplitter().convert(lcovContent);
  if (lines.isEmpty) {
    throw CoverageParseException('Le fichier LCOV est vide.');
  }

  for (final line in lines) {
    if (line.startsWith('DA:')) {
      final data = line.substring(3).split(',');
      if (data.length != 2) {
        throw CoverageParseException('Ligne LCOV invalide : $line');
      }
      final executionCount = int.tryParse(data[1]);
      if (executionCount == null) {
        throw CoverageParseException('Compteur invalide sur : $line');
      }
      found += 1;
      if (executionCount > 0) {
        hit += 1;
      }
    }
  }

  return CoverageReport(hitLines: hit, foundLines: found);
}

/// Vérifie que le pourcentage de couverture est >= seuil et affiche le résultat.
Future<void> main(List<String> args) async {
  const defaultThreshold = 70.0;
  var threshold = defaultThreshold;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--min' && i + 1 < args.length) {
      threshold = double.tryParse(args[i + 1]) ?? defaultThreshold;
    }
  }

  final coverageFile = File('coverage/lcov.info');
  if (!coverageFile.existsSync()) {
    throw CoverageParseException(
      'Fichier coverage/lcov.info introuvable. Lance `flutter test --coverage` avant.',
    );
  }

  final report = parseLcov(await coverageFile.readAsString());
  final percentage = report.linePercentage;
  stdout.writeln('Couverture lignes : ${percentage.toStringAsFixed(2)}% (${report.hitLines}/${report.foundLines})');

  if (percentage < threshold) {
    stderr.writeln('Couverture insuffisante : ${percentage.toStringAsFixed(2)}% < $threshold%');
    exitCode = 1;
  }
}
