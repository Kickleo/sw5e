/// ---------------------------------------------------------------------------
/// Fichier : lib/presentation/character_creation/blocs/quick_create_bloc.dart
/// Rôle : ViewModel MVVM basé sur BLoC pour l'assistant de création rapide.
/// Dépendances : use cases LoadQuickCreateCatalog/LoadSpeciesDetails/
///        LoadClassDetails, FinalizeLevel1Character, AppLogger, AppFailure,
///        état [QuickCreateState].
/// Exemple d'usage :
///   final bloc = QuickCreateBloc(...)
///     ..add(const QuickCreateStarted());
///   bloc.stream.listen((state) => debugPrint(state.stepIndex.toString()));
/// ---------------------------------------------------------------------------
library;
import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sw5e_manager/common/errors/app_failure.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart'
    show ClassDef;
import 'package:sw5e_manager/domain/characters/usecases/clear_character_draft.dart';
import 'package:sw5e_manager/domain/characters/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_character_draft.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_class_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_quick_create_catalog.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_ability_scores.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_background.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_class.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_equipment.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_name.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_species.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_step.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_skills.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/domain/characters/value_objects/background_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_name.dart';
import 'package:sw5e_manager/domain/characters/value_objects/class_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/equipment_item_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/quantity.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';
import 'package:sw5e_manager/presentation/character_creation/states/quick_create_state.dart';

/// ---- Events ----------------------------------------------------------------

/// QuickCreateEvent = intention utilisateur/ système qui déclenche une mutation.
sealed class QuickCreateEvent extends Equatable {
  /// Constructeur const par défaut.
  const QuickCreateEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// QuickCreateStarted = chargement initial du catalogue.
class QuickCreateStarted extends QuickCreateEvent {
  /// force=true relance le chargement même si déjà effectué.
  const QuickCreateStarted({this.force = false});

  /// Bypass du garde "déjà chargé".
  final bool force;

  @override
  List<Object?> get props => <Object?>[force];
}

/// QuickCreateNameChanged = mise à jour du nom saisi.
class QuickCreateNameChanged extends QuickCreateEvent {
  /// Nouveau nom.
  final String name;

  /// Crée l'événement.
  const QuickCreateNameChanged(this.name);

  @override
  List<Object?> get props => <Object?>[name];
}

/// QuickCreateSpeciesSelected = choix d'une espèce.
class QuickCreateSpeciesSelected extends QuickCreateEvent {
  /// Identifiant de l'espèce.
  final String speciesId;

  /// Crée l'événement.
  const QuickCreateSpeciesSelected(this.speciesId);

  @override
  List<Object?> get props => <Object?>[speciesId];
}

/// QuickCreateClassSelected = choix d'une classe.
class QuickCreateClassSelected extends QuickCreateEvent {
  /// Identifiant de la classe.
  final String classId;

  /// Crée l'événement.
  const QuickCreateClassSelected(this.classId);

  @override
  List<Object?> get props => <Object?>[classId];
}

/// QuickCreateBackgroundSelected = choix du background.
class QuickCreateBackgroundSelected extends QuickCreateEvent {
  /// Identifiant du background.
  final String backgroundId;

  /// Crée l'événement.
  const QuickCreateBackgroundSelected(this.backgroundId);

  @override
  List<Object?> get props => <Object?>[backgroundId];
}

/// QuickCreateStepChanged = navigation directe vers une étape.
class QuickCreateStepChanged extends QuickCreateEvent {
  /// Index demandé.
  final int index;

  /// Crée l'événement.
  const QuickCreateStepChanged(this.index);

  @override
  List<Object?> get props => <Object?>[index];
}

/// QuickCreateNextStepRequested = passage à l'étape suivante.
class QuickCreateNextStepRequested extends QuickCreateEvent {
  /// Constructeur const.
  const QuickCreateNextStepRequested();
}

/// QuickCreatePreviousStepRequested = retour à l'étape précédente.
class QuickCreatePreviousStepRequested extends QuickCreateEvent {
  /// Constructeur const.
  const QuickCreatePreviousStepRequested();
}

/// QuickCreateAbilityModeChanged = changement de mode d'attribution des scores.
class QuickCreateAbilityModeChanged extends QuickCreateEvent {
  /// Nouveau mode.
  final AbilityGenerationMode mode;

  /// Crée l'événement.
  const QuickCreateAbilityModeChanged(this.mode);

  @override
  List<Object?> get props => <Object?>[mode];
}

/// QuickCreateAbilityScoresRerolled = relance des scores aléatoires.
class QuickCreateAbilityScoresRerolled extends QuickCreateEvent {
  /// Constructeur const.
  const QuickCreateAbilityScoresRerolled();
}

/// QuickCreateAbilityAssigned = affectation d'un score à une caractéristique.
class QuickCreateAbilityAssigned extends QuickCreateEvent {
  /// Caractéristique ciblée (str/dex...).
  final String ability;

  /// Valeur choisie (null pour réinitialiser).
  final int? value;

  /// Crée l'événement.
  const QuickCreateAbilityAssigned(this.ability, this.value);

