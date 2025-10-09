// lib/features/character_creation/domain/usecases/list_saved_characters_impl.dart
import 'package:sw5e_manager/core/domain/result.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/character_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/list_saved_characters.dart';

class ListSavedCharactersImpl implements ListSavedCharacters {
  final CharacterRepository _repository;

  ListSavedCharactersImpl(this._repository);

  @override
  Future<Result<List<Character>>> call() async {
    try {
      final characters = await _repository.listAll();
      return Result.ok(characters);
    } catch (e) {
      return Result.err(DomainError('Unexpected', message: e.toString()));
    }
  }
}
