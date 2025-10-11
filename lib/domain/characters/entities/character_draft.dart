/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/entities/character_draft.dart
/// Rôle : Représenter l'état incomplet d'un personnage en cours de création.
///        Permet de persister la progression (espèce, effets, etc.).
/// ---------------------------------------------------------------------------
library;

import 'package:meta/meta.dart';
import 'package:sw5e_manager/domain/characters/value_objects/background_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';
import 'package:sw5e_manager/domain/characters/value_objects/class_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';

/// Modes de génération des caractéristiques retenus dans le brouillon.
enum DraftAbilityGenerationMode { standardArray, roll, manual }

/// Photographie des scores de caractéristiques (mode + affectations + pool).
@immutable
class DraftAbilityScores {
  const DraftAbilityScores({
    required this.mode,
    required Map<String, int?> assignments,
    required List<int> pool,
  })  : assignments = Map<String, int?>.unmodifiable(assignments),
        pool = List<int>.unmodifiable(pool);

  final DraftAbilityGenerationMode mode;
  final Map<String, int?> assignments;
  final List<int> pool;

  DraftAbilityScores copyWith({
    DraftAbilityGenerationMode? mode,
    Map<String, int?>? assignments,
    List<int>? pool,
  }) {
    return DraftAbilityScores(
      mode: mode ?? this.mode,
      assignments: assignments ?? this.assignments,
      pool: pool ?? this.pool,
    );
  }
}

/// Sélection d'équipement conservée dans le brouillon (pack + quantités).
@immutable
class DraftEquipmentSelection {
  const DraftEquipmentSelection({
    required this.useStartingEquipment,
    required Map<String, int> quantities,
  }) : quantities = Map<String, int>.unmodifiable(quantities);

  final bool useStartingEquipment;
  final Map<String, int> quantities;

  DraftEquipmentSelection copyWith({
    bool? useStartingEquipment,
    Map<String, int>? quantities,
  }) {
    return DraftEquipmentSelection(
      useStartingEquipment: useStartingEquipment ?? this.useStartingEquipment,
      quantities: quantities ?? this.quantities,
    );
  }
}

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
    this.classId,
    this.backgroundId,
    this.abilityScores,
    Set<String>? chosenSkills,
    this.equipment,
  }) : chosenSkills = chosenSkills == null
            ? const <String>{}
            : Set<String>.unmodifiable(chosenSkills);

  final String? name;
  final DraftSpeciesSelection? species;
  final ClassId? classId;
  final BackgroundId? backgroundId;
  final DraftAbilityScores? abilityScores;
  final Set<String> chosenSkills;
  final DraftEquipmentSelection? equipment;

  CharacterDraft copyWith({
    Object? name = _sentinel,
    Object? species = _sentinel,
    Object? classId = _sentinel,
    Object? backgroundId = _sentinel,
    Object? abilityScores = _sentinel,
    Object? chosenSkills = _sentinel,
    Object? equipment = _sentinel,
  }) {
    return CharacterDraft(
      name: name == _sentinel ? this.name : name as String?,
      species:
          species == _sentinel ? this.species : species as DraftSpeciesSelection?,
      classId: classId == _sentinel ? this.classId : classId as ClassId?,
      backgroundId: backgroundId == _sentinel
          ? this.backgroundId
          : backgroundId as BackgroundId?,
      abilityScores: abilityScores == _sentinel
          ? this.abilityScores
          : abilityScores as DraftAbilityScores?,
      chosenSkills: chosenSkills == _sentinel
          ? this.chosenSkills
          : Set<String>.unmodifiable(chosenSkills as Set<String>),
      equipment: equipment == _sentinel
          ? this.equipment
          : equipment as DraftEquipmentSelection?,
    );
  }

  static const Object _sentinel = Object();
}