  @override
  List<Object?> get props => <Object?>[ability, value];
}

/// QuickCreateSkillToggled = ajout/suppression d'une compétence choisie.
class QuickCreateSkillToggled extends QuickCreateEvent {
  /// Identifiant de la compétence.
  final String skillId;

  /// Crée l'événement.
  const QuickCreateSkillToggled(this.skillId);

  @override
  List<Object?> get props => <Object?>[skillId];
}

/// QuickCreateUseStartingEquipmentChanged = bascule pack d'équipement.
class QuickCreateUseStartingEquipmentChanged extends QuickCreateEvent {
  /// Nouveau statut.
  final bool useStartingEquipment;

  /// Crée l'événement.
  const QuickCreateUseStartingEquipmentChanged(this.useStartingEquipment);

  @override
  List<Object?> get props => <Object?>[useStartingEquipment];
}

/// QuickCreateEquipmentQuantityChanged = modification de quantité.
class QuickCreateEquipmentQuantityChanged extends QuickCreateEvent {
  /// Identifiant de l'équipement.
  final String equipmentId;

  /// Quantité souhaitée.
  final int quantity;

  /// Crée l'événement.
  const QuickCreateEquipmentQuantityChanged(this.equipmentId, this.quantity);

  @override
  List<Object?> get props => <Object?>[equipmentId, quantity];
}

/// QuickCreateSubmitted = demande de finalisation du personnage.
class QuickCreateSubmitted extends QuickCreateEvent {
  /// Constructeur const.
  const QuickCreateSubmitted();
}

/// QuickCreateCompletionCleared = reset de la complétion (fermeture dialog).
class QuickCreateCompletionCleared extends QuickCreateEvent {
  /// Constructeur const.
  const QuickCreateCompletionCleared();
}

/// ---- BLoC ------------------------------------------------------------------

/// QuickCreateBloc = ViewModel BLoC orchestrant le wizard de création rapide.
class QuickCreateBloc extends Bloc<QuickCreateEvent, QuickCreateState> {
  /// Crée le bloc avec les dépendances nécessaires.
  QuickCreateBloc({
    required LoadQuickCreateCatalog loadQuickCreateCatalog,
    required LoadSpeciesDetails loadSpeciesDetails,
    required LoadClassDetails loadClassDetails,
    required LoadCharacterDraft loadCharacterDraft,
    required FinalizeLevel1Character finalizeLevel1Character,
    required AppLogger logger,
    required PersistCharacterDraftName persistCharacterDraftName,
    required PersistCharacterDraftSpecies persistCharacterDraftSpecies,
    required PersistCharacterDraftClass persistCharacterDraftClass,
    required PersistCharacterDraftBackground persistCharacterDraftBackground,
    required PersistCharacterDraftAbilityScores persistCharacterDraftAbilityScores,
    required PersistCharacterDraftSkills persistCharacterDraftSkills,
    required PersistCharacterDraftEquipment persistCharacterDraftEquipment,
    required PersistCharacterDraftStep persistCharacterDraftStep,
    required ClearCharacterDraft clearCharacterDraft,
    Random? random,
  })  : _loadQuickCreateCatalog = loadQuickCreateCatalog,
        _loadSpeciesDetails = loadSpeciesDetails,
        _loadClassDetails = loadClassDetails,
        _loadCharacterDraft = loadCharacterDraft,
        _finalizeLevel1Character = finalizeLevel1Character,
        _logger = logger,
        _persistCharacterDraftName = persistCharacterDraftName,
        _persistCharacterDraftSpecies = persistCharacterDraftSpecies,
        _persistCharacterDraftClass = persistCharacterDraftClass,
        _persistCharacterDraftBackground = persistCharacterDraftBackground,
        _persistCharacterDraftAbilityScores = persistCharacterDraftAbilityScores,
        _persistCharacterDraftSkills = persistCharacterDraftSkills,
        _persistCharacterDraftEquipment = persistCharacterDraftEquipment,
        _persistCharacterDraftStep = persistCharacterDraftStep,
        _clearCharacterDraft = clearCharacterDraft,
        _random = random ?? Random(),
        super(QuickCreateState.initial()) {
    on<QuickCreateStarted>(_onStarted);
    on<QuickCreateNameChanged>(_onNameChanged);
    on<QuickCreateSpeciesSelected>(_onSpeciesSelected);
    on<QuickCreateClassSelected>(_onClassSelected);
    on<QuickCreateBackgroundSelected>(_onBackgroundSelected);
    on<QuickCreateStepChanged>(_onStepChanged);
    on<QuickCreateNextStepRequested>(_onNextStepRequested);
    on<QuickCreatePreviousStepRequested>(_onPreviousStepRequested);
    on<QuickCreateAbilityModeChanged>(_onAbilityModeChanged);
    on<QuickCreateAbilityScoresRerolled>(_onAbilityScoresRerolled);
    on<QuickCreateAbilityAssigned>(_onAbilityAssigned);
    on<QuickCreateSkillToggled>(_onSkillToggled);
    on<QuickCreateUseStartingEquipmentChanged>(_onUseStartingEquipmentChanged);
    on<QuickCreateEquipmentQuantityChanged>(_onEquipmentQuantityChanged);
    on<QuickCreateSubmitted>(_onSubmitted);
    on<QuickCreateCompletionCleared>(_onCompletionCleared);
  }

