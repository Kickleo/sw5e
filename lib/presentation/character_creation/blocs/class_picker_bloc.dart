/// ---------------------------------------------------------------------------
/// Fichier : lib/presentation/character_creation/blocs/class_picker_bloc.dart
/// Rôle : ViewModel BLoC dédié à la sélection d'une classe dans l'assistant
///        (chargement de la liste, détails, caches associés).
/// Dépendances : flutter_bloc, equatable, CatalogRepository, AppLogger,
///        AppFailure.
/// Exemple d'usage :
///   final bloc = ClassPickerBloc(
///     catalog: catalogRepository,
///     logger: logger,
///   )..add(const ClassPickerStarted());
/// ---------------------------------------------------------------------------
library;
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sw5e_manager/common/errors/app_failure.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// ClassPickerEvent = intentions utilisateur (charger, sélectionner).
sealed class ClassPickerEvent extends Equatable {
  const ClassPickerEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// ClassPickerStarted = déclenché à l'ouverture de la vue (option initiale).
class ClassPickerStarted extends ClassPickerEvent {
  const ClassPickerStarted({this.initialClassId});

  final String? initialClassId;

  @override
  List<Object?> get props => <Object?>[initialClassId];
}

/// ClassPickerClassRequested = l'utilisateur sélectionne une classe.
class ClassPickerClassRequested extends ClassPickerEvent {
  const ClassPickerClassRequested(this.classId);

  final String classId;

  @override
  List<Object?> get props => <Object?>[classId];
}

/// ClassPickerState = photographie immuable de la vue (liste, sélection, caches).
class ClassPickerState extends Equatable {
  const ClassPickerState({
    required this.isLoadingList,
    required this.isLoadingDetails,
    required this.classIds,
    required this.classDefinitions,
    required this.selectedClassId,
    required this.selectedClass,
    required this.skillDefinitions,
    required this.abilityDefinitions,
    required this.equipmentDefinitions,
    required this.failure,
    required this.hasLoadedOnce,
  });

  /// Fabrique initiale = aucune donnée chargée.
  factory ClassPickerState.initial() => const ClassPickerState(
        isLoadingList: false,
        isLoadingDetails: false,
        classIds: <String>[],
        classDefinitions: <String, ClassDef>{},
        selectedClassId: null,
        selectedClass: null,
        skillDefinitions: <String, SkillDef>{},
        abilityDefinitions: <String, AbilityDef>{},
        equipmentDefinitions: <String, EquipmentDef>{},
        failure: null,
        hasLoadedOnce: false,
      );

  final bool isLoadingList;
  final bool isLoadingDetails;
  final List<String> classIds;
  final Map<String, ClassDef> classDefinitions;
  final String? selectedClassId;
  final ClassDef? selectedClass;
  final Map<String, SkillDef> skillDefinitions;
  final Map<String, AbilityDef> abilityDefinitions;
  final Map<String, EquipmentDef> equipmentDefinitions;
  final AppFailure? failure;
  final bool hasLoadedOnce;

  bool get hasSelection => selectedClassId != null;
  bool get hasError => failure != null;
  String? get errorMessage =>
      failure?.toDisplayMessage(includeCode: true);

