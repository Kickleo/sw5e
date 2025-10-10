/// ---------------------------------------------------------------------------
/// Fichier : lib/presentation/character_creation/blocs/saved_characters_bloc.dart
/// Rôle : ViewModel BLoC orchestrant le chargement/refraîchissement de la liste
///        de personnages sauvegardés pour la vue dédiée.
/// Dépendances : flutter_bloc pour la gestion d'état réactive, use case
///        ListSavedCharacters (couche domaine), AppResult/AppFailure pour mapper
///        les erreurs.
/// Exemple d'usage :
///   final bloc = SavedCharactersBloc(listSavedCharacters: useCase)..add(
///     const SavedCharactersRequested(),
///   );
///   bloc.stream.listen((state) => print(state.characters.length));
/// ---------------------------------------------------------------------------
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sw5e_manager/common/errors/app_failure.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters.dart';

/// SavedCharactersEvent = message utilisateur/ système demandant un nouvel
/// état BLoC (définition) ; chaque event est immuable et comparable.
sealed class SavedCharactersEvent extends Equatable {
  const SavedCharactersEvent();

  @override
  List<Object?> get props => const [];
}

/// SavedCharactersRequested = demande initiale/ explicite de chargement.
class SavedCharactersRequested extends SavedCharactersEvent {
  /// force=true bypass la protection "déjà en cours" pour permettre refresh.
  const SavedCharactersRequested({this.force = false});

  final bool force;

  @override
  List<Object?> get props => <Object?>[force];
}

/// SavedCharactersRefreshRequested = intention UI "pull to refresh".
class SavedCharactersRefreshRequested extends SavedCharactersEvent {
  const SavedCharactersRefreshRequested();
}

/// SavedCharactersState = photographie immuable de la vue (définition).
class SavedCharactersState extends Equatable {
  const SavedCharactersState({
    required this.isLoading,
    required this.characters,
    required this.failure,
    required this.hasLoadedOnce,
  });

  /// Fabrique initiale = rien n'a encore été chargé.
  factory SavedCharactersState.initial() => const SavedCharactersState(
        isLoading: false,
        characters: <Character>[],
        failure: null,
        hasLoadedOnce: false,
      );

  final bool isLoading;
  final List<Character> characters;
  final AppFailure? failure;
  final bool hasLoadedOnce;

  bool get hasError => failure != null;
  String? get errorMessage =>
      failure?.toDisplayMessage(includeCode: true);
  bool get isEmpty => characters.isEmpty;

  /// copyWith = création d'une nouvelle version avec champs modifiés.
  SavedCharactersState copyWith({
    bool? isLoading,
    List<Character>? characters,
    AppFailure? failure,
    bool clearFailure = false,
    bool? hasLoadedOnce,
  }) {
    return SavedCharactersState(
      isLoading: isLoading ?? this.isLoading,
      characters: characters ?? this.characters,
      failure: clearFailure ? null : (failure ?? this.failure),
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        isLoading,
        characters,
        failure,
        hasLoadedOnce,
      ];
}

/// SavedCharactersBloc = ViewModel MVVM basé BLoC ; orchestre use case domaine.
class SavedCharactersBloc
    extends Bloc<SavedCharactersEvent, SavedCharactersState> {
  SavedCharactersBloc({required ListSavedCharacters listSavedCharacters})
      : _listSavedCharacters = listSavedCharacters,
        super(SavedCharactersState.initial()) {
    on<SavedCharactersRequested>(_onRequested);
    on<SavedCharactersRefreshRequested>(_onRefreshed);
  }

  final ListSavedCharacters _listSavedCharacters;

  Future<void> _onRequested(
    SavedCharactersRequested event,
    Emitter<SavedCharactersState> emit,
  ) async {
    if (state.isLoading && !event.force) {
      return;
    }

    emit(state.copyWith(isLoading: true, clearFailure: true));

    final AppResult<List<Character>> result = await _listSavedCharacters();

    result.match(
      ok: (List<Character> characters) {
        emit(
          state.copyWith(
            isLoading: false,
            characters: List<Character>.unmodifiable(characters),
            clearFailure: true,
            hasLoadedOnce: true,
          ),
        );
      },
      err: (DomainError error) {
        emit(
          state.copyWith(
            isLoading: false,
            failure: AppFailure.fromDomain(error),
            hasLoadedOnce: true,
          ),
        );
      },
    );
  }

  Future<void> _onRefreshed(
    SavedCharactersRefreshRequested event,
    Emitter<SavedCharactersState> emit,
  ) async {
    emit(state.copyWith(clearFailure: true));
    add(const SavedCharactersRequested(force: true));
  }
}
