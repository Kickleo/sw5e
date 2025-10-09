import 'package:equatable/equatable.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';

class SavedCharactersState extends Equatable {
  const SavedCharactersState({
    required this.isLoading,
    required this.characters,
    required this.errorMessage,
    required this.hasLoadedOnce,
  });

  factory SavedCharactersState.initial() => const SavedCharactersState(
        isLoading: false,
        characters: <Character>[],
        errorMessage: null,
        hasLoadedOnce: false,
      );

  final bool isLoading;
  final List<Character> characters;
  final String? errorMessage;
  final bool hasLoadedOnce;

  bool get hasError => errorMessage != null;
  bool get isEmpty => characters.isEmpty;

  SavedCharactersState copyWith({
    bool? isLoading,
    List<Character>? characters,
    String? errorMessage,
    bool resetError = false,
    bool? hasLoadedOnce,
  }) {
    return SavedCharactersState(
      isLoading: isLoading ?? this.isLoading,
      characters: characters ?? this.characters,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }

  @override
  List<Object?> get props => [isLoading, characters, errorMessage, hasLoadedOnce];
}
