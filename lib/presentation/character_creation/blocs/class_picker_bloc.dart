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
    required this.selectedClassId,
    required this.selectedClass,
    required this.skillDefinitions,
    required this.equipmentDefinitions,
    required this.failure,
    required this.hasLoadedOnce,
  });

  /// Fabrique initiale = aucune donnée chargée.
  factory ClassPickerState.initial() => const ClassPickerState(
        isLoadingList: false,
        isLoadingDetails: false,
        classIds: <String>[],
        selectedClassId: null,
        selectedClass: null,
        skillDefinitions: <String, SkillDef>{},
        equipmentDefinitions: <String, EquipmentDef>{},
        failure: null,
        hasLoadedOnce: false,
      );

  final bool isLoadingList;
  final bool isLoadingDetails;
  final List<String> classIds;
  final String? selectedClassId;
  final ClassDef? selectedClass;
  final Map<String, SkillDef> skillDefinitions;
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
    String? selectedClassId,
    ClassDef? selectedClass,
    Map<String, SkillDef>? skillDefinitions,
    Map<String, EquipmentDef>? equipmentDefinitions,
    AppFailure? failure,
    bool clearFailure = false,
    bool? hasLoadedOnce,
  }) {
    return ClassPickerState(
      isLoadingList: isLoadingList ?? this.isLoadingList,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      classIds: classIds ?? this.classIds,
      selectedClassId: selectedClassId ?? this.selectedClassId,
      selectedClass: selectedClass ?? this.selectedClass,
      skillDefinitions: skillDefinitions ?? this.skillDefinitions,
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
        selectedClassId,
        selectedClass,
        skillDefinitions,
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
        existingSkills: state.skillDefinitions,
        existingEquipment: state.equipmentDefinitions,
      );

      emit(
        state.copyWith(
          isLoadingList: false,
          isLoadingDetails: false,
          classIds: List<String>.unmodifiable(ids),
          selectedClassId: targetId,
          selectedClass: selection.classDef,
          skillDefinitions: selection.skillDefinitions,
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
        existingSkills: state.skillDefinitions,
        existingEquipment: state.equipmentDefinitions,
      );

      emit(
        state.copyWith(
          isLoadingDetails: false,
          selectedClass: selection.classDef,
          skillDefinitions: selection.skillDefinitions,
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
    required Map<String, SkillDef> existingSkills,
    required Map<String, EquipmentDef> existingEquipment,
  }) async {
    final ClassDef? classDef = await _catalog.getClass(classId);
    if (classDef == null) {
      throw StateError('Classe "$classId" introuvable');
    }

    final Map<String, SkillDef> skillDefs = Map<String, SkillDef>.from(existingSkills);
    final Map<String, EquipmentDef> equipmentDefs =
        Map<String, EquipmentDef>.from(existingEquipment);

    final Iterable<String> skillIds = classDef.level1.proficiencies.skillsFrom;
    for (final String skillId in skillIds) {
      if (skillId == 'any') continue;
      if (skillDefs.containsKey(skillId)) continue;
      final SkillDef? def = await _catalog.getSkill(skillId);
      if (def != null) {
        skillDefs[skillId] = def;
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
      skillDefinitions: Map<String, SkillDef>.unmodifiable(skillDefs),
      equipmentDefinitions: Map<String, EquipmentDef>.unmodifiable(equipmentDefs),
    );
  }
}

/// _SelectionResult = structure interne pour transporter la sélection + caches.
class _SelectionResult {
  const _SelectionResult({
    required this.classDef,
    required this.skillDefinitions,
    required this.equipmentDefinitions,
  });

  final ClassDef classDef;
  final Map<String, SkillDef> skillDefinitions;
  final Map<String, EquipmentDef> equipmentDefinitions;
}
