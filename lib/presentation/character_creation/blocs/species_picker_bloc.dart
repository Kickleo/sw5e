/// ---------------------------------------------------------------------------
/// Fichier : lib/presentation/character_creation/blocs/species_picker_bloc.dart
/// Rôle : ViewModel BLoC responsable du chargement et de la sélection d'une
///        espèce dans l'assistant (liste, détails, traits associés).
/// Dépendances : flutter_bloc, equatable, CatalogRepository, AppLogger,
///        AppFailure.
/// Exemple d'usage :
///   final bloc = SpeciesPickerBloc(
///     catalog: catalogRepository,
///     logger: logger,
///   )..add(const SpeciesPickerStarted());
/// ---------------------------------------------------------------------------
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sw5e_manager/common/errors/app_failure.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// SpeciesPickerEvent = intentions utilisateur (initialisation, changement).
sealed class SpeciesPickerEvent extends Equatable {
  const SpeciesPickerEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// SpeciesPickerStarted = déclenché à l'ouverture de la vue (option initiale).
class SpeciesPickerStarted extends SpeciesPickerEvent {
  const SpeciesPickerStarted({this.initialSpeciesId});

  final String? initialSpeciesId;

  @override
  List<Object?> get props => <Object?>[initialSpeciesId];
}

/// SpeciesPickerSpeciesRequested = l'utilisateur sélectionne une espèce.
class SpeciesPickerSpeciesRequested extends SpeciesPickerEvent {
  const SpeciesPickerSpeciesRequested(this.speciesId);

  final String speciesId;

  @override
  List<Object?> get props => <Object?>[speciesId];
}

/// SpeciesPickerState = photographie immuable de la vue (liste, sélection, cache).
class SpeciesPickerState extends Equatable {
  const SpeciesPickerState({
    required this.isLoadingList,
    required this.isLoadingDetails,
    required this.speciesIds,
    required this.selectedSpeciesId,
    required this.selectedSpecies,
    required this.selectedTraits,
    required this.speciesDefinitions,
    required this.traitDefinitions,
    required this.failure,
    required this.hasLoadedOnce,
  });

  /// Fabrique initiale = aucune donnée chargée.
  factory SpeciesPickerState.initial() => const SpeciesPickerState(
        isLoadingList: false,
        isLoadingDetails: false,
        speciesIds: <String>[],
        selectedSpeciesId: null,
        selectedSpecies: null,
        selectedTraits: <TraitDef>[],
        speciesDefinitions: <String, SpeciesDef>{},
        traitDefinitions: <String, TraitDef>{},
        failure: null,
        hasLoadedOnce: false,
      );

  final bool isLoadingList;
  final bool isLoadingDetails;
  final List<String> speciesIds;
  final String? selectedSpeciesId;
  final SpeciesDef? selectedSpecies;
  final List<TraitDef> selectedTraits;
  final Map<String, SpeciesDef> speciesDefinitions;
  final Map<String, TraitDef> traitDefinitions;
  final AppFailure? failure;
  final bool hasLoadedOnce;

  bool get hasSelection => selectedSpeciesId != null;
  bool get hasError => failure != null;
  String? get errorMessage =>
      failure?.toDisplayMessage(includeCode: true);

  SpeciesPickerState copyWith({
    bool? isLoadingList,
    bool? isLoadingDetails,
    List<String>? speciesIds,
    String? selectedSpeciesId,
    SpeciesDef? selectedSpecies,
    List<TraitDef>? selectedTraits,
    Map<String, SpeciesDef>? speciesDefinitions,
    Map<String, TraitDef>? traitDefinitions,
    AppFailure? failure,
    bool clearFailure = false,
    bool? hasLoadedOnce,
  }) {
    return SpeciesPickerState(
      isLoadingList: isLoadingList ?? this.isLoadingList,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      speciesIds: speciesIds ?? this.speciesIds,
      selectedSpeciesId: selectedSpeciesId ?? this.selectedSpeciesId,
      selectedSpecies: selectedSpecies ?? this.selectedSpecies,
      selectedTraits: selectedTraits ?? this.selectedTraits,
      speciesDefinitions: speciesDefinitions ?? this.speciesDefinitions,
      traitDefinitions: traitDefinitions ?? this.traitDefinitions,
      failure: clearFailure ? null : (failure ?? this.failure),
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        isLoadingList,
        isLoadingDetails,
        speciesIds,
        selectedSpeciesId,
        selectedSpecies,
        selectedTraits,
        speciesDefinitions,
        traitDefinitions,
        failure,
        hasLoadedOnce,
      ];
}

/// SpeciesPickerBloc = ViewModel MVVM orchestrant les appels catalogue.
class SpeciesPickerBloc extends Bloc<SpeciesPickerEvent, SpeciesPickerState> {
  SpeciesPickerBloc({required CatalogRepository catalog, required AppLogger logger})
      : _catalog = catalog,
        _logger = logger,
        super(SpeciesPickerState.initial()) {
    on<SpeciesPickerStarted>(_onStarted);
    on<SpeciesPickerSpeciesRequested>(_onSpeciesRequested);
  }

  final CatalogRepository _catalog;
  final AppLogger _logger;

