/// -----------------------------------------------------------------------------
/// Fichier : test/data/characters/in_memory_character_repository_test.dart
/// Rôle : Vérifier le comportement de l'adapter InMemoryCharacterRepository.
/// Dépendances : entités/value objects domaine pour construire des personnages.
/// Exemple d'usage : exécuter `flutter test test/data/characters/...`.
/// -----------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/data/characters/repositories/in_memory_character_repository.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_repository.dart';
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

Character _dummyCharacter(String id) {
  return Character(
    id: CharacterId(id),
    name: CharacterName('Hero $id'),
    speciesId: SpeciesId('human'),
    classId: ClassId('guardian'),
    backgroundId: BackgroundId('outlaw'),
    level: Level.one,
    abilities: <String, AbilityScore>{
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
  late CharacterRepository repository;

  setUp(() {
    repository = InMemoryCharacterRepository();
  });

  test('sauvegarde et liste les personnages dans l\'ordre', () async {
    await repository.save(_dummyCharacter('c1'));
    await repository.save(_dummyCharacter('c2'));

    final characters = await repository.listAll();

    expect(characters, hasLength(2));
    expect(characters.first.id.value, 'c1');
    expect(() => characters.add(_dummyCharacter('c3')), throwsUnsupportedError);
  });

  test('remplace un personnage avec le même identifiant', () async {
    final original = _dummyCharacter('c1');
    final updated = _dummyCharacter('c1');

    await repository.save(original);
    await repository.save(updated);

    final characters = await repository.listAll();
    expect(characters, hasLength(1));
    expect(characters.single.name.value, updated.name.value);
  });

  test('loadLast renvoie le plus récent', () async {
    expect(await repository.loadLast(), isNull);

    await repository.save(_dummyCharacter('c1'));
    await repository.save(_dummyCharacter('c2'));

    final last = await repository.loadLast();
    expect(last?.id.value, 'c2');
  });

  test('loadById renvoie le personnage correspondant', () async {
    await repository.save(_dummyCharacter('c1'));
    await repository.save(_dummyCharacter('c2'));

    final found = await repository.loadById(CharacterId('c1'));
    final missing = await repository.loadById(CharacterId('unknown'));

    expect(found, isNotNull);
    expect(found!.id.value, 'c1');
    expect(missing, isNull);
  });
}
