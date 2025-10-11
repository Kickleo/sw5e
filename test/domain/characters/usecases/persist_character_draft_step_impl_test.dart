/// ---------------------------------------------------------------------------
/// Fichier test : persist_character_draft_step_impl_test.dart
/// Rôle : Vérifier la persistance de l'étape courante dans le brouillon.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/data/characters/repositories/in_memory_character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_step_impl.dart';
import 'package:test/test.dart';

void main() {
  test('enregistre l\'index d\'étape dans le repository', () async {
    final repository = InMemoryCharacterDraftRepository();
    await repository.save(CharacterDraft(name: 'Test'));
    final PersistCharacterDraftStepImpl useCase =
        PersistCharacterDraftStepImpl(repository);

    final AppResult<CharacterDraft> result = await useCase(4);

    expect(result.isOk, isTrue);
    final CharacterDraft? stored = await repository.load();
    expect(stored, isNotNull);
    expect(stored!.stepIndex, 4);
  });
}
