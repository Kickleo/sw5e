/// ---------------------------------------------------------------------------
/// Fichier test : character_test.dart
/// Rôle : Vérifier les invariants d'instanciation de l'entité [Character].
/// ---------------------------------------------------------------------------
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/domain/characters/value_objects/background_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_name.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_trait.dart';
import 'package:sw5e_manager/domain/characters/value_objects/class_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/credits.dart';
import 'package:sw5e_manager/domain/characters/value_objects/defense.dart';
import 'package:sw5e_manager/domain/characters/value_objects/encumbrance.dart';
import 'package:sw5e_manager/domain/characters/value_objects/equipment_item_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/hit_points.dart';
import 'package:sw5e_manager/domain/characters/value_objects/initiative.dart';
import 'package:sw5e_manager/domain/characters/value_objects/level.dart';
import 'package:sw5e_manager/domain/characters/value_objects/maneuvers_known.dart';
import 'package:sw5e_manager/domain/characters/value_objects/proficiency_bonus.dart';
import 'package:sw5e_manager/domain/characters/value_objects/quantity.dart';
import 'package:sw5e_manager/domain/characters/value_objects/skill_proficiency.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/superiority_dice.dart';
import 'package:sw5e_manager/domain/characters/value_objects/trait_id.dart';

void main() {
  group('Character', () {
    test("s'instancie lorsque tous les invariants sont respectés", () {
      final Character character = Character(
        id: CharacterId('hero-1'),
        name: CharacterName('Luke Skywalker'),
        speciesId: SpeciesId('human'),
        classId: ClassId('guardian'),
        backgroundId: BackgroundId('pilot'),
        level: Level.one,
        abilities: <String, AbilityScore>{
          'str': AbilityScore(12),
          'dex': AbilityScore(14),
          'con': AbilityScore(13),
          'int': AbilityScore(10),
          'wis': AbilityScore(12),
          'cha': AbilityScore(15),
        },
        skills: <SkillProficiency>{
          SkillProficiency(
            skillId: 'piloting',
            state: ProficiencyState.proficient,
            sources: const <ProficiencySource>{ProficiencySource.classSource},
          ),
        },
        proficiencyBonus: ProficiencyBonus.fromLevel(Level.one),
        hitPoints: HitPoints(12),
        defense: Defense(15),
        initiative: Initiative(3),
        credits: Credits(150),
        inventory: <InventoryLine>[
          InventoryLine(
            itemId: EquipmentItemId('lightsaber-training-remote'),
            quantity: Quantity(1),
          ),
        ],
        encumbrance: Encumbrance(1200),
        maneuversKnown: ManeuversKnown(0),
        superiorityDice: SuperiorityDice(count: 0),
        speciesTraits: <CharacterTrait>{
          CharacterTrait(id: TraitId('keen-senses')),
        },
      );

      expect(character.id.value, equals('hero-1'));
      expect(character.abilities['cha']?.modifier, equals(2));
    });

    test('rejette un niveau différent de 1 (MVP)', () {
      expect(
        () => Character(
          id: CharacterId('hero-2'),
          name: CharacterName('Test'),
          speciesId: SpeciesId('human'),
          classId: ClassId('guardian'),
          backgroundId: BackgroundId('pilot'),
          level: Level(2),
          abilities: _validAbilities(),
          skills: _validSkills(),
          proficiencyBonus: ProficiencyBonus.fromLevel(Level(2)),
          hitPoints: HitPoints(12),
          defense: Defense(15),
          initiative: Initiative(2),
          credits: Credits(10),
          inventory: _validInventory(),
          encumbrance: Encumbrance(1000),
          maneuversKnown: ManeuversKnown(0),
          superiorityDice: SuperiorityDice(count: 0),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejette une carte de caractéristiques incomplète', () {
      expect(
        () => Character(
          id: CharacterId('hero-3'),
          name: CharacterName('Test'),
          speciesId: SpeciesId('human'),
          classId: ClassId('guardian'),
          backgroundId: BackgroundId('pilot'),
          level: Level.one,
          abilities: <String, AbilityScore>{
            'str': AbilityScore(10),
            'dex': AbilityScore(10),
            'con': AbilityScore(10),
            'int': AbilityScore(10),
            'wis': AbilityScore(10),
            // 'cha' manquant
          },
          skills: _validSkills(),
          proficiencyBonus: ProficiencyBonus.fromLevel(Level.one),
          hitPoints: HitPoints(10),
          defense: Defense(12),
          initiative: Initiative(1),
          credits: Credits(10),
          inventory: _validInventory(),
          encumbrance: Encumbrance(500),
          maneuversKnown: ManeuversKnown(0),
          superiorityDice: SuperiorityDice(count: 0),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test("rejette une ligne d'inventaire avec quantité nulle", () {
      expect(
        () => Character(
          id: CharacterId('hero-4'),
          name: CharacterName('Test'),
          speciesId: SpeciesId('human'),
          classId: ClassId('guardian'),
          backgroundId: BackgroundId('pilot'),
          level: Level.one,
          abilities: _validAbilities(),
          skills: _validSkills(),
          proficiencyBonus: ProficiencyBonus.fromLevel(Level.one),
          hitPoints: HitPoints(10),
          defense: Defense(12),
          initiative: Initiative(1),
          credits: Credits(10),
          inventory: <InventoryLine>[
            InventoryLine(
              itemId: EquipmentItemId('training-saber'),
              quantity: Quantity(0),
            ),
          ],
          encumbrance: Encumbrance(200),
          maneuversKnown: ManeuversKnown(0),
          superiorityDice: SuperiorityDice(count: 0),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

Map<String, AbilityScore> _validAbilities() => <String, AbilityScore>{
      'str': AbilityScore(10),
      'dex': AbilityScore(10),
      'con': AbilityScore(10),
      'int': AbilityScore(10),
      'wis': AbilityScore(10),
      'cha': AbilityScore(10),
    };

Set<SkillProficiency> _validSkills() => <SkillProficiency>{
      SkillProficiency(
        skillId: 'piloting',
        state: ProficiencyState.proficient,
        sources: const <ProficiencySource>{ProficiencySource.classSource},
      ),
    };

List<InventoryLine> _validInventory() => <InventoryLine>[
      InventoryLine(
        itemId: EquipmentItemId('training-saber'),
        quantity: Quantity(1),
      ),
    ];
