import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sw5e_manager/di/character_creation_module.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_id.dart';

final characterSummaryViewModelProvider =
    StateNotifierProvider.autoDispose<CharacterSummaryViewModel, CharacterSummaryState>((ref) {
  return CharacterSummaryViewModel(ref)
    ..refresh();
});

class CharacterSummaryState {
  final AsyncValue<List<Character>> characters;
  final CharacterId? selectedId;
  final bool isSharing;

  const CharacterSummaryState({
    required this.characters,
    required this.selectedId,
    required this.isSharing,
  });

  factory CharacterSummaryState.initial() => const CharacterSummaryState(
        characters: AsyncValue.loading(),
        selectedId: null,
        isSharing: false,
      );

  CharacterSummaryState copyWith({
    AsyncValue<List<Character>>? characters,
    CharacterId? selectedId,
    bool? isSharing,
  }) {
    return CharacterSummaryState(
      characters: characters ?? this.characters,
      selectedId: selectedId ?? this.selectedId,
      isSharing: isSharing ?? this.isSharing,
    );
  }

  Character? get selectedCharacter {
    final data = characters.asData?.value;
    if (data == null || data.isEmpty) return null;
    final id = selectedId;
    if (id == null) return data.last;
    return data.firstWhere(
      (c) => c.id == id,
      orElse: () => data.last,
    );
  }
}

class CharacterSummaryViewModel extends StateNotifier<CharacterSummaryState> {
  CharacterSummaryViewModel(this._ref) : super(CharacterSummaryState.initial());

  final Ref _ref;

  ListSavedCharacters get _listSavedCharacters => _ref.read(listSavedCharactersProvider);

  Future<void> refresh() async {
    state = state.copyWith(characters: const AsyncValue.loading());
    final result = await _listSavedCharacters();
    result.match(
      ok: (characters) {
        final selectedId = characters.isEmpty
            ? null
            : state.selectedId != null &&
                    characters.any((character) => character.id == state.selectedId)
                ? state.selectedId
                : characters.last.id;
        state = state.copyWith(
          characters: AsyncValue.data(characters),
          selectedId: selectedId,
        );
      },
      err: (error) {
        state = state.copyWith(
          characters: AsyncValue.error(error, StackTrace.current),
        );
      },
    );
  }

  void selectCharacter(CharacterId id) {
    if (id == state.selectedId) return;
    state = state.copyWith(selectedId: id);
  }

  Future<void> shareSelectedCharacter() async {
    final character = state.selectedCharacter;
    if (character == null || state.isSharing) return;
    state = state.copyWith(isSharing: true);
    final buffer = StringBuffer()
      ..writeln('Nom : ${character.name.value}')
      ..writeln('Espèce : ${character.speciesId.value}')
      ..writeln('Classe : ${character.classId.value}')
      ..writeln('Historique : ${character.backgroundId.value}')
      ..writeln('PV : ${character.hitPoints.value}')
      ..writeln('Défense : ${character.defense.value}')
      ..writeln('Initiative : ${character.initiative.value}')
      ..writeln('Crédits : ${character.credits.value}')
      ..writeln('Compétences : ${character.skills.map((s) => s.skillId).join(', ')}')
      ..writeln('Inventaire : ${character.inventory.map((l) => "${l.itemId.value} x${l.quantity.value}").join(', ')}');
    await Share.share(buffer.toString(), subject: 'Personnage SW5e : ${character.name.value}');
    state = state.copyWith(isSharing: false);
  }
}
