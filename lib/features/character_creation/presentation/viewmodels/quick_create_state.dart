import 'package:meta/meta.dart';
import 'package:sw5e_manager/core/domain/result.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';

enum QuickCreateStep { species, classes, skills, background }

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
    );
  }

  QuickCreateStep get currentStep => QuickCreateStep.values[stepIndex];

  bool get canGoNext {
    switch (currentStep) {
      case QuickCreateStep.species:
        return selectedSpecies != null;
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
      hasValidSkillSelection;
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
