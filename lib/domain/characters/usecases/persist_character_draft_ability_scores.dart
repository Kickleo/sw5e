/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_ability_scores.dart
/// Rôle : Persister le mode et les affectations de caractéristiques.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';

abstract class PersistCharacterDraftAbilityScores {
  Future<AppResult<CharacterDraft>> call(DraftAbilityScores scores);
}