  final LoadQuickCreateCatalog _loadQuickCreateCatalog;
  final LoadSpeciesDetails _loadSpeciesDetails;
  final LoadClassDetails _loadClassDetails;
  final LoadCharacterDraft _loadCharacterDraft;
  final FinalizeLevel1Character _finalizeLevel1Character;
  final AppLogger _logger;
  final PersistCharacterDraftName _persistCharacterDraftName;
  final PersistCharacterDraftSpecies _persistCharacterDraftSpecies;
  final PersistCharacterDraftClass _persistCharacterDraftClass;
  final PersistCharacterDraftBackground _persistCharacterDraftBackground;
  final PersistCharacterDraftAbilityScores _persistCharacterDraftAbilityScores;
  final PersistCharacterDraftSkills _persistCharacterDraftSkills;
  final PersistCharacterDraftEquipment _persistCharacterDraftEquipment;
  final PersistCharacterDraftStep _persistCharacterDraftStep;
  final ClearCharacterDraft _clearCharacterDraft;
  final Random _random;

  static const List<int> _standardArray = <int>[15, 14, 13, 12, 10, 8];

  /// Construit une map vide (toutes valeurs nulles) pour suivre les attributions
  /// de caractéristiques dans le mode manuel/jet.
  Map<String, int?> _emptyAbilityAssignments() => <String, int?>{
        for (final String ability in QuickCreateState.abilityOrder) ability: null,
      };

  /// Affectations par défaut correspondant au standard array classique.
  Map<String, int?> _defaultStandardAssignments() => const <String, int?>{
        'str': 15,
        'dex': 14,
        'con': 13,
        'int': 12,
        'wis': 10,
        'cha': 8,
      };

  /// Conversion du mode UI vers le mode persisté dans le brouillon.
  DraftAbilityGenerationMode _mapToDraftMode(AbilityGenerationMode mode) {
    switch (mode) {
      case AbilityGenerationMode.standardArray:
        return DraftAbilityGenerationMode.standardArray;
      case AbilityGenerationMode.roll:
        return DraftAbilityGenerationMode.roll;
      case AbilityGenerationMode.manual:
        return DraftAbilityGenerationMode.manual;
    }
  }

  /// Conversion inverse : du brouillon vers le mode présenté dans l'UI.
  AbilityGenerationMode _mapFromDraftMode(DraftAbilityGenerationMode mode) {
    switch (mode) {
      case DraftAbilityGenerationMode.standardArray:
        return AbilityGenerationMode.standardArray;
      case DraftAbilityGenerationMode.roll:
        return AbilityGenerationMode.roll;
      case DraftAbilityGenerationMode.manual:
        return AbilityGenerationMode.manual;
    }
  }

  /// Prépare un instantané des caractéristiques à sauvegarder.
  DraftAbilityScores _buildDraftAbilityScoresSnapshot(
    QuickCreateState current,
  ) {
    return DraftAbilityScores(
      mode: _mapToDraftMode(current.abilityMode),
      assignments: Map<String, int?>.from(current.abilityAssignments),
      pool: List<int>.from(current.abilityPool),
    );
  }

  /// Prépare un instantané de l'équipement sélectionné.
  DraftEquipmentSelection _buildDraftEquipmentSelectionSnapshot(
    QuickCreateState current,
  ) {
    return DraftEquipmentSelection(
      useStartingEquipment: current.useStartingEquipment,
      quantities: Map<String, int>.from(current.chosenEquipment),
    );
  }

