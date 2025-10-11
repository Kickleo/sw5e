/// ---------------------------------------------------------------------------
/// Fichier test : clear_character_draft_impl_test.dart
/// Rôle : Vérifier l'effacement du brouillon via l'use case dédié.
/// ---------------------------------------------------------------------------
library;

import 'package:test/test.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/data/characters/repositories/in_memory_character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/usecases/clear_character_draft_impl.dart';

void main() {
  test('supprime le brouillon persisté', () async {
    final repository = InMemoryCharacterDraftRepository();
    await repository.save(const CharacterDraft(name: 'Drafted'));
    final ClearCharacterDraftImpl useCase =
        ClearCharacterDraftImpl(repository);

    final AppResult<void> result = await useCase();

    expect(result.isOk, isTrue);
    final CharacterDraft? stored = await repository.load();
    expect(stored, isNull);
  });
}
