/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_class_impl.dart
/// Rôle : Persister la classe sélectionnée dans le brouillon.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_class.dart';
import 'package:sw5e_manager/domain/characters/value_objects/class_id.dart';

class PersistCharacterDraftClassImpl implements PersistCharacterDraftClass {
  const PersistCharacterDraftClassImpl(this._repository);

  final CharacterDraftRepository _repository;

  @override
  Future<AppResult<CharacterDraft>> call(String classId) async {
    try {
      // On repart du brouillon actuel pour ne pas perdre les autres choix
      // effectués dans l'assistant.
      final CharacterDraft existing = await _repository.load() ?? const CharacterDraft();
      // La valeur reçue est transformée en value object `ClassId` avant
      // d'alimenter la copie immuable du brouillon.
      final CharacterDraft updated = existing.copyWith(classId: ClassId(classId));
      await _repository.save(updated);
      return appOk(updated);
    } catch (error) {
      return appErr(
        DomainError(
          'DraftPersistenceFailed',
          message: error.toString(),
          details: const {'field': 'class'},
        ),
      );
    }
  }
}

