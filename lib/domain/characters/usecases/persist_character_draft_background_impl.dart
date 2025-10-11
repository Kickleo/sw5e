/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_background_impl.dart
/// Rôle : Sauvegarder le background sélectionné dans le brouillon persistant.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_background.dart';
import 'package:sw5e_manager/domain/characters/value_objects/background_id.dart';

class PersistCharacterDraftBackgroundImpl
    implements PersistCharacterDraftBackground {
  const PersistCharacterDraftBackgroundImpl(this._repository);

  final CharacterDraftRepository _repository;

  @override
  Future<AppResult<CharacterDraft>> call(String backgroundId) async {
    try {
      // On charge l'état actuel du brouillon pour préserver les sélections
      // précédentes de l'utilisateur.
      final CharacterDraft existing = await _repository.load() ?? CharacterDraft();
      // Le background est encapsulé dans son value object dédié avant copie.
      final CharacterDraft updated =
          existing.copyWith(backgroundId: BackgroundId(backgroundId));
      await _repository.save(updated);
      return appOk(updated);
    } catch (error) {
      return appErr(
        DomainError(
          'DraftPersistenceFailed',
          message: error.toString(),
          details: const {'field': 'background'},
        ),
      );
    }
  }
}

