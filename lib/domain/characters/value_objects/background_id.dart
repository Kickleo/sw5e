/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/background_id.dart
/// Rôle : Normaliser et valider l'identifiant de background (slug ASCII)
///        utilisé dans le catalogue hors-ligne.
/// Dépendances : `equatable` pour simplifier les comparaisons d'instances.
/// Exemple d'usage :
///   final id = BackgroundId(' Outlaw '); // => "outlaw"
/// ---------------------------------------------------------------------------
library;
import 'package:equatable/equatable.dart';

/// BackgroundId = Value Object pour un identifiant de background valide.
///
/// * Pré-condition : la valeur fournie doit respecter le format slug.
/// * Post-condition : l'identifiant est stocké en minuscules sans espaces.
/// * Erreurs : `ArgumentError` si vide ou format invalide.
class BackgroundId extends Equatable {
  /// Valeur normalisée (slug).
  final String value;

  const BackgroundId._(this.value);

  /// Fabrique validant et normalisant la chaîne reçue.
  factory BackgroundId(String input) {
    final String raw = input.trim();
    if (raw.isEmpty) {
      throw ArgumentError('BackgroundId.nullOrEmpty');
    }
    final String normalized = raw.toLowerCase();
    if (!_slug.hasMatch(normalized)) {
      throw ArgumentError('BackgroundId.invalidFormat');
    }
    return BackgroundId._(normalized);
  }

  /// Pattern slug autorisant lettres, chiffres et tirets (3..50 caractères).
  static final RegExp _slug = RegExp(r'^[a-z0-9-]{3,50}$');

  @override
  List<Object?> get props => <Object?>[value];

  @override
  String toString() => value;
}
