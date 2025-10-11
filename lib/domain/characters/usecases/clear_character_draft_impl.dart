/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/clear_character_draft_impl.dart
/// Rôle : Implémentation de la suppression du brouillon persistant.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/clear_character_draft.dart';

class ClearCharacterDraftImpl implements ClearCharacterDraft {
  const ClearCharacterDraftImpl(this._repository);

  final CharacterDraftRepository _repository;

  @override
  Future<AppResult<void>> call() async {
    try {
      // On délègue l'effacement au repository, qu'il soit mémoire ou disque.
      await _repository.clear();
      return appOk(null);
    } catch (error) {
      return appErr(
        DomainError(
          'DraftClearFailed',
          message: error.toString(),
          details: {'repository': _repository.runtimeType.toString()},
        ),
      );
    }
  }
}
