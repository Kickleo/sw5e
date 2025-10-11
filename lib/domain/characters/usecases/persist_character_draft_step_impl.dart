/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_step_impl.dart
/// Rôle : Implémentation de la sauvegarde de l'étape courante du brouillon.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_step.dart';

class PersistCharacterDraftStepImpl implements PersistCharacterDraftStep {
  const PersistCharacterDraftStepImpl(this._repository);

  final CharacterDraftRepository _repository;

  @override
  Future<AppResult<CharacterDraft>> call(int stepIndex) async {
    try {
      // Charger le brouillon existant permet de conserver toutes les saisies.
      final CharacterDraft existing = await _repository.load() ?? CharacterDraft();
      // Seul l'indice d'étape est mis à jour dans la copie immuable.
      final CharacterDraft updated = existing.copyWith(stepIndex: stepIndex);
      await _repository.save(updated);
      return appOk(updated);
    } catch (error) {
      return appErr(
        DomainError(
          'DraftPersistenceFailed',
          message: error.toString(),
          details: {'field': 'stepIndex', 'value': stepIndex},
        ),
      );
    }
  }
}
