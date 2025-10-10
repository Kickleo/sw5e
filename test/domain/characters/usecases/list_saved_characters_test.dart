/// ---------------------------------------------------------------------------
/// Fichier test : domain/characters/usecases/list_saved_characters_test.dart
/// Rôle : Vérifier le use case ListSavedCharacters (liste et erreurs).
/// Dépendances : mocktail, CharacterRepository, AppResult.
/// ---------------------------------------------------------------------------
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters_impl.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/domain/characters/value_objects/background_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_name.dart';
import 'package:sw5e_manager/domain/characters/value_objects/class_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/credits.dart';
import 'package:sw5e_manager/domain/characters/value_objects/defense.dart';
import 'package:sw5e_manager/domain/characters/value_objects/encumbrance.dart';
import 'package:sw5e_manager/domain/characters/value_objects/hit_points.dart';
import 'package:sw5e_manager/domain/characters/value_objects/initiative.dart';
import 'package:sw5e_manager/domain/characters/value_objects/level.dart';
import 'package:sw5e_manager/domain/characters/value_objects/maneuvers_known.dart';
import 'package:sw5e_manager/domain/characters/value_objects/proficiency_bonus.dart';
import 'package:sw5e_manager/domain/characters/value_objects/skill_proficiency.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/superiority_dice.dart';

class _MockCharacterRepository extends Mock implements CharacterRepository {}

Character _dummyCharacter(String id) {
  return Character(
    id: CharacterId(id),
    name: CharacterName('Dummy $id'),
    speciesId: SpeciesId('human'),
    classId: ClassId('guardian'),
    backgroundId: BackgroundId('outlaw'),
    level: Level.one,
    abilities: {
      'str': AbilityScore(10),
      'dex': AbilityScore(10),
      'con': AbilityScore(10),
      'int': AbilityScore(10),
      'wis': AbilityScore(10),
      'cha': AbilityScore(10),
    },
    skills: const <SkillProficiency>{},
    proficiencyBonus: ProficiencyBonus.fromLevel(Level.one),
    hitPoints: HitPoints(10),
    defense: Defense(10),
    initiative: Initiative(0),
    credits: Credits(0),
    inventory: const <InventoryLine>[],
    encumbrance: Encumbrance(0),
    maneuversKnown: ManeuversKnown(0),
    superiorityDice: SuperiorityDice(count: 0, die: null),
  );
}

void main() {
  late _MockCharacterRepository repository;
  late ListSavedCharacters usecase;

  setUp(() {
    repository = _MockCharacterRepository();
    usecase = ListSavedCharactersImpl(repository);
  });

  test('renvoie Ok avec les personnages sauvegardés', () async {
    final characters = [_dummyCharacter('c1'), _dummyCharacter('c2')];
    when(() => repository.listAll()).thenAnswer((_) async => characters);

    final result = await usecase();

    expect(result.isOk, isTrue);
    result.match(
      ok: (value) {
        expect(value, hasLength(2));
        expect(value.first.id.value, 'c1');
      },
      err: (error) => fail('Ne devrait pas échouer: $error'),
    );
    verify(() => repository.listAll()).called(1);
  });

  test('renvoie Err(Unexpected) quand le repository jette une exception', () async {
    when(() => repository.listAll()).thenThrow(Exception('disk I/O error'));

    final result = await usecase();

    expect(result.isErr, isTrue);
    result.match(
      ok: (_) => fail('Devrait échouer'),
      err: (error) => expect(error.code, 'Unexpected'),
    );
    verify(() => repository.listAll()).called(1);
  });
}
