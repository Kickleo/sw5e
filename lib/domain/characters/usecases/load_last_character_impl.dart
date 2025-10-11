/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/load_last_character_impl.dart
/// Rôle : Implémenter le chargement du dernier personnage via le repository.
/// Dépendances : `CharacterRepository`, `AppResult`.
/// Exemple d'usage :
///   final result = await LoadLastCharacterImpl(repo)();
/// ---------------------------------------------------------------------------
library;
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_last_character.dart';

/// Implémentation orchestrant la récupération via [CharacterRepository].
///
/// * Erreurs : convertit les exceptions génériques en [DomainError] `Unexpected`.
class LoadLastCharacterImpl implements LoadLastCharacter {
  final CharacterRepository _repo;

  LoadLastCharacterImpl(this._repo);

  @override
  Future<AppResult<Character?>> call() async {
    try {
      final c = await _repo.loadLast();
      return appOk(c); // Ok(null) si aucun perso sauvegardé — convention
    } catch (e) {
      return appErr(DomainError('Unexpected', message: e.toString()));
    }
  }
}
