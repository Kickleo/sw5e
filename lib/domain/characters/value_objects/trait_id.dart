/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/trait_id.dart
/// Rôle : Valider un identifiant de trait.
/// Dépendances : `equatable` uniquement.
/// Exemple d'usage :
///   final id = TraitId('shrewd');
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';

/// TraitId = Value Object pour un identifiant de trait.
///
/// * Pré-condition : slug ASCII 3..60.
/// * Post-condition : normalisation en minuscules.
/// * Erreurs : `ArgumentError` si vide ou invalide.
class TraitId extends Equatable {
  final String value;

  const TraitId._(this.value);

  factory TraitId(String input) {
    final raw = input.trim();
    if (raw.isEmpty) {
      throw ArgumentError('TraitId.nullOrEmpty');
    }
    final normalized = raw.toLowerCase();
    if (!_slug.hasMatch(normalized)) {
      throw ArgumentError('TraitId.invalidFormat (attendu slug a-z0-9- entre 3 et 60 chars)');
    }
    return TraitId._(normalized);
  }

  static final RegExp _slug = RegExp(r'^[a-z0-9-]{3,60}$');

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
