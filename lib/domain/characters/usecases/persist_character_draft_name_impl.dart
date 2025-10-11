/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_name_impl.dart
/// Rôle : Implémenter la sauvegarde du nom du brouillon dans le repository.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_name.dart';

class PersistCharacterDraftNameImpl implements PersistCharacterDraftName {
  const PersistCharacterDraftNameImpl(this._repository);

  final CharacterDraftRepository _repository;

  @override
  Future<AppResult<CharacterDraft>> call(String name) async {
    try {
      // On récupère le brouillon existant (ou un brouillon vide) pour conserver
      // les autres informations déjà saisies par l'utilisateur.
      final CharacterDraft existing = await _repository.load() ?? CharacterDraft();
      // Seul le nom est modifié : la copie immuable protège les autres champs.
      final CharacterDraft updated = existing.copyWith(name: name);
      await _repository.save(updated);
      return appOk(updated);
    } catch (error) {
      return appErr(
        DomainError(
          'DraftPersistenceFailed',
          message: error.toString(),
          details: const {'field': 'name'},
        ),
      );
    }
  }
}

