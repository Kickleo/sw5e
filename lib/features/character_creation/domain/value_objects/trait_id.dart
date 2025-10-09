// lib/features/character_creation/domain/value_objects/trait_id.dart
import 'package:equatable/equatable.dart';

/// Identifiant de trait (slug), ex: "shrewd", "nimble-escape".
/// On ne traite ICI que l'identité; le contenu/effets viendront via le catalogue.
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
