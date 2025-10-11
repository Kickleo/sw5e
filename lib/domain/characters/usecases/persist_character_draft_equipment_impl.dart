/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_equipment_impl.dart
/// Rôle : Sauvegarder le choix d'équipement (pack + quantités) du brouillon.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_equipment.dart';

class PersistCharacterDraftEquipmentImpl
    implements PersistCharacterDraftEquipment {
  const PersistCharacterDraftEquipmentImpl(this._repository);

  final CharacterDraftRepository _repository;

  @override
  Future<AppResult<CharacterDraft>> call(
    DraftEquipmentSelection selection,
  ) async {
    try {
      // On récupère le brouillon existant afin de préserver les autres choix.
      final CharacterDraft existing = await _repository.load() ?? const CharacterDraft();
      // L'instantané d'équipement est immuable et peut être stocké directement.
      final CharacterDraft updated = existing.copyWith(equipment: selection);
      await _repository.save(updated);
      return appOk(updated);
    } catch (error) {
      return appErr(
        DomainError(
          'DraftPersistenceFailed',
          message: error.toString(),
          details: const {'field': 'equipment'},
        ),
      );
    }
  }
}

