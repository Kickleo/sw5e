/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_skills.dart
/// Rôle : Persister les compétences sélectionnées dans le brouillon.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';

abstract class PersistCharacterDraftSkills {
  Future<AppResult<CharacterDraft>> call(Set<String> skillIds);
}

