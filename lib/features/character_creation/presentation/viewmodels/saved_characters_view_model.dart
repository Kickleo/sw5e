import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw5e_manager/core/domain/result.dart';
import 'package:sw5e_manager/di/character_creation_module.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/features/character_creation/presentation/viewmodels/saved_characters_state.dart';

final savedCharactersViewModelProvider =
    StateNotifierProvider.autoDispose<SavedCharactersViewModel, SavedCharactersState>((ref) {
  final viewModel = SavedCharactersViewModel(ref);
  viewModel.loadSavedCharacters();
  return viewModel;
});

class SavedCharactersViewModel extends StateNotifier<SavedCharactersState> {
  SavedCharactersViewModel(this._ref) : super(SavedCharactersState.initial());

  final Ref _ref;

  ListSavedCharacters get _listSavedCharacters =>
      _ref.read(listSavedCharactersProvider);

  Future<void> loadSavedCharacters() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      resetError: true,
    );

    final Result<List<Character>> result = await _listSavedCharacters();

    result.match(
      ok: (characters) {
        state = state.copyWith(
          isLoading: false,
          characters: List<Character>.unmodifiable(characters),
          resetError: true,
          hasLoadedOnce: true,
        );
      },
      err: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              '${error.code}${error.message != null ? ' — ${error.message}' : ''}',
          hasLoadedOnce: true,
        );
      },
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(resetError: true);
    await loadSavedCharacters();
  }
}