  /// Charge le catalogue et tente de restaurer un brouillon existant.
  Future<void> _onStarted(
    QuickCreateStarted event,
    Emitter<QuickCreateState> emit,
  ) async {
    if (state.hasLoadedOnce && !event.force) {
      return;
    }

    emit(
      state.copyWith(
        isLoadingCatalog: true,
        failure: null,
        statusMessage: 'Chargement du catalogue…',
        hasLoadedOnce: true,
        isLoadingEquipment: true,
      ),
    );

    final AppResult<QuickCreateCatalogSnapshot> result =
        await _loadQuickCreateCatalog();

    await result.match(
      ok: (QuickCreateCatalogSnapshot snapshot) async {
        CharacterDraft? existingDraft;
        final AppResult<CharacterDraft?> draftResult =
            await _loadCharacterDraft();
        draftResult.match(
          ok: (CharacterDraft? draft) {
            existingDraft = draft;
          },
          err: (DomainError error) {
            _logger.warn(
              'Échec du chargement du brouillon en reprise',
              error: error,
            );
          },
        );

        String? resolvedSpeciesId = snapshot.defaultSpeciesId;
        final String? draftSpeciesId = existingDraft?.species?.speciesId.value;
        if (draftSpeciesId != null && snapshot.speciesIds.contains(draftSpeciesId)) {
          resolvedSpeciesId = draftSpeciesId;
        }

        String? resolvedClassId = snapshot.defaultClassId;
        final String? draftClassId = existingDraft?.classId?.value;
        if (draftClassId != null && snapshot.classIds.contains(draftClassId)) {
          resolvedClassId = draftClassId;
        }

        String? resolvedBackgroundId = snapshot.defaultBackgroundId;
        final String? draftBackgroundId = existingDraft?.backgroundId?.value;
        if (draftBackgroundId != null &&
            snapshot.backgroundIds.contains(draftBackgroundId)) {
          resolvedBackgroundId = draftBackgroundId;
        }

        AbilityGenerationMode resolvedAbilityMode =
            AbilityGenerationMode.standardArray;
        Map<String, int?> resolvedAssignments = _defaultStandardAssignments();
        List<int> resolvedPool = List<int>.from(_standardArray);
        final DraftAbilityScores? draftAbilityScores = existingDraft?.abilityScores;
        if (draftAbilityScores != null) {
          resolvedAbilityMode = _mapFromDraftMode(draftAbilityScores.mode);
          final Map<String, int?> normalized = _emptyAbilityAssignments();
          normalized.addAll(draftAbilityScores.assignments);
          resolvedAssignments = normalized;
          resolvedPool = List<int>.from(draftAbilityScores.pool);
          if (resolvedAbilityMode == AbilityGenerationMode.standardArray &&
              resolvedPool.length != _standardArray.length) {
            resolvedPool = List<int>.from(_standardArray);
          }
        }

        final Set<String> resolvedSkills =
            existingDraft?.chosenSkills ?? const <String>{};
        final DraftEquipmentSelection? draftEquipment = existingDraft?.equipment;
        final bool resolvedUseStartingEquipment =
            draftEquipment?.useStartingEquipment ?? true;
        final Map<String, int> resolvedEquipment = draftEquipment == null
            ? <String, int>{}
            : Map<String, int>.from(draftEquipment.quantities);

        final int resolvedStepIndex = _sanitizeStepIndex(existingDraft?.stepIndex);

        emit(
          state.copyWith(
            species: snapshot.speciesIds,
            classes: snapshot.classIds,
            backgrounds: snapshot.backgroundIds,
            selectedSpecies: resolvedSpeciesId,
            selectedClass: resolvedClassId,
            selectedBackground: resolvedBackgroundId,
            availableSkills: const <String>[],
            chosenSkills: resolvedSkills,
            skillChoicesRequired: 0,
            isLoadingCatalog: false,
            statusMessage: null,
            failure: null,
            equipmentDefinitions: snapshot.equipmentById,
            equipmentList: snapshot.sortedEquipmentIds,
            chosenEquipment: resolvedEquipment,
            useStartingEquipment: resolvedUseStartingEquipment,
            isLoadingEquipment: false,
            characterName: existingDraft?.name ?? state.characterName,
            abilityAssignments: resolvedAssignments,
            abilityPool: resolvedPool,
            abilityMode: resolvedAbilityMode,
            stepIndex: resolvedStepIndex,
            selectedSpeciesEffects:
                existingDraft?.species?.effects ?? const <CharacterEffect>[],
          ),
        );

        if (resolvedSpeciesId != null) {
          await _refreshSpeciesTraits(resolvedSpeciesId, emit);
        }
        if (resolvedClassId != null) {
          await _refreshClassDef(resolvedClassId, emit);
        }
      },
      err: (DomainError error) async {
        final AppFailure failure = AppFailure.fromDomain(error);
        _logger.error(
          'Erreur de chargement du catalogue',
          error: failure,
        );
        emit(
          state.copyWith(
            isLoadingCatalog: false,
            isLoadingEquipment: false,
            failure: failure,
            statusMessage: null,
          ),
        );
      },
    );
  }

  /// Persiste les modifications de nom et met à jour l'état local.
  Future<void> _onNameChanged(
    QuickCreateNameChanged event,
    Emitter<QuickCreateState> emit,
  ) async {
    if (event.name == state.characterName) {
      return;
    }
    final QuickCreateState updated =
        state.copyWith(characterName: event.name, statusMessage: null);
    emit(updated);
    final AppResult<CharacterDraft> result =
        await _persistCharacterDraftName(event.name);
    result.match(
      ok: (_) {},
      err: (DomainError error) {
        _logger.warn(
          'Échec de la sauvegarde du nom',
          error: error,
          payload: {'name': event.name},
        );
      },
    );
  }

  /// Charge les détails de l'espèce puis enregistre le brouillon enrichi.
  Future<void> _onSpeciesSelected(
    QuickCreateSpeciesSelected event,
    Emitter<QuickCreateState> emit,
  ) async {
    if (event.speciesId == state.selectedSpecies) {
      return;
    }
    emit(state.copyWith(selectedSpecies: event.speciesId, statusMessage: null));
    await _refreshSpeciesTraits(event.speciesId, emit);
  }

