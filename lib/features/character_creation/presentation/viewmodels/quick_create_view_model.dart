import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw5e_manager/core/domain/result.dart';
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
    final skillsFrom = classDef?.level1.proficiencies.skillsFrom ?? const <String>[];
    final choose = classDef?.level1.proficiencies.skillsChoose ?? 0;
    final chosenSkills = skillsFrom.take(choose).toSet();

    final input = FinalizeLevel1Input(
      name: CharacterName(state.characterName.trim()),
      speciesId: SpeciesId(selectedSpecies),
      classId: ClassId(selectedClass),
      backgroundId: BackgroundId(selectedBackground),
      baseAbilities: const {
        'str': AbilityScore(10),
        'dex': AbilityScore(12),
        'con': AbilityScore(14),
        'int': AbilityScore(10),
        'wis': AbilityScore(10),
        'cha': AbilityScore(10),
      },
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
      state = state.copyWith(
        selectedClassDef: def,
        isLoadingClassDetails: false,
      );
    } catch (e) {
      state = state.copyWith(
        statusMessage: 'Erreur lors du chargement de la classe: $e',
        isLoadingClassDetails: false,
      );
    }
  }
}
