/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_skills_impl.dart
/// Rôle : Sauvegarder les compétences choisies.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_skills.dart';

class PersistCharacterDraftSkillsImpl implements PersistCharacterDraftSkills {
  const PersistCharacterDraftSkillsImpl(this._repository);

  final CharacterDraftRepository _repository;

  @override
  Future<AppResult<CharacterDraft>> call(Set<String> skillIds) async {
    try {
      final CharacterDraft existing = await _repository.load() ?? const CharacterDraft();
      final CharacterDraft updated =
          existing.copyWith(chosenSkills: Set<String>.from(skillIds));
      await _repository.save(updated);
      return appOk(updated);
    } catch (error) {
      return appErr(
        DomainError(
          'DraftPersistenceFailed',
          message: error.toString(),
          details: const {'field': 'skills'},
        ),
      );
    }
  }
}

