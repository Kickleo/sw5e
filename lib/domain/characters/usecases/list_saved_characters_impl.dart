/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/list_saved_characters_impl.dart
/// Rôle : Réaliser la récupération des personnages en s'appuyant sur le repository.
/// Dépendances : `CharacterRepository`, `AppResult`.
/// Exemple d'usage :
///   final result = await ListSavedCharactersImpl(repo)();
/// ---------------------------------------------------------------------------
library;
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters.dart';

/// Implémentation standard basée sur [CharacterRepository].
///
/// * Pré-condition : le repository ne doit pas retourner de liste mutable.
/// * Erreurs : toute exception est convertie en [DomainError] générique.
class ListSavedCharactersImpl implements ListSavedCharacters {
  final CharacterRepository
      _repository; // Source de vérité pour les personnages persistés.

  ListSavedCharactersImpl(this._repository);

  @override
  Future<AppResult<List<Character>>> call() async {
    try {
      final characters = await _repository.listAll();
      return appOk(characters); // Propage la liste telle quelle (déjà immuable).
    } catch (e) {
      return appErr(
          DomainError('Unexpected', message: e.toString())); // Wrappe toute erreur inattendue.
    }
  }
}