  Future<void> _onStarted(
    SpeciesPickerStarted event,
    Emitter<SpeciesPickerState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingList: true,
        isLoadingDetails: true,
        clearFailure: true,
      ),
    );

    try {
      final List<String> ids = await _catalog.listSpecies();
      final String? targetId =
          event.initialSpeciesId ?? (ids.isNotEmpty ? ids.first : null);

      if (targetId == null) {
        emit(
          state.copyWith(
            isLoadingList: false,
            isLoadingDetails: false,
            speciesIds: ids,
            selectedSpeciesId: null,
          selectedSpecies: null,
          selectedTraits: const <TraitDef>[],
          clearFailure: true,
          hasLoadedOnce: true,
        ),
      );
      return;
    }

      final _SpeciesSelection selection = await _loadSpeciesDetails(
        targetId,
        existingSpecies: state.speciesDefinitions,
        existingTraits: state.traitDefinitions,
      );

      emit(
        state.copyWith(
          isLoadingList: false,
          isLoadingDetails: false,
          speciesIds: ids,
          selectedSpeciesId: targetId,
          selectedSpecies: selection.species,
          selectedTraits: selection.traits,
          speciesDefinitions: selection.speciesDefinitions,
          traitDefinitions: selection.traitDefinitions,
          clearFailure: true,
          hasLoadedOnce: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.error(
        'SpeciesPickerBloc: échec du chargement initial',
        error: error,
        stackTrace: stackTrace,
        payload: <String, Object?>{'initialSpeciesId': event.initialSpeciesId},
      );
      emit(
        state.copyWith(
          isLoadingList: false,
          isLoadingDetails: false,
          failure: AppFailure.storage(
            code: 'SpeciesListLoadFailed',
            message: 'Échec du chargement des espèces : $error',
            details: <String, Object?>{'initialSpeciesId': event.initialSpeciesId},
          ),
          hasLoadedOnce: true,
        ),
      );
    }
  }

  Future<void> _onSpeciesRequested(
    SpeciesPickerSpeciesRequested event,
    Emitter<SpeciesPickerState> emit,
  ) async {
    if (event.speciesId == state.selectedSpeciesId && state.selectedSpecies != null) {
      return; // Rien à faire si déjà sélectionné.
    }

    emit(
      state.copyWith(
        isLoadingDetails: true,
        selectedSpeciesId: event.speciesId,
        clearFailure: true,
      ),
    );

    try {
      final _SpeciesSelection selection = await _loadSpeciesDetails(
        event.speciesId,
        existingSpecies: state.speciesDefinitions,
        existingTraits: state.traitDefinitions,
      );

      emit(
        state.copyWith(
          isLoadingDetails: false,
          selectedSpecies: selection.species,
          selectedTraits: selection.traits,
          speciesDefinitions: selection.speciesDefinitions,
          traitDefinitions: selection.traitDefinitions,
          clearFailure: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.warn(
        'SpeciesPickerBloc: échec chargement détails',
        error: error,
        stackTrace: stackTrace,
        payload: <String, Object?>{'speciesId': event.speciesId},
      );
      emit(
        state.copyWith(
          isLoadingDetails: false,
          failure: AppFailure.storage(
            code: 'SpeciesSelectionFailed',
            message: 'Erreur lors de la sélection de l\'espèce : $error',
            details: <String, Object?>{'speciesId': event.speciesId},
          ),
        ),
      );
    }
  }

  Future<_SpeciesSelection> _loadSpeciesDetails(
    String speciesId, {
    required Map<String, SpeciesDef> existingSpecies,
    required Map<String, TraitDef> existingTraits,
  }) async {
    SpeciesDef? species = existingSpecies[speciesId];
    final Map<String, SpeciesDef> speciesDefinitions = Map<String, SpeciesDef>.from(
      existingSpecies,
    );

    if (species == null) {
      species = await _catalog.getSpecies(speciesId);
      if (species != null) {
        speciesDefinitions[speciesId] = species;
      }
    }

    if (species == null) {
      return _SpeciesSelection(
        species: null,
        traits: const <TraitDef>[],
        speciesDefinitions: speciesDefinitions,
        traitDefinitions: existingTraits,
      );
    }

    final Map<String, TraitDef> traitDefinitions = Map<String, TraitDef>.from(
      existingTraits,
    );
    final List<TraitDef> traits = <TraitDef>[];

    for (final String traitId in species.traitIds) {
      TraitDef? trait = traitDefinitions[traitId];
      if (trait == null) {
        trait = await _catalog.getTrait(traitId);
        if (trait != null) {
          traitDefinitions[traitId] = trait;
        }
      }
      if (trait != null) {
        traits.add(trait);
      }
    }

    return _SpeciesSelection(
      species: species,
      traits: traits,
      speciesDefinitions: speciesDefinitions,
      traitDefinitions: traitDefinitions,
    );
  }
}

/// _SpeciesSelection = structure interne pour retourner sélection + caches mis à jour.
class _SpeciesSelection {
  const _SpeciesSelection({
    required this.species,
    required this.traits,
    required this.speciesDefinitions,
    required this.traitDefinitions,
  });

  final SpeciesDef? species;
  final List<TraitDef> traits;
  final Map<String, SpeciesDef> speciesDefinitions;
  final Map<String, TraitDef> traitDefinitions;
}
