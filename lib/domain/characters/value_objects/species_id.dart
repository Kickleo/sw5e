/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/species_id.dart
/// Rôle : Valider l'identifiant d'espèce.
/// Dépendances : `equatable` uniquement.
/// Exemple d'usage :
///   final id = SpeciesId('bothan');
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';

/// SpeciesId = Value Object contrôlant l'identifiant d'espèce.
///
/// * Pré-condition : slug ASCII 3..40.
/// * Post-condition : normalisation en minuscules.
/// * Erreurs : `ArgumentError` si vide ou invalide.
class SpeciesId extends Equatable {
  final String value;

  const SpeciesId._(this.value);

  factory SpeciesId(String input) {
    final raw = input.trim();
    if (raw.isEmpty) {
      throw ArgumentError('SpeciesId.nullOrEmpty');
    }
    final normalized = raw.toLowerCase();
    if (!_slug.hasMatch(normalized)) {
      throw ArgumentError('SpeciesId.invalidFormat');
    }
    return SpeciesId._(normalized);
  }

  static final RegExp _slug = RegExp(r'^[a-z0-9-]{3,40}$');

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
