/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/entities/character_draft.dart
/// Rôle : Représenter l'état incomplet d'un personnage en cours de création.
///        Permet de persister la progression (espèce, effets, etc.).
/// ---------------------------------------------------------------------------
library;

import 'package:meta/meta.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';

@immutable
class DraftSpeciesSelection {
  const DraftSpeciesSelection({
    required this.speciesId,
    required this.displayName,
    required this.effects,
  });

  final SpeciesId speciesId;
  final String displayName;
  final List<CharacterEffect> effects;
}

/// Brouillon de personnage : informations partielles sauvegardées.
@immutable
class CharacterDraft {
  const CharacterDraft({
    this.name,
    this.species,
  });

  final String? name;
  final DraftSpeciesSelection? species;

  CharacterDraft copyWith({
    Object? name = _sentinel,
    Object? species = _sentinel,
  }) {
    return CharacterDraft(
      name: name == _sentinel ? this.name : name as String?,
      species:
          species == _sentinel ? this.species : species as DraftSpeciesSelection?,
    );
  }

  static const Object _sentinel = Object();
}
