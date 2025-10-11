/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/load_last_character.dart
/// Rôle : Définir le contrat de chargement du dernier personnage.
/// Dépendances : `AppResult` et entité `Character`.
/// Exemple d'usage :
///   final character = (await useCase()).unwrapOr(null);
/// ---------------------------------------------------------------------------
library;
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';

/// LoadLastCharacter = use case chargé de restituer le dernier personnage sauvegardé.
///
/// * Post-condition : retourne un [AppResult] contenant soit le personnage, soit `null`.
/// * Erreurs : propagées sous forme de [DomainError] via l'implémentation.
abstract class LoadLastCharacter {
  Future<AppResult<Character?>> call();
}