  /// Met à jour la classe choisie et déclenche la persistance.
  Future<void> _onClassSelected(
    QuickCreateClassSelected event,
    Emitter<QuickCreateState> emit,
  ) async {
    if (event.classId == state.selectedClass) {
      return;
    }
    final QuickCreateState updated = state.copyWith(
        selectedClass: event.classId,
        selectedClassDef: null,
        statusMessage: null,
        isLoadingClassDetails: true,
        availableSkills: const <String>[],
        chosenSkills: const <String>{},
        skillChoicesRequired: 0,
        chosenEquipment: const <String, int>{},
        useStartingEquipment: true,
      ),
    );
    emit(updated);
    final AppResult<CharacterDraft> persistClassResult =
        await _persistCharacterDraftClass(event.classId);
    persistClassResult.match(
      ok: (_) {},
      err: (DomainError error) {
        _logger.warn(
          'Échec de la sauvegarde de la classe',
          error: error,
          payload: {'classId': event.classId},
        );
      },
    );
    await _persistSkillsSnapshot(updated);
    await _persistEquipmentSnapshot(updated);
    await _refreshClassDef(event.classId, emit);
  }

  /// Met à jour le background sélectionné et le sauvegarde.
  Future<void> _onBackgroundSelected(
    QuickCreateBackgroundSelected event,
    Emitter<QuickCreateState> emit,
  ) async {
    if (event.backgroundId == state.selectedBackground) {
      return;
    }
    final QuickCreateState updated = state.copyWith(
      selectedBackground: event.backgroundId,
      statusMessage: null,
    );
    emit(updated);
    final AppResult<CharacterDraft> result =
        await _persistCharacterDraftBackground(event.backgroundId);
    result.match(
      ok: (_) {},
      err: (DomainError error) {
        _logger.warn(
          'Échec de la sauvegarde du background',
          error: error,
          payload: {'backgroundId': event.backgroundId},
        );
      },
    );
  }

  /// Synchronise l'étape courante avec la navigation manuelle de l'UI.
  Future<void> _onStepChanged(
    QuickCreateStepChanged event,
    Emitter<QuickCreateState> emit,
  ) async {
    if (event.index < 0 || event.index >= QuickCreateStep.values.length) {
      return;
    }
    emit(state.copyWith(stepIndex: event.index));
    await _persistStepIndex(event.index);
  }

  /// Passe à l'étape suivante (si possible) et enregistre l'indice.
  Future<void> _onNextStepRequested(
    QuickCreateNextStepRequested event,
    Emitter<QuickCreateState> emit,
  ) async {
    final int nextIndex = state.stepIndex + 1;
    if (nextIndex < QuickCreateStep.values.length) {
      emit(state.copyWith(stepIndex: nextIndex));
      await _persistStepIndex(nextIndex);
    }
  }

  /// Reculer d'une étape et enregistrer l'indice persistant.
  Future<void> _onPreviousStepRequested(
    QuickCreatePreviousStepRequested event,
    Emitter<QuickCreateState> emit,
  ) async {
    final int previousIndex = state.stepIndex - 1;
    if (previousIndex >= 0) {
      emit(state.copyWith(stepIndex: previousIndex));
      await _persistStepIndex(previousIndex);
    }
  }

  /// Met à jour le mode de génération (standard/jet/manual) et persiste.
  Future<void> _onAbilityModeChanged(
    QuickCreateAbilityModeChanged event,
    Emitter<QuickCreateState> emit,
  ) async {
    if (event.mode == state.abilityMode) {
      return;
    }
    QuickCreateState updated;
    switch (event.mode) {
      case AbilityGenerationMode.standardArray:
        updated = state.copyWith(
          abilityMode: event.mode,
          abilityPool: List<int>.from(_standardArray),
          abilityAssignments: _defaultStandardAssignments(),
          statusMessage: null,
        );
        break;
      case AbilityGenerationMode.roll:
        updated = state.copyWith(
          abilityMode: event.mode,
          abilityPool: _generateRolledAbilityScores(),
          abilityAssignments: _emptyAbilityAssignments(),
          statusMessage: null,
        );
        break;
      case AbilityGenerationMode.manual:
        updated = state.copyWith(
          abilityMode: event.mode,
          abilityPool: const <int>[],
          abilityAssignments: Map<String, int?>.from(state.abilityAssignments),
          statusMessage: null,
        );
        break;
    }
    emit(updated);
    await _persistAbilityScoresSnapshot(updated);
  }

  /// Relance de nouveaux jets de caractéristiques et sauvegarde du résultat.
  Future<void> _onAbilityScoresRerolled(
    QuickCreateAbilityScoresRerolled event,
    Emitter<QuickCreateState> emit,
  ) async {
    if (state.abilityMode != AbilityGenerationMode.roll) {
      return;
    }
    final QuickCreateState updated = state.copyWith(
      abilityPool: _generateRolledAbilityScores(),
      abilityAssignments: _emptyAbilityAssignments(),
      statusMessage: null,
    );
    emit(updated);
    await _persistAbilityScoresSnapshot(updated);
  }

