/// ---------------------------------------------------------------------------
/// Fichier test : load_character_draft_impl_test.dart
/// Rôle : Vérifier que le use case de chargement des brouillons récupère bien
///        la sauvegarde existante et gère les erreurs d'IO.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/data/characters/repositories/in_memory_character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_character_draft_impl.dart';
import 'package:sw5e_manager/domain/characters/value_objects/background_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';
import 'package:sw5e_manager/domain/characters/value_objects/class_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';
import 'package:test/test.dart';

void main() {
  group('LoadCharacterDraftImpl', () {
    test('retourne le brouillon sauvegardé', () async {
      final InMemoryCharacterDraftRepository repository =
          InMemoryCharacterDraftRepository();
      final CharacterDraft expectedDraft = CharacterDraft(
        name: 'Lando',
        species: DraftSpeciesSelection(
          speciesId: SpeciesId('bith'),
          displayName: 'Bith',
          effects: const <CharacterEffect>[],
        ),
        classId: ClassId('consular'),
        backgroundId: BackgroundId('scholar'),
        abilityScores: DraftAbilityScores(
          mode: DraftAbilityGenerationMode.standardArray,
          assignments: const <String, int?>{
            'str': 15,
            'dex': 14,
            'con': 13,
            'int': 12,
            'wis': 10,
            'cha': 8,
          },
          pool: const <int>[15, 14, 13, 12, 10, 8],
        ),
        chosenSkills: const <String>{'lore'},
        equipment: DraftEquipmentSelection(
          useStartingEquipment: false,
          quantities: const <String, int>{'holocron': 1},
        ),
      );
      await repository.save(expectedDraft);

      final LoadCharacterDraftImpl useCase = LoadCharacterDraftImpl(repository);

      final AppResult<CharacterDraft?> result = await useCase();
      expect(result.isOk, isTrue);
      result.match(
        ok: (CharacterDraft? draft) {
          expect(draft, isNotNull);
          expect(draft!.name, 'Lando');
          expect(draft.species!.speciesId.value, 'bith');
          expect(draft.classId?.value, 'consular');
          expect(draft.backgroundId?.value, 'scholar');
          expect(draft.abilityScores?.mode,
              DraftAbilityGenerationMode.standardArray);
          expect(draft.chosenSkills, contains('lore'));
          expect(draft.equipment?.quantities['holocron'], 1);
        },
        err: (DomainError error) => fail('Unexpected error: $error'),
      );
    });

    test('renvoie une erreur si le repository lève une exception', () async {
      final _ThrowingCharacterDraftRepository repository =
          _ThrowingCharacterDraftRepository();
      final LoadCharacterDraftImpl useCase = LoadCharacterDraftImpl(repository);

      final AppResult<CharacterDraft?> result = await useCase();
      expect(result.isErr, isTrue);
      result.match(
        ok: (_) => fail('Expected an error'),
        err: (DomainError error) {
          expect(error.code, 'DraftLoadFailed');
        },
      );
    });
  });
}

class _ThrowingCharacterDraftRepository implements CharacterDraftRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<CharacterDraft?> load() async => throw StateError('disk failure');

  @override
  Future<void> save(CharacterDraft draft) async {}
}
