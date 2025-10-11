/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_ability_scores_impl.dart
/// Rôle : Sauvegarder les caractéristiques en cours d'attribution.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_ability_scores.dart';

class PersistCharacterDraftAbilityScoresImpl
    implements PersistCharacterDraftAbilityScores {
  const PersistCharacterDraftAbilityScoresImpl(this._repository);

  final CharacterDraftRepository _repository;

  @override
  Future<AppResult<CharacterDraft>> call(DraftAbilityScores scores) async {
    try {
      // L'état existant sert de base afin de conserver espèce, classe, etc.
      final CharacterDraft existing = await _repository.load() ?? const CharacterDraft();
      // Les caractéristiques étant déjà immuables, on peut réutiliser l'instance
      // fournie directement dans la copie du brouillon.
      final CharacterDraft updated = existing.copyWith(abilityScores: scores);
      await _repository.save(updated);
      return appOk(updated);
    } catch (error) {
      return appErr(
        DomainError(
          'DraftPersistenceFailed',
          message: error.toString(),
          details: const {'field': 'abilityScores'},
        ),
      );
    }
  }
}

