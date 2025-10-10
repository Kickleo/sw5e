import 'package:meta/meta.dart';
import 'package:sw5e_manager/core/domain/result.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/ability_score.dart';

enum QuickCreateStep { species, abilities, classes, skills, background }

enum AbilityGenerationMode { standardArray, roll, manual }

@immutable
class QuickCreateState {
  final bool isLoadingCatalog;
  final bool isLoadingClassDetails;
  final bool isCreating;
  final List<String> species;
  final List<String> classes;
  final List<String> backgrounds;
  final String? selectedSpecies;
  final String? selectedClass;
  final String? selectedBackground;
  final ClassDef? selectedClassDef;
  final List<TraitDef> selectedSpeciesTraits;
  final List<String> availableSkills;
  final Map<String, SkillDef> skillDefinitions;
  final Set<String> chosenSkills;
  final int skillChoicesRequired;
  final int stepIndex;
  final String characterName;
  final String? statusMessage;
  final String? errorMessage;
  final QuickCreateCompletion? completion;
  final bool hasLoadedOnce;
  final Map<String, int?> abilityAssignments;
  final List<int> abilityPool;
  final AbilityGenerationMode abilityMode;

  const QuickCreateState({
    required this.isLoadingCatalog,
    required this.isLoadingClassDetails,
    required this.isCreating,
    required this.species,
    required this.classes,
    required this.backgrounds,
    required this.selectedSpecies,
    required this.selectedClass,
    required this.selectedBackground,
    required this.selectedClassDef,
    required this.selectedSpeciesTraits,
    required this.availableSkills,
    required this.skillDefinitions,
    required this.chosenSkills,
    required this.skillChoicesRequired,
    required this.stepIndex,
    required this.characterName,
    required this.statusMessage,
    required this.errorMessage,
    required this.completion,
    required this.hasLoadedOnce,
    required this.abilityAssignments,
    required this.abilityPool,
    required this.abilityMode,
  });

  factory QuickCreateState.initial() => const QuickCreateState(
        isLoadingCatalog: false,
        isLoadingClassDetails: false,
        isCreating: false,
        species: <String>[],
        classes: <String>[],
        backgrounds: <String>[],
        selectedSpecies: null,
        selectedClass: null,
        selectedBackground: null,
        selectedClassDef: null,
        selectedSpeciesTraits: <TraitDef>[],
        availableSkills: <String>[],
        skillDefinitions: <String, SkillDef>{},
        chosenSkills: <String>{},
        skillChoicesRequired: 0,
        stepIndex: 0,
        characterName: 'Rey',
        statusMessage: null,
        errorMessage: null,
        completion: null,
        hasLoadedOnce: false,
        abilityAssignments: <String, int?>{
          'str': 15,
          'dex': 14,
          'con': 13,
          'int': 12,
          'wis': 10,
          'cha': 8,
        },
        abilityPool: <int>[15, 14, 13, 12, 10, 8],
        abilityMode: AbilityGenerationMode.standardArray,
      );

