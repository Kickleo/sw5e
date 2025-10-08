// lib/features/character_creation/domain/value_objects/species_id.dart
import 'package:equatable/equatable.dart';

/// Value Object : SpeciesId (slug ASCII, ex: "human")
/// - Normalise en minuscules + trim
/// - Valide le format slug: ^[a-z0-9-]{3,40}$
/// - ⚠️ L'existence dans le catalogue est vérifiée ailleurs (use case/service).
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
