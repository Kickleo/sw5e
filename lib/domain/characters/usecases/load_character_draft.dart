/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/load_character_draft.dart
/// Rôle : Définir le contrat d'application chargé de restituer un brouillon de
///        personnage éventuellement sauvegardé pendant la création.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';

/// Use case exposant la dernière sauvegarde partielle du personnage.
abstract class LoadCharacterDraft {
  /// Retourne le brouillon courant ou `null` si aucun n'est enregistré.
  ///
  /// * Succès : [AppResult] `Ok` contenant le brouillon (ou `null`).
  /// * Erreur : [AppResult] `Err` avec un [DomainError] en cas d'échec IO.
  Future<AppResult<CharacterDraft?>> call();
}