  /// Affectation d'un score à une caractéristique particulière.
  Future<void> _onAbilityAssigned(
    QuickCreateAbilityAssigned event,
    Emitter<QuickCreateState> emit,
  ) async {
    if (!QuickCreateState.abilityOrder.contains(event.ability)) {
      return;
    }
    final int? current = state.abilityAssignments[event.ability];
    if (current == event.value) {
      return;
    }

    if (event.value != null) {
      if (event.value! < AbilityScore.min || event.value! > AbilityScore.max) {
        return;
      }
      if (state.abilityMode != AbilityGenerationMode.manual) {
        final Map<int, int> poolCounts = _countValues(state.abilityPool);
        final Map<int, int> assignedCounts = _countValues(
          state.abilityAssignments.entries
              .where((MapEntry<String, int?> entry) =>
                  entry.key != event.ability && entry.value != null)
              .map((MapEntry<String, int?> entry) => entry.value!),
        );
        final int available = poolCounts[event.value!] ?? 0;
        final int used = assignedCounts[event.value!] ?? 0;
        if (used >= available) {
          return;
        }
      }
    }

    final Map<String, int?> updated =
        Map<String, int?>.from(state.abilityAssignments);
    updated[event.ability] = event.value;
    final QuickCreateState newState = state.copyWith(
      abilityAssignments: updated,
      statusMessage: null,
    );
    emit(newState);
    await _persistAbilityScoresSnapshot(newState);
  }

  /// Ajout ou suppression d'une compétence choisie.
  Future<void> _onSkillToggled(
    QuickCreateSkillToggled event,
    Emitter<QuickCreateState> emit,
  ) async {
    final int required = state.skillChoicesRequired;
    if (required == 0) {
      return;
    }
    if (!state.availableSkills.contains(event.skillId)) {
      return;
    }

    final Set<String> current = state.chosenSkills.toSet();
    if (current.contains(event.skillId)) {
      current.remove(event.skillId);
    } else {
      if (current.length >= required) {
        return;
      }
      current.add(event.skillId);
      if (!state.skillDefinitions.containsKey(event.skillId)) {
        _logger.warn(
          'Définition de compétence manquante lors de la sélection',
          payload: {'skillId': event.skillId},
        );
      }
    }

    final QuickCreateState updated = state.copyWith(chosenSkills: current);
    emit(updated);
    await _persistSkillsSnapshot(updated);
  }

  /// Basculer entre l'équipement de départ et la prise d'or initial.
  Future<void> _onUseStartingEquipmentChanged(
    QuickCreateUseStartingEquipmentChanged event,
    Emitter<QuickCreateState> emit,
  ) async {
    if (event.useStartingEquipment == state.useStartingEquipment) {
      return;
    }
    final QuickCreateState updated = state.copyWith(
      useStartingEquipment: event.useStartingEquipment,
      statusMessage: null,
    );
    emit(updated);
    await _persistEquipmentSnapshot(updated);
  }

  /// Ajuste la quantité d'un élément d'équipement choisi.
  Future<void> _onEquipmentQuantityChanged(
    QuickCreateEquipmentQuantityChanged event,
    Emitter<QuickCreateState> emit,
  ) async {
    if (!state.equipmentDefinitions.containsKey(event.equipmentId)) {
      return;
    }
    int sanitized = event.quantity;
    if (sanitized < 0) {
      sanitized = 0;
    }
    if (sanitized > 99) {
      sanitized = 99;
    }
    final Map<String, int> updated =
        Map<String, int>.from(state.chosenEquipment);
    if (sanitized == 0) {
      updated.remove(event.equipmentId);
    } else {
      updated[event.equipmentId] = sanitized;
    }
    final QuickCreateState newState = state.copyWith(
      chosenEquipment: updated,
      statusMessage: null,
    );
    emit(newState);
    await _persistEquipmentSnapshot(newState);
  }

