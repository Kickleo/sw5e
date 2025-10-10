import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw5e_manager/di/character_creation_module.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/ability_score.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/background_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_name.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/class_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/species_id.dart';
import 'package:sw5e_manager/features/character_creation/presentation/viewmodels/quick_create_state.dart';

final quickCreateViewModelProvider = StateNotifierProvider.autoDispose<QuickCreateViewModel, QuickCreateState>((ref) {
  return QuickCreateViewModel(ref)
    ..loadInitialData();
});

class QuickCreateViewModel extends StateNotifier<QuickCreateState> {
  QuickCreateViewModel(this._ref) : super(QuickCreateState.initial());

  final Ref _ref;

  CatalogRepository get _catalog => _ref.read(catalogRepositoryProvider);
  FinalizeLevel1Character get _finalize => _ref.read(finalizeLevel1CharacterProvider);

  static const List<int> _standardArray = [15, 14, 13, 12, 10, 8];

  static Map<String, int?> _emptyAbilityAssignments() => <String, int?>{
        for (final ability in QuickCreateState.abilityOrder) ability: null,
      };

  static Map<String, int?> _defaultStandardAssignments() => <String, int?>{
        'str': 15,
        'dex': 14,
        'con': 13,
        'int': 12,
        'wis': 10,
        'cha': 8,
      };

  Future<void> loadInitialData() async {
    if (state.hasLoadedOnce || state.isLoadingCatalog) return;
    state = state.copyWith(
      isLoadingCatalog: true,
      errorMessage: null,
      statusMessage: 'Chargement du catalogue…',
      hasLoadedOnce: true,
    );

    try {
      final species = await _catalog.listSpecies();
      final classes = await _catalog.listClasses();
      final backgrounds = await _catalog.listBackgrounds();

      final selectedSpecies = species.isNotEmpty ? species.first : null;
      final selectedClass = classes.isNotEmpty ? classes.first : null;
      final selectedBackground = backgrounds.isNotEmpty ? backgrounds.first : null;

      state = state.copyWith(
        species: species,
        classes: classes,
        backgrounds: backgrounds,
        selectedSpecies: selectedSpecies,
        selectedClass: selectedClass,
        selectedBackground: selectedBackground,
        availableSkills: const <String>[],
        chosenSkills: const <String>{},
        skillChoicesRequired: 0,
        isLoadingCatalog: false,
        statusMessage: null,
        errorMessage: null,
      );

      if (selectedSpecies != null) {
        await _refreshSpeciesTraits(selectedSpecies);
      }
      if (selectedClass != null) {
        await _refreshClassDef(selectedClass);
      }
    } catch (error) {
      state = state.copyWith(
        isLoadingCatalog: false,
        errorMessage: 'Erreur de chargement du catalogue: $error',
        statusMessage: null,
      );
    }
  }

  void updateName(String value) {
    if (value == state.characterName) return;
    state = state.copyWith(characterName: value);
  }

  Future<void> selectSpecies(String? id) async {
    if (id == null || id == state.selectedSpecies) return;
    state = state.copyWith(selectedSpecies: id, statusMessage: null);
    await _refreshSpeciesTraits(id);
  }

  Future<void> selectClass(String? id) async {
    if (id == null || id == state.selectedClass) return;
    state = state.copyWith(
      selectedClass: id,
      selectedClassDef: null,
      statusMessage: null,
      isLoadingClassDetails: true,
      availableSkills: const <String>[],
      chosenSkills: const <String>{},
      skillChoicesRequired: 0,
    );
    await _refreshClassDef(id);
  }

  void selectBackground(String? id) {
    if (id == state.selectedBackground) return;
    state = state.copyWith(selectedBackground: id, statusMessage: null);
  }

  void goToStep(int index) {
    if (index < 0 || index >= QuickCreateStep.values.length) return;
    state = state.copyWith(stepIndex: index);
  }

  void nextStep() {
    final nextIndex = state.stepIndex + 1;
    if (nextIndex < QuickCreateStep.values.length) {
      state = state.copyWith(stepIndex: nextIndex);
    }
  }

