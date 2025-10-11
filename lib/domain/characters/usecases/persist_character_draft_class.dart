/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_class.dart
/// Rôle : Enregistrer la classe sélectionnée dans le brouillon de personnage.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';

abstract class PersistCharacterDraftClass {
  Future<AppResult<CharacterDraft>> call(String classId);
}