  ClassPickerState copyWith({
    bool? isLoadingList,
    bool? isLoadingDetails,
    List<String>? classIds,
    Map<String, ClassDef>? classDefinitions,
    String? selectedClassId,
    ClassDef? selectedClass,
    Map<String, SkillDef>? skillDefinitions,
    Map<String, AbilityDef>? abilityDefinitions,
    Map<String, EquipmentDef>? equipmentDefinitions,
    AppFailure? failure,
    bool clearFailure = false,
    bool? hasLoadedOnce,
  }) {
    return ClassPickerState(
      isLoadingList: isLoadingList ?? this.isLoadingList,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      classIds: classIds ?? this.classIds,
      classDefinitions: classDefinitions ?? this.classDefinitions,
      selectedClassId: selectedClassId ?? this.selectedClassId,
      selectedClass: selectedClass ?? this.selectedClass,
      skillDefinitions: skillDefinitions ?? this.skillDefinitions,
      abilityDefinitions: abilityDefinitions ?? this.abilityDefinitions,
      equipmentDefinitions:
          equipmentDefinitions ?? this.equipmentDefinitions,
      failure: clearFailure ? null : (failure ?? this.failure),
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        isLoadingList,
        isLoadingDetails,
        classIds,
        classDefinitions,
        selectedClassId,
        selectedClass,
        skillDefinitions,
        abilityDefinitions,
        equipmentDefinitions,
        failure,
        hasLoadedOnce,
      ];
}

/// ClassPickerBloc = ViewModel MVVM orchestrant les appels catalogue.
class ClassPickerBloc extends Bloc<ClassPickerEvent, ClassPickerState> {
  ClassPickerBloc({required CatalogRepository catalog, required AppLogger logger})
      : _catalog = catalog,
        _logger = logger,
        super(ClassPickerState.initial()) {
    on<ClassPickerStarted>(_onStarted);
    on<ClassPickerClassRequested>(_onClassRequested);
  }

  final CatalogRepository _catalog;
  final AppLogger _logger;

