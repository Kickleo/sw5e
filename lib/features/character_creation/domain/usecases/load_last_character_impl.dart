// lib/features/character_creation/domain/usecases/load_last_character_impl.dart
import 'package:sw5e_manager/core/domain/result.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/character_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/load_last_character.dart';

class LoadLastCharacterImpl implements LoadLastCharacter {
  final CharacterRepository _repo;

  LoadLastCharacterImpl(this._repo);

  @override
  Future<Result<Character?>> call() async {
    try {
      final c = await _repo.loadLast();
      return Result.ok(c); // Ok(null) si aucun perso sauvegardé — convention
    } catch (e) {
      return Result.err(DomainError('Unexpected', message: e.toString()));
    }
  }
}
