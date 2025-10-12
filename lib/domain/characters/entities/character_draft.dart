/// Structures décrivant un personnage en cours de création.
///
/// Le brouillon capture les choix intermédiaires réalisés par l'utilisateur
/// avant la finalisation en [Character]. Chaque structure reste immutable afin
/// de simplifier l'utilisation dans des architectures réactives (BLoC,
/// Riverpod, etc.).
library;

import 'package:meta/meta.dart';
import 'package:sw5e_manager/domain/characters/value_objects/background_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';
import 'package:sw5e_manager/domain/characters/value_objects/class_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';

/// Modes de génération des caractéristiques retenus dans le brouillon.
enum DraftAbilityGenerationMode { standardArray, roll, manual }

/// Photographie des scores de caractéristiques (mode + affectations + pool).
///
/// - [mode] indique la méthode sélectionnée (table standard, tirage, manuel) ;
/// - [assignments] conserve, par abréviation, la valeur assignée ou `null` si
///   l'emplacement est libre ;
/// - [pool] mémorise les valeurs encore disponibles lors d'un tirage/standard
///   afin de pouvoir réinitialiser la distribution.
@immutable
class DraftAbilityScores {
  DraftAbilityScores({
    required this.mode,
    required Map<String, int?> assignments,
    required List<int> pool,
  })  : assignments = Map<String, int?>.unmodifiable(assignments),
        pool = List<int>.unmodifiable(pool);

  final DraftAbilityGenerationMode mode;
  final Map<String, int?> assignments;
  final List<int> pool;

  /// Crée une nouvelle instance en ne remplaçant que les champs fournis.
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
///
/// Le booléen [useStartingEquipment] reflète la case à cocher « pack de départ »
/// tandis que [quantities] stocke les achats additionnels saisis manuellement.
@immutable
class DraftEquipmentSelection {
  DraftEquipmentSelection({
    required this.useStartingEquipment,
    required Map<String, int> quantities,
  }) : quantities = Map<String, int>.unmodifiable(quantities);

  final bool useStartingEquipment;
  final Map<String, int> quantities;

  /// Crée une nouvelle instance en ne remplaçant que les champs fournis.
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

/// Conteneur principal du brouillon : chaque champ peut être nul tant que la
/// progression n'est pas terminée. Les setters immuables facilitent
/// l'utilisation avec des BLoC/StateNotifier.
///
/// Les propriétés couvrent l'intégralité du wizard :
///
/// - [name] = saisie libre ;
/// - [species]/[classId]/[backgroundId] = choix dans les catalogues ;
/// - [abilityScores] = configuration des caractéristiques ;
/// - [chosenSkills] = compétences retenues ;
/// - [equipment] = sélection d'équipement ;
/// - [stepIndex] = dernière étape visitée pour restaurer la progression.
@immutable
class CharacterDraft {
  CharacterDraft({
    this.name,
    this.species,
    this.classId,
    this.backgroundId,
    this.abilityScores,
    Set<String>? chosenSkills,
    this.equipment,
    this.stepIndex,
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
  final int? stepIndex;

  /// Permet de cloner le brouillon en remplaçant uniquement certains champs.
  /// L'usage d'un _sentinel interne différencie « ne pas toucher » de
  /// « remplacer par null », indispensable pour gérer les retours en arrière.
  CharacterDraft copyWith({
    Object? name = _sentinel,
    Object? species = _sentinel,
    Object? classId = _sentinel,
    Object? backgroundId = _sentinel,
    Object? abilityScores = _sentinel,
    Object? chosenSkills = _sentinel,
    Object? equipment = _sentinel,
    Object? stepIndex = _sentinel,
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
      stepIndex:
          stepIndex == _sentinel ? this.stepIndex : stepIndex as int?,
    );
  }

  static const Object _sentinel = Object();
}
