/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_name.dart
/// Rôle : Contrat de persistance du nom du personnage en cours de création.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';

/// Enregistre le nom saisi dans le brouillon courant.
abstract class PersistCharacterDraftName {
  Future<AppResult<CharacterDraft>> call(String name);
}

