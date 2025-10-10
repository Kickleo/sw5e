/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/list_saved_characters.dart
/// Rôle : Définir le contrat de récupération des personnages sauvegardés.
/// Dépendances : `AppResult` (gestion d'erreurs) et entité `Character`.
/// Exemple d'usage :
///   final result = await useCase();
/// ---------------------------------------------------------------------------
library;
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';

/// ListSavedCharacters = use case renvoyant la liste des personnages persistés.
///
/// * Post-condition : retourne un [AppResult] immuable (liste non modifiable).
/// * Erreurs : mappées vers [DomainError] par l'implémentation.
abstract class ListSavedCharacters {
  Future<AppResult<List<Character>>> call();
}
