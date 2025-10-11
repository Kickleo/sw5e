/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_step.dart
/// Rôle : Contrat de sauvegarde de l'étape courante du brouillon de personnage.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';

abstract class PersistCharacterDraftStep {
  Future<AppResult<CharacterDraft>> call(int stepIndex);
}
