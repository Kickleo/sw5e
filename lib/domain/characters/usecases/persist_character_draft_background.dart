/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_background.dart
/// Rôle : Persister le background choisi pour le personnage en cours.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';

abstract class PersistCharacterDraftBackground {
  Future<AppResult<CharacterDraft>> call(String backgroundId);
}