  QuickCreateState copyWith({
    bool? isLoadingCatalog,
    bool? isLoadingClassDetails,
    bool? isCreating,
    List<String>? species,
    List<String>? classes,
    List<String>? backgrounds,
    String? selectedSpecies,
    String? selectedClass,
    String? selectedBackground,
    ClassDef? selectedClassDef,
    List<TraitDef>? selectedSpeciesTraits,
    List<String>? availableSkills,
    Map<String, SkillDef>? skillDefinitions,
    Set<String>? chosenSkills,
    int? skillChoicesRequired,
    int? stepIndex,
    String? characterName,
    Object? statusMessage = _sentinel,
    Object? errorMessage = _sentinel,
    Object? completion = _sentinel,
    bool? hasLoadedOnce,
    Map<String, int?>? abilityAssignments,
    List<int>? abilityPool,
    AbilityGenerationMode? abilityMode,
  }) {
    return QuickCreateState(
      isLoadingCatalog: isLoadingCatalog ?? this.isLoadingCatalog,
      isLoadingClassDetails: isLoadingClassDetails ?? this.isLoadingClassDetails,
      isCreating: isCreating ?? this.isCreating,
      species: species ?? this.species,
      classes: classes ?? this.classes,
      backgrounds: backgrounds ?? this.backgrounds,
      selectedSpecies: selectedSpecies ?? this.selectedSpecies,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedBackground: selectedBackground ?? this.selectedBackground,
      selectedClassDef: selectedClassDef ?? this.selectedClassDef,
      selectedSpeciesTraits: selectedSpeciesTraits ?? this.selectedSpeciesTraits,
      availableSkills: availableSkills ?? this.availableSkills,
      skillDefinitions: skillDefinitions ?? this.skillDefinitions,
      chosenSkills: chosenSkills ?? this.chosenSkills,
      skillChoicesRequired: skillChoicesRequired ?? this.skillChoicesRequired,
      stepIndex: stepIndex ?? this.stepIndex,
      characterName: characterName ?? this.characterName,
      statusMessage:
          statusMessage == _sentinel ? this.statusMessage : statusMessage as String?,
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      completion:
          completion == _sentinel ? this.completion : completion as QuickCreateCompletion?,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      abilityAssignments: abilityAssignments ?? this.abilityAssignments,
      abilityPool: abilityPool ?? this.abilityPool,
      abilityMode: abilityMode ?? this.abilityMode,
    );
  }

  QuickCreateStep get currentStep => QuickCreateStep.values[stepIndex];

  bool get canGoNext {
    switch (currentStep) {
      case QuickCreateStep.species:
        return selectedSpecies != null;
      case QuickCreateStep.abilities:
        return hasValidAbilityAssignments;
      case QuickCreateStep.classes:
        return selectedClass != null;
      case QuickCreateStep.skills:
        return hasValidSkillSelection;
      case QuickCreateStep.background:
        return canCreate;
    }
  }

  bool get canGoPrevious => stepIndex > 0;

  bool get hasValidSkillSelection =>
      skillChoicesRequired == 0 || chosenSkills.length == skillChoicesRequired;

  bool get canCreate =>
      selectedSpecies != null &&
      selectedClass != null &&
      selectedBackground != null &&
      characterName.trim().isNotEmpty &&
      hasValidSkillSelection &&
      hasValidAbilityAssignments;

  bool get hasValidAbilityAssignments {
    for (final ability in abilityOrder) {
      final value = abilityAssignments[ability];
      if (value == null || value < AbilityScore.min || value > AbilityScore.max) {
        return false;
      }
    }
    if (abilityMode == AbilityGenerationMode.manual) {
      return true;
    }
    final poolCounts = <int, int>{};
    for (final value in abilityPool) {
      poolCounts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }
    final assignedCounts = <int, int>{};
    for (final value in abilityAssignments.values) {
      if (value == null) continue;
      assignedCounts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }
    for (final entry in assignedCounts.entries) {
      final available = poolCounts[entry.key] ?? 0;
      if (entry.value > available) {
        return false;
      }
    }
    return true;
  }

  static const List<String> abilityOrder = ['str', 'dex', 'con', 'int', 'wis', 'cha'];

  static const Map<String, String> abilityLabels = {
    'str': 'Force',
    'dex': 'Dextérité',
    'con': 'Constitution',
    'int': 'Intelligence',
    'wis': 'Sagesse',
    'cha': 'Charisme',
  };

  static const Map<String, String> abilityAbbreviations = {
    'str': 'FOR',
    'dex': 'DEX',
    'con': 'CON',
    'int': 'INT',
    'wis': 'SAG',
    'cha': 'CHA',
  };
}

sealed class QuickCreateCompletion {
  const QuickCreateCompletion();
}

final class QuickCreateSuccess extends QuickCreateCompletion {
  final Character character;
  const QuickCreateSuccess(this.character);
}

final class QuickCreateFailure extends QuickCreateCompletion {
  final DomainError error;
  const QuickCreateFailure(this.error);
}

const Object _sentinel = Object();