  Future<void> _onStarted(
    ClassPickerStarted event,
    Emitter<ClassPickerState> emit,
  ) async {
    emit(
        state.copyWith(
          isLoadingList: true,
          isLoadingDetails: true,
          clearFailure: true,
        ),
      );

    try {
      final List<String> ids = await _catalog.listClasses();
      final String? targetId =
          event.initialClassId ?? (ids.isNotEmpty ? ids.first : null);

      if (targetId == null) {
        emit(
          state.copyWith(
            isLoadingList: false,
            isLoadingDetails: false,
            classIds: List<String>.unmodifiable(ids),
            selectedClassId: null,
            selectedClass: null,
            hasLoadedOnce: true,
          ),
        );
        return;
      }

      final _SelectionResult selection = await _loadSelection(
        targetId,
        existingClasses: state.classDefinitions,
        existingSkills: state.skillDefinitions,
        existingAbilities: state.abilityDefinitions,
        existingEquipment: state.equipmentDefinitions,
      );

      final Map<String, ClassDef> classDefinitions =
          Map<String, ClassDef>.from(selection.classDefinitions);
      for (final String id in ids) {
        if (classDefinitions.containsKey(id)) {
          continue;
        }
        final ClassDef? def = await _catalog.getClass(id);
        if (def != null) {
          classDefinitions[id] = def;
        }
      }

      emit(
        state.copyWith(
          isLoadingList: false,
          isLoadingDetails: false,
          classIds: List<String>.unmodifiable(ids),
          classDefinitions: Map<String, ClassDef>.unmodifiable(classDefinitions),
          selectedClassId: targetId,
          selectedClass: selection.classDef,
          skillDefinitions: selection.skillDefinitions,
          abilityDefinitions: selection.abilityDefinitions,
          equipmentDefinitions: selection.equipmentDefinitions,
          clearFailure: true,
          hasLoadedOnce: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.error(
        'ClassPickerBloc.start failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          isLoadingList: false,
          isLoadingDetails: false,
          failure: AppFailure.storage(
            code: 'ClassListLoadFailed',
            message: 'Échec du chargement des classes : $error',
          ),
          hasLoadedOnce: true,
        ),
      );
    }
  }

  Future<void> _onClassRequested(
    ClassPickerClassRequested event,
    Emitter<ClassPickerState> emit,
  ) async {
    if (event.classId == state.selectedClassId && state.selectedClass != null) {
      return;
    }

    emit(
      state.copyWith(
        selectedClassId: event.classId,
        selectedClass: null,
        isLoadingDetails: true,
        clearFailure: true,
      ),
    );

    try {
      final _SelectionResult selection = await _loadSelection(
        event.classId,
        existingClasses: state.classDefinitions,
        existingSkills: state.skillDefinitions,
        existingAbilities: state.abilityDefinitions,
        existingEquipment: state.equipmentDefinitions,
      );

      emit(
        state.copyWith(
          isLoadingDetails: false,
          selectedClass: selection.classDef,
          classDefinitions:
              Map<String, ClassDef>.unmodifiable(selection.classDefinitions),
          skillDefinitions: selection.skillDefinitions,
          abilityDefinitions: selection.abilityDefinitions,
          equipmentDefinitions: selection.equipmentDefinitions,
          clearFailure: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.error(
        'ClassPickerBloc.select failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          isLoadingDetails: false,
          failure: AppFailure.storage(
            code: 'ClassSelectionFailed',
            message: 'Échec du chargement de la classe : $error',
            details: {'classId': event.classId},
          ),
        ),
      );
    }
  }

  Future<_SelectionResult> _loadSelection(
    String classId, {
    required Map<String, ClassDef> existingClasses,
    required Map<String, SkillDef> existingSkills,
    required Map<String, AbilityDef> existingAbilities,
    required Map<String, EquipmentDef> existingEquipment,
  }) async {
    final Map<String, ClassDef> classDefs = Map<String, ClassDef>.from(existingClasses);
    ClassDef? classDef = classDefs[classId];
    if (classDef == null) {
      classDef = await _catalog.getClass(classId);
      if (classDef != null) {
        classDefs[classId] = classDef;
      }
    }

    if (classDef == null) {
      throw StateError('Classe "$classId" introuvable');
    }

    final Map<String, SkillDef> skillDefs = Map<String, SkillDef>.from(existingSkills);
    final Map<String, AbilityDef> abilityDefs =
        Map<String, AbilityDef>.from(existingAbilities);
    final Map<String, EquipmentDef> equipmentDefs =
        Map<String, EquipmentDef>.from(existingEquipment);

    final Iterable<String> skillIds = classDef.level1.proficiencies.skillsFrom;
    for (final String skillId in skillIds) {
      if (skillId == 'any') continue;
      SkillDef? def = skillDefs[skillId];
      def ??= await _catalog.getSkill(skillId);
      if (def != null) {
        skillDefs[skillId] = def;
        final String abilitySlug = def.ability;
        if (!abilityDefs.containsKey(abilitySlug)) {
          final AbilityDef? ability = await _catalog.getAbility(abilitySlug);
          if (ability != null) {
            abilityDefs[abilitySlug] = ability;
          }
        }
      }
    }

    final Set<String> extraAbilitySlugs = <String>{
      ...classDef.primaryAbilities,
      ...classDef.savingThrows,
      ...?classDef.multiclassing?.abilityRequirements.keys,
    };
    for (final String slug in extraAbilitySlugs) {
      if (abilityDefs.containsKey(slug)) {
        continue;
      }
      final AbilityDef? ability = await _catalog.getAbility(slug);
      if (ability != null) {
        abilityDefs[slug] = ability;
      }
    }

    final Iterable<String> equipmentIds =
        classDef.level1.startingEquipment.map((StartingEquipmentLine line) => line.id);
    for (final String equipmentId in equipmentIds) {
      if (equipmentDefs.containsKey(equipmentId)) continue;
      final EquipmentDef? def = await _catalog.getEquipment(equipmentId);
      if (def != null) {
        equipmentDefs[equipmentId] = def;
      }
    }

    return _SelectionResult(
      classDef: classDef,
      classDefinitions: Map<String, ClassDef>.unmodifiable(classDefs),
      skillDefinitions: Map<String, SkillDef>.unmodifiable(skillDefs),
      abilityDefinitions: Map<String, AbilityDef>.unmodifiable(abilityDefs),
      equipmentDefinitions: Map<String, EquipmentDef>.unmodifiable(equipmentDefs),
    );
  }
}

/// _SelectionResult = structure interne pour transporter la sélection + caches.
class _SelectionResult {
  const _SelectionResult({
    required this.classDef,
    required this.classDefinitions,
    required this.skillDefinitions,
    required this.abilityDefinitions,
    required this.equipmentDefinitions,
  });

  final ClassDef classDef;
  final Map<String, ClassDef> classDefinitions;
  final Map<String, SkillDef> skillDefinitions;
  final Map<String, AbilityDef> abilityDefinitions;
  final Map<String, EquipmentDef> equipmentDefinitions;
}
