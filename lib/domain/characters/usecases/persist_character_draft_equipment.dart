/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_equipment.dart
/// Rôle : Persister la sélection d'équipement du brouillon de personnage.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';

abstract class PersistCharacterDraftEquipment {
  Future<AppResult<CharacterDraft>> call(DraftEquipmentSelection selection);
}