  void previousStep() {
    final previousIndex = state.stepIndex - 1;
    if (previousIndex >= 0) {
      state = state.copyWith(stepIndex: previousIndex);
    }
  }

  void setAbilityGenerationMode(AbilityGenerationMode mode) {
    if (mode == state.abilityMode) return;
    switch (mode) {
      case AbilityGenerationMode.standardArray:
        state = state.copyWith(
          abilityMode: mode,
          abilityPool: List<int>.from(_standardArray),
          abilityAssignments: _defaultStandardAssignments(),
          statusMessage: null,
        );
        break;
      case AbilityGenerationMode.roll:
        state = state.copyWith(
          abilityMode: mode,
          abilityPool: _generateRolledAbilityScores(),
          abilityAssignments: _emptyAbilityAssignments(),
          statusMessage: null,
        );
        break;
      case AbilityGenerationMode.manual:
        state = state.copyWith(
          abilityMode: mode,
          abilityPool: const <int>[],
          abilityAssignments: Map<String, int?>.from(state.abilityAssignments),
          statusMessage: null,
        );
        break;
    }
  }

  void rerollAbilityScores() {
    if (state.abilityMode != AbilityGenerationMode.roll) return;
    state = state.copyWith(
      abilityPool: _generateRolledAbilityScores(),
      abilityAssignments: _emptyAbilityAssignments(),
      statusMessage: null,
    );
  }

  void setAbilityScore(String ability, int? value) {
    if (!QuickCreateState.abilityOrder.contains(ability)) return;
    final current = state.abilityAssignments[ability];
    if (current == value) return;

    if (value != null) {
      if (value < AbilityScore.min || value > AbilityScore.max) {
        return;
      }
      if (state.abilityMode != AbilityGenerationMode.manual) {
        final poolCounts = _countValues(state.abilityPool);
        final assignedCounts = _countValues(
          state.abilityAssignments.entries
              .where((entry) => entry.key != ability && entry.value != null)
              .map((entry) => entry.value!),
        );
        final available = poolCounts[value] ?? 0;
        final used = assignedCounts[value] ?? 0;
        if (used >= available) {
          return;
        }
      }
    }

    final updated = Map<String, int?>.from(state.abilityAssignments);
    updated[ability] = value;
    state = state.copyWith(
      abilityAssignments: updated,
      statusMessage: null,
    );
  }

  Future<void> createCharacter() async {
    if (!state.canCreate || state.isCreating) return;
    final selectedSpecies = state.selectedSpecies;
    final selectedClass = state.selectedClass;
    final selectedBackground = state.selectedBackground;
    if (selectedSpecies == null || selectedClass == null || selectedBackground == null) {
      return;
    }

    state = state.copyWith(
      isCreating: true,
      statusMessage: 'Création en cours…',
      completion: null,
    );

    final classDef = state.selectedClassDef ?? await _catalog.getClass(selectedClass);
    final chosenSkills = Set<String>.from(state.chosenSkills);

    final abilityAssignments = state.abilityAssignments;
    final baseAbilities = <String, AbilityScore>{};
    for (final ability in QuickCreateState.abilityOrder) {
      final rawValue = abilityAssignments[ability];
      if (rawValue == null) {
        state = state.copyWith(
          isCreating: false,
          statusMessage: null,
          errorMessage: 'Veuillez attribuer une valeur à chaque caractéristique.',
        );
        return;
      }
      try {
        baseAbilities[ability] = AbilityScore(rawValue);
      } on ArgumentError {
        state = state.copyWith(
          isCreating: false,
          statusMessage: null,
          errorMessage:
              'Valeur invalide pour ${QuickCreateState.abilityLabels[ability] ?? ability.toUpperCase()}.',
        );
        return;
      }
    }

    final input = FinalizeLevel1Input(
      name: CharacterName(state.characterName.trim()),
      speciesId: SpeciesId(selectedSpecies),
      classId: ClassId(selectedClass),
      backgroundId: BackgroundId(selectedBackground),
      baseAbilities: baseAbilities,
      chosenSkills: chosenSkills,
      chosenEquipment: const <ChosenEquipmentLine>[],
    );

    final result = await _finalize(input);

    result.match(
      ok: (character) {
        state = state.copyWith(
          isCreating: false,
          statusMessage: 'OK: ${character.name.value}',
          completion: QuickCreateSuccess(character),
          errorMessage: null,
        );
      },
      err: (error) {
        state = state.copyWith(
          isCreating: false,
          statusMessage: null,
          completion: QuickCreateFailure(error),
          errorMessage: 'Erreur: ${error.code}${error.message != null ? ' — ${error.message}' : ''}',
        );
      },
    );
  }

