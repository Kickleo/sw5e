/// -----------------------------------------------------------------------------
/// Fichier : test/data/characters/persistent_character_repository_test.dart
/// Rôle : Vérifier la persistance disque de `PersistentCharacterRepository`.
/// Dépendances : `dart:io` pour le dossier temporaire, entités domaine.
/// Exemple d'usage : exécuter `flutter test test/data/characters/...`.
/// -----------------------------------------------------------------------------
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/data/characters/repositories/persistent_character_repository.dart';
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
  late Directory tempDir;
  late CharacterRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('characters_repo_test');
    repository = PersistentCharacterRepository(
      directoryProvider: () async => tempDir,
      fileName: 'characters_test.json',
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('sauvegarde et lit depuis le disque', () async {
    await repository.save(_dummyCharacter('c1'));
    await repository.save(_dummyCharacter('c2'));

    final List<Character> characters = await repository.listAll();

    expect(characters, hasLength(2));
    expect(characters.first.id.value, 'c1');
  });

  test('persiste après recréation de l\'adapter', () async {
    await repository.save(_dummyCharacter('c1'));

    repository = PersistentCharacterRepository(
      directoryProvider: () async => tempDir,
      fileName: 'characters_test.json',
    );

    final Character? recovered = await repository.loadLast();

    expect(recovered, isNotNull);
    expect(recovered!.id.value, 'c1');
  });

  test('loadById retrouve un personnage existant', () async {
    final Character saved = _dummyCharacter('c42');
    await repository.save(saved);

    final Character? found = await repository.loadById(saved.id);

    expect(found, isNotNull);
    expect(found!.name.value, saved.name.value);
  });

  test('save remplace un personnage avec le même identifiant', () async {
    final Character original = _dummyCharacter('dup');
    await repository.save(original);

    final Character updated = Character(
      id: original.id,
      name: CharacterName('Hero updated'),
      speciesId: original.speciesId,
      classId: original.classId,
      backgroundId: original.backgroundId,
      level: original.level,
      abilities: original.abilities,
      skills: original.skills,
      proficiencyBonus: original.proficiencyBonus,
      hitPoints: original.hitPoints,
      defense: original.defense,
      initiative: original.initiative,
      credits: original.credits,
      inventory: original.inventory,
      encumbrance: original.encumbrance,
      maneuversKnown: original.maneuversKnown,
      superiorityDice: original.superiorityDice,
    );

    await repository.save(updated);

    final Character? recovered = await repository.loadById(original.id);

    expect(recovered, isNotNull);
    expect(recovered!.name.value, 'Hero updated');
  });
}
