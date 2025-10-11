/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/load_character_draft_impl.dart
/// Rôle : Implémenter la lecture du brouillon de personnage depuis le
///        repository de persistance.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_character_draft.dart';

/// Implémentation par défaut s'appuyant sur [CharacterDraftRepository].
class LoadCharacterDraftImpl implements LoadCharacterDraft {
  /// Crée l'use case avec le repository à interroger.
  const LoadCharacterDraftImpl(this._repository);

  final CharacterDraftRepository _repository;

  @override
  Future<AppResult<CharacterDraft?>> call() async {
    try {
      // On récupère le brouillon persistant ; `null` signifie qu'aucune reprise
      // n'est disponible pour l'utilisateur.
      final CharacterDraft? draft = await _repository.load();
      return appOk(draft);
    } catch (error, stackTrace) {
      return appErr(
        DomainError(
          'DraftLoadFailed',
          message: error.toString(),
          details: {
            'repository': _repository.runtimeType.toString(),
            'stackTrace': stackTrace.toString(),
          },
        ),
      );
    }
  }
}
