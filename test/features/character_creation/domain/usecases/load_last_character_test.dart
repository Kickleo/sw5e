import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/character_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/load_last_character.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/load_last_character_impl.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/ability_score.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/background_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_name.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/class_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/credits.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/defense.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/encumbrance.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/equipment_item_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/hit_points.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/initiative.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/level.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/maneuvers_known.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/proficiency_bonus.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/quantity.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/skill_proficiency.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/species_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/superiority_dice.dart';

class _MockCharacterRepository extends Mock implements CharacterRepository {}

Character _dummyCharacter() {
  return Character(
    name: CharacterName('Dummy'),
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
    inventory: <InventoryLine>[
      InventoryLine(itemId: EquipmentItemId('blaster-pistol'), quantity: Quantity(1)),
    ],
    encumbrance: Encumbrance(800),
    maneuversKnown: ManeuversKnown(0),
    superiorityDice: SuperiorityDice(count: 0, die: null),
  );
}

void main() {
  late _MockCharacterRepository repo;
  late LoadLastCharacter usecase;

  setUp(() {
    repo = _MockCharacterRepository();
    usecase = LoadLastCharacterImpl(repo);
  });

  test('renvoie Ok(null) quand aucun personnage n’est sauvegardé', () async {
    when(() => repo.loadLast()).thenAnswer((_) async => null);

    final res = await usecase();

    expect(res.isOk, isTrue);
    res.match(
      ok: (c) => expect(c, isNull),
      err: (e) => fail('Ne devrait pas échouer: $e'),
    );
    verify(() => repo.loadLast()).called(1);
  });

  test('renvoie Ok(Character) quand un personnage est présent', () async {
    final dummy = _dummyCharacter();
    when(() => repo.loadLast()).thenAnswer((_) async => dummy);

    final res = await usecase();

    expect(res.isOk, isTrue);
    res.match(
      ok: (c) {
        expect(c, isNotNull);
        expect(c!.name.value, 'Dummy');
      },
      err: (e) => fail('Ne devrait pas échouer: $e'),
    );
    verify(() => repo.loadLast()).called(1);
  });

  test('renvoie Err(Unexpected) si le repository lève une exception', () async {
    when(() => repo.loadLast()).thenThrow(Exception('disk I/O failed'));

    final res = await usecase();

    expect(res.isErr, isTrue);
    res.match(
      ok: (_) => fail('Devrait échouer'),
      err: (e) => expect(e.code, 'Unexpected'),
    );
    verify(() => repo.loadLast()).called(1);
  });
}