  /// Finalise le personnage et purge le brouillon persisté.
  Future<void> _onSubmitted(
    QuickCreateSubmitted event,
    Emitter<QuickCreateState> emit,
  ) async {
    if (!state.canCreate || state.isCreating) {
      return;
    }
    final String? selectedSpecies = state.selectedSpecies;
    final String? selectedClass = state.selectedClass;
    final String? selectedBackground = state.selectedBackground;
    if (selectedSpecies == null ||
        selectedClass == null ||
        selectedBackground == null) {
      return;
    }
    if (!state.hasValidEquipmentSelection) {
      emit(
        state.copyWith(
          statusMessage: null,
          failure: AppFailure.validation(
            code: 'InvalidEquipmentSelection',
            message:
                'Veuillez vérifier vos choix d\'équipement (poids ou crédits).',
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isCreating: true,
        statusMessage: 'Création en cours…',
        completion: null,
        failure: null,
      ),
    );

    ClassDef? classDef = state.selectedClassDef;
    if (classDef == null) {
      final AppResult<QuickCreateClassDetails> fallbackDetails =
          await _loadClassDetails(selectedClass);
      classDef = await fallbackDetails.match(
        ok: (QuickCreateClassDetails details) => details.classDef,
        err: (DomainError error) {
          final AppFailure failure = AppFailure.fromDomain(error);
          _logger.error(
            'Impossible de charger les détails de la classe sélectionnée',
            error: failure,
            payload: {'classId': selectedClass},
          );
          emit(
            state.copyWith(
              isCreating: false,
              statusMessage: null,
              failure: failure,
            ),
          );
          return null;
        },
      );
      if (classDef == null) {
        return;
      }
    }

    final Set<String> chosenSkills = Set<String>.from(state.chosenSkills);

    final Map<String, int?> abilityAssignments = state.abilityAssignments;
    final Map<String, AbilityScore> baseAbilities = <String, AbilityScore>{};
    for (final String ability in QuickCreateState.abilityOrder) {
      final int? rawValue = abilityAssignments[ability];
      if (rawValue == null) {
        emit(
          state.copyWith(
            isCreating: false,
            statusMessage: null,
            failure: AppFailure.validation(
              code: 'MissingAbilityValue',
              message: 'Veuillez attribuer une valeur à chaque caractéristique.',
            ),
          ),
        );
        return;
      }
      try {
        baseAbilities[ability] = AbilityScore(rawValue);
      } on ArgumentError {
        emit(
          state.copyWith(
            isCreating: false,
            statusMessage: null,
            failure: AppFailure.validation(
              code: 'InvalidAbilityValue',
              message:
                  'Valeur invalide pour ${QuickCreateState.abilityLabels[ability] ?? ability.toUpperCase()}.',
              details: {'ability': ability, 'value': rawValue},
            ),
          ),
        );
        return;
      }
    }

    final List<ChosenEquipmentLine> chosenEquipment = <ChosenEquipmentLine>[];
    for (final MapEntry<String, int> entry in state.chosenEquipment.entries) {
      final int qty = entry.value;
      if (qty <= 0) {
        continue;
      }
      try {
        chosenEquipment.add(
          ChosenEquipmentLine(
            itemId: EquipmentItemId(entry.key),
            quantity: Quantity(qty),
          ),
        );
      } on ArgumentError {
        emit(
          state.copyWith(
            isCreating: false,
            statusMessage: null,
            failure: AppFailure.validation(
              code: 'InvalidEquipmentQuantity',
              message: 'Équipement sélectionné invalide (${entry.key}).',
              details: {'itemId': entry.key, 'quantity': qty},
            ),
          ),
        );
        return;
      }
    }

    final FinalizeLevel1Input input = FinalizeLevel1Input(
      name: CharacterName(state.characterName.trim()),
      speciesId: SpeciesId(selectedSpecies),
      classId: ClassId(selectedClass),
      backgroundId: BackgroundId(selectedBackground),
      baseAbilities: baseAbilities,
      chosenSkills: chosenSkills,
      chosenEquipment: chosenEquipment,
      useStartingEquipmentPackage: state.useStartingEquipment,
    );

    try {
      final AppResult<Character> result =
          await _finalizeLevel1Character(input);
      await result.match<Future<void>>(
        ok: (Character character) async {
          emit(
            state.copyWith(
              isCreating: false,
              statusMessage: 'OK: ${character.name.value}',
              completion: QuickCreateSuccess(character),
              failure: null,
            ),
          );
          final AppResult<void> clearResult = await _clearCharacterDraft();
          clearResult.match(
            ok: (_) => null,
            err: (DomainError error) {
              _logger.warn(
                'Impossible d\'effacer le brouillon après création',
                error: error,
              );
              return null;
            },
          );
        },
        err: (DomainError error) async {
          final AppFailure failure = AppFailure.fromDomain(error);
          emit(
            state.copyWith(
              isCreating: false,
              statusMessage: null,
              completion: QuickCreateFailure(failure),
              failure: failure,
            ),
          );
        },
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Erreur inattendue lors de la finalisation',
        error: error,
        stackTrace: stackTrace,
        payload: {
          'species': selectedSpecies,
          'class': selectedClass,
          'background': selectedBackground,
        },
      );
      emit(
        state.copyWith(
          isCreating: false,
          statusMessage: null,
          completion: null,
          failure: AppFailure.fromException(
            error,
            code: 'UnexpectedFinalizeError',
            details: {
              'species': selectedSpecies,
              'class': selectedClass,
              'background': selectedBackground,
            },
          ),
        ),
      );
    }
  }

  /// Réinitialise l'objet de complétion après affichage en UI.
  void _onCompletionCleared(
    QuickCreateCompletionCleared event,
    Emitter<QuickCreateState> emit,
  ) {
    if (state.completion != null) {
      emit(state.copyWith(completion: null));
    }
  }

  Future<void> _refreshSpeciesTraits(
    String speciesId,
    Emitter<QuickCreateState> emit,
  ) async {
    final AppResult<QuickCreateSpeciesDetails> result =
        await _loadSpeciesDetails(speciesId);

    await result.match(
      ok: (QuickCreateSpeciesDetails details) async {
        if (details.missingTraitIds.isNotEmpty) {
          _logger.warn(
            'Traits manquants pour une espèce',
            payload: {
              'speciesId': speciesId,
              'missingTraitIds': details.missingTraitIds,
            },
          );
        }
        emit(
          state.copyWith(
            selectedSpeciesTraits: details.traits,
            statusMessage: null,
            failure: null,
          ),
        );
        final AppResult<CharacterDraft> draftResult =
            await _persistCharacterDraftSpecies(details);
        draftResult.match(
          ok: (CharacterDraft draft) {
            emit(
              state.copyWith(
                selectedSpeciesEffects:
                    draft.species?.effects ?? const <CharacterEffect>[],
              ),
            );
          },
          err: (DomainError error) {
            _logger.warn(
              'Échec de la sauvegarde du brouillon d\'espèce',
              error: error,
              payload: {
                'speciesId': speciesId,
              },
            );
          },
        );
      },
      err: (DomainError error) async {
        _logger.warn(
          'Erreur lors du chargement des traits',
          error: error,
          payload: {'speciesId': speciesId},
        );
        emit(
          state.copyWith(
            statusMessage:
                'Erreur lors du chargement des traits: ${error.message ?? error.code}',
          ),
        );
      },
    );
  }

  int _sanitizeStepIndex(int? raw) {
    if (raw == null || raw.isNegative) {
      return 0;
    }
    final int maxIndex = QuickCreateStep.values.length - 1;
    if (raw > maxIndex) {
      return maxIndex;
    }
    return raw;
  }

  Future<void> _persistStepIndex(int index) async {
    final AppResult<CharacterDraft> result =
        await _persistCharacterDraftStep(index);
    result.match(
      ok: (_) => null,
      err: (DomainError error) {
        _logger.warn(
          'Échec de la sauvegarde de l\'étape courante',
          error: error,
          payload: {'stepIndex': index},
        );
        return null;
      },
    );
  }

  Future<void> _persistAbilityScoresSnapshot(QuickCreateState snapshot) async {
    final AppResult<CharacterDraft> result =
        await _persistCharacterDraftAbilityScores(
      _buildDraftAbilityScoresSnapshot(snapshot),
    );
    result.match(
      ok: (_) {},
      err: (DomainError error) {
        _logger.warn(
          'Échec de la sauvegarde des caractéristiques',
          error: error,
        );
      },
    );
  }

  Future<void> _persistSkillsSnapshot(QuickCreateState snapshot) async {
    final AppResult<CharacterDraft> result =
        await _persistCharacterDraftSkills(Set<String>.from(snapshot.chosenSkills));
    result.match(
      ok: (_) {},
      err: (DomainError error) {
        _logger.warn(
          'Échec de la sauvegarde des compétences',
          error: error,
        );
      },
    );
  }

  Future<void> _persistEquipmentSnapshot(QuickCreateState snapshot) async {
    final AppResult<CharacterDraft> result =
        await _persistCharacterDraftEquipment(
      _buildDraftEquipmentSelectionSnapshot(snapshot),
    );
    result.match(
      ok: (_) {},
      err: (DomainError error) {
        _logger.warn(
          'Échec de la sauvegarde de l\'équipement',
          error: error,
        );
      },
    );
  }

  Future<void> _refreshClassDef(
    String classId,
    Emitter<QuickCreateState> emit,
  ) async {
    final AppResult<QuickCreateClassDetails> result =
        await _loadClassDetails(classId);

    await result.match(
      ok: (QuickCreateClassDetails details) async {
        if (details.missingSkillIds.isNotEmpty) {
          _logger.warn(
            'Compétences manquantes pour la classe',
            payload: {
              'classId': classId,
              'missingSkillIds': details.missingSkillIds,
            },
          );
        }

        final Set<String> availableSet = details.availableSkillIds.toSet();
        final Set<String> retainedSelection = state.chosenSkills
            .where(availableSet.contains)
            .toSet();
        if (details.skillChoicesRequired == 0) {
          retainedSelection.clear();
        }

        emit(
          state.copyWith(
            selectedClassDef: details.classDef,
            isLoadingClassDetails: false,
            availableSkills: details.availableSkillIds,
            chosenSkills: retainedSelection,
            skillChoicesRequired: details.skillChoicesRequired,
            skillDefinitions: details.skillDefinitions,
            statusMessage: null,
            failure: null,
          ),
        );
      },
      err: (DomainError error) async {
        _logger.warn(
          'Erreur lors du chargement de la classe',
          error: error,
          payload: {'classId': classId},
        );
        emit(
          state.copyWith(
            statusMessage:
                'Erreur lors du chargement de la classe: ${error.message ?? error.code}',
            isLoadingClassDetails: false,
          ),
        );
      },
    );
  }

  List<int> _generateRolledAbilityScores() {
    final List<int> scores =
        List<int>.generate(6, (_) => _roll4d6DropLowest(_random));
    scores.sort((int a, int b) => b.compareTo(a));
    return scores;
  }

  int _roll4d6DropLowest(Random random) {
    final List<int> rolls = List<int>.generate(4, (_) => random.nextInt(6) + 1)
      ..sort();
    return rolls.sublist(1).reduce((int a, int b) => a + b);
  }

  Map<int, int> _countValues(Iterable<int> values) {
    final Map<int, int> counts = <int, int>{};
    for (final int value in values) {
      counts.update(value, (int count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

}