  void clearCompletion() {
    if (state.completion != null) {
      state = state.copyWith(completion: null);
    }
  }

  Future<void> _refreshSpeciesTraits(String speciesId) async {
    try {
      final species = await _catalog.getSpecies(speciesId);
      if (species == null) {
        state = state.copyWith(selectedSpeciesTraits: const <TraitDef>[]);
        return;
      }
      final traits = <TraitDef>[];
      for (final traitId in species.traitIds) {
        final trait = await _catalog.getTrait(traitId);
        if (trait != null) {
          traits.add(trait);
        }
      }
      state = state.copyWith(selectedSpeciesTraits: traits);
    } catch (e) {
      state = state.copyWith(statusMessage: 'Erreur lors du chargement des traits: $e');
    }
  }

  Future<void> _refreshClassDef(String classId) async {
    try {
      final def = await _catalog.getClass(classId);
      if (def == null) {
        state = state.copyWith(
          selectedClassDef: null,
          availableSkills: const <String>[],
          chosenSkills: const <String>{},
          skillChoicesRequired: 0,
          isLoadingClassDetails: false,
        );
        return;
      }

      final proficiencies = def.level1.proficiencies;
      final choose = proficiencies.skillsChoose;
      final from = proficiencies.skillsFrom;
      final allowsAny = from.contains('any');
      final filtered = from.where((id) => id != 'any');
      List<String> available;
      if (allowsAny) {
        available = await _catalog.listSkills();
      } else {
        available = filtered.toList();
      }
      available.sort();

      final availableSet = available.toSet();
      final retainedSelection = state.chosenSkills.where(availableSet.contains).toSet();
      if (choose == 0) {
        retainedSelection.clear();
      }

      state = state.copyWith(
        selectedClassDef: def,
        isLoadingClassDetails: false,
        availableSkills: available,
        chosenSkills: retainedSelection,
        skillChoicesRequired: choose,
      );

      if (available.isNotEmpty) {
        await _ensureSkillDefs(available);
      }
    } catch (e) {
      state = state.copyWith(
        statusMessage: 'Erreur lors du chargement de la classe: $e',
        isLoadingClassDetails: false,
      );
    }
  }

  List<int> _generateRolledAbilityScores() {
    final random = Random();
    final scores = List<int>.generate(6, (_) => _roll4d6DropLowest(random));
    scores.sort((a, b) => b.compareTo(a));
    return scores;
  }

  int _roll4d6DropLowest(Random random) {
    final rolls = List<int>.generate(4, (_) => random.nextInt(6) + 1)..sort();
    return rolls.sublist(1).reduce((a, b) => a + b);
  }

  Map<int, int> _countValues(Iterable<int> values) {
    final counts = <int, int>{};
    for (final value in values) {
      counts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  Future<void> _ensureSkillDefs(Iterable<String> ids) async {
    final existing = Map<String, SkillDef>.from(state.skillDefinitions);
    var hasNew = false;
    for (final id in ids) {
      if (existing.containsKey(id)) continue;
      final def = await _catalog.getSkill(id);
      if (def != null) {
        existing[id] = def;
        hasNew = true;
      }
    }
    if (hasNew) {
      state = state.copyWith(skillDefinitions: existing);
    }
  }

  void toggleSkillSelection(String id) {
    final required = state.skillChoicesRequired;
    if (required == 0) {
      return;
    }
    if (!state.availableSkills.contains(id)) {
      return;
    }

    final current = state.chosenSkills.toSet();
    if (current.contains(id)) {
      current.remove(id);
    } else {
      if (current.length >= required) {
        return;
      }
      current.add(id);
    }

    state = state.copyWith(chosenSkills: current);
  }
}
