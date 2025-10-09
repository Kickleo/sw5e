// test/features/character_creation/domain/usecases/finalize_level1_character_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/character_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/finalize_level1_character_impl.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/ability_score.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/background_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_name.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/class_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/credits.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/defense.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/encumbrance.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/hit_points.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/initiative.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/level.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/maneuvers_known.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/proficiency_bonus.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/skill_proficiency.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/species_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/superiority_dice.dart';


// 👇 On référencera une implémentation concrète à créer ensuite.
class MockCatalogRepository extends Mock implements CatalogRepository {}
class MockCharacterRepository extends Mock implements CharacterRepository {}

Character _dummyCharacter() {
  return Character(
    id: CharacterId('dummy'),
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
    skills: const {},
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
  setUpAll(() {
    // 👇 indispensable pour any<Character>()
    registerFallbackValue(_dummyCharacter());
  });
  group('FinalizeLevel1Character (happy path)', () {
    late MockCatalogRepository catalog;
    late MockCharacterRepository chars;

    // ⚠️ On utilisera "FinalizeLevel1CharacterImpl" à l’étape suivante.
    late FinalizeLevel1Character usecase;

    setUp(() {
      catalog = MockCatalogRepository();
      chars = MockCharacterRepository();
      usecase = FinalizeLevel1CharacterImpl(catalog: catalog, characters: chars);

      // 👉 À l’étape suivante, on créera cette classe concrète :
      // usecase = FinalizeLevel1CharacterImpl(catalog: catalog, characters: chars);
    });

    test('produit un Character prêt à jouer (level 1, Guardian, Outlaw)', () async {
      // ARRANGE — Mocks du catalogue (cohérents avec tes assets JSON)
      when(() => catalog.getRulesVersion()).thenAnswer((_) async => '2025-10-06');

      when(() => catalog.getSpecies('human')).thenAnswer((_) async => const SpeciesDef(
            id: 'human',
            name: LocalizedText(en: 'Human', fr: 'Humain'),
            speed: 30,
            size: 'medium',
          ));

      when(() => catalog.getClass('guardian')).thenAnswer((_) async => const ClassDef(
            id: 'guardian',
            name: LocalizedText(en: 'Guardian', fr: 'Gardien'),
            hitDie: 10,
            level1: ClassLevel1Data(
              proficiencies: ClassLevel1Proficiencies(
                skillsChoose: 2,
                skillsFrom: ['athletics', 'perception', 'stealth', 'deception'],
              ),
              startingCredits: 150,
              startingEquipment: [StartingEquipmentLine(id: 'blaster-pistol', qty: 1)],
            ),
          ));

      when(() => catalog.getBackground('outlaw')).thenAnswer((_) async => const BackgroundDef(
            id: 'outlaw',
            name: LocalizedText(en: 'Outlaw', fr: 'Hors-la-loi'),
            grantedSkills: ['stealth', 'deception'],
          ));

      // Skills référencés
      when(() => catalog.getSkill(any())).thenAnswer((invocation) async {
        final id = invocation.positionalArguments.first as String;
        // On mappe chaque skill à son ability attendue
        switch (id) {
          case 'perception':
            return const SkillDef(id: 'perception', ability: 'wis');
          case 'athletics':
            return const SkillDef(id: 'athletics', ability: 'str');
          case 'stealth':
            return const SkillDef(id: 'stealth', ability: 'dex');
          case 'deception':
            return const SkillDef(id: 'deception', ability: 'cha');
        }
        return null;
      });

      // Équipement de départ
      when(() => catalog.getEquipment('blaster-pistol')).thenAnswer((_) async => const EquipmentDef(
            id: 'blaster-pistol',
            name: LocalizedText(en: 'Blaster Pistol', fr: 'Pistolet blaster'),
            type: 'weapon',
            weightG: 800,
            cost: 200,
          ));

      // Formules de base (au MVP on ne parse pas les strings; on applique une règle simple)
      when(() => catalog.getFormulas()).thenAnswer((_) async => const FormulasDef(
            rulesVersion: '2025-10-06',
            hpLevel1: 'max(hit_die) + mod(CON)',
            defenseBase: '10 + mod(DEX)', // interprétation MVP
            initiative: 'mod(DEX)',
            superiorityDiceByClass: {
              'guardian': SuperiorityDiceRule(count: 0, die: null),
            },
          ));

      // Persistance : on s’assure que save() est bien appelé
      when(() => chars.save(any())).thenAnswer((_) async {});
      when(() => chars.loadLast()).thenAnswer((_) async => null);

      // INPUT — On crée l’input DTO avec des valeurs simples
      final input = FinalizeLevel1Input(
        name: CharacterName('Rey'),
        speciesId: SpeciesId('human'),
        classId: ClassId('guardian'),
        backgroundId: BackgroundId('outlaw'),
        baseAbilities: {
          'str': AbilityScore(10),
          'dex': AbilityScore(12), // mod +1
          'con': AbilityScore(14), // mod +2
          'int': AbilityScore(10),
          'wis': AbilityScore(10),
          'cha': AbilityScore(10),
        },
        chosenSkills: {'athletics', 'perception'}, // 2 depuis la classe
        chosenEquipment: const <ChosenEquipmentLine>[], // rien de plus que le pack de départ
      );

      // ACT — Appel du use 
      final result = await usecase(input);
      expect(result.isOk, isTrue, reason: 'Le use case devrait réussir (happy path).');

      final character = result.match(
        ok: (c) => c,
        err: (e) => fail('Unexpected error: $e'),
      );

      // Identité & niveau
      expect(character.name.value, 'Rey');
      expect(character.level.value, 1);
      expect(character.classId.value, 'guardian');
      expect(character.speciesId.value, 'human');
      expect(character.backgroundId.value, 'outlaw');

      // Dérivés attendus (MVP)
      expect(character.proficiencyBonus.value, 2); // level 1
      expect(character.hitPoints.value, 12);       // d10 + mod CON (+2) = 12
      expect(character.initiative.value, 1);       // mod DEX +1
      expect(character.defense.value, 11);         // 10 + mod DEX +1 (sans armure/bouclier)

      // Économie & inventaire
      expect(character.credits.value, 150);        // crédits de départ (équipement pack = gratuit)
      expect(character.inventory.length, 1);
      expect(character.inventory.first.itemId.value, 'blaster-pistol');
      expect(character.inventory.first.quantity.value, 1);
      expect(character.encumbrance.grams, 800);    // 800g

      // Manœuvres (guardian: none au level 1 ici)
      expect(character.maneuversKnown.value, 0);
      expect(character.superiorityDice.count, 0);
      expect(character.superiorityDice.die, isNull);

      // Compétences (2 de classe choisies + 2 de background)
      expect(character.skills.length, 4);
      bool has(String id, ProficiencySource src) =>
          character.skills.any((s) => s.skillId == id && s.state == ProficiencyState.proficient && s.sources.contains(src));
      expect(has('athletics', ProficiencySource.classSource), isTrue);
      expect(has('perception', ProficiencySource.classSource), isTrue);
      expect(has('stealth', ProficiencySource.background), isTrue);
      expect(has('deception', ProficiencySource.background), isTrue);

      // Persistance
      verify(() => chars.save(any())).called(1);
    });

    test('échoue si les compétences choisies ne respectent pas les règles (InvalidPrerequisite)', () async {
      // ARRANGE (réutilise les mêmes mocks que le happy path)
      when(() => catalog.getRulesVersion()).thenAnswer((_) async => '2025-10-06');

      when(() => catalog.getSpecies('human')).thenAnswer((_) async => const SpeciesDef(
            id: 'human',
            name: LocalizedText(en: 'Human', fr: 'Humain'),
            speed: 30,
            size: 'medium',
          ));

      when(() => catalog.getClass('guardian')).thenAnswer((_) async => const ClassDef(
            id: 'guardian',
            name: LocalizedText(en: 'Guardian', fr: 'Gardien'),
            hitDie: 10,
            level1: ClassLevel1Data(
              proficiencies: ClassLevel1Proficiencies(
                skillsChoose: 2,
                skillsFrom: ['athletics', 'perception', 'stealth', 'deception'],
              ),
              startingCredits: 150,
              startingEquipment: [StartingEquipmentLine(id: 'blaster-pistol', qty: 1)],
            ),
          ));

      when(() => catalog.getBackground('outlaw')).thenAnswer((_) async => const BackgroundDef(
            id: 'outlaw',
            name: LocalizedText(en: 'Outlaw', fr: 'Hors-la-loi'),
            grantedSkills: ['stealth', 'deception'],
          ));

      when(() => catalog.getFormulas()).thenAnswer((_) async => const FormulasDef(
            rulesVersion: '2025-10-06',
            hpLevel1: 'max(hit_die) + mod(CON)',
            defenseBase: '10 + mod(DEX)',
            initiative: 'mod(DEX)',
            superiorityDiceByClass: {
              'guardian': SuperiorityDiceRule(count: 0, die: null),
            },
          ));

      // On ne stub PAS chars.save : on veut vérifier qu'il n'est pas appelé.

      // INPUT avec un choix invalide (ex: "arcana" qui n'est pas dans skillsFrom)
      final input = FinalizeLevel1Input(
        name: CharacterName('Rey'),
        speciesId: SpeciesId('human'),
        classId: ClassId('guardian'),
        backgroundId: BackgroundId('outlaw'),
        baseAbilities: {
          'str': AbilityScore(10),
          'dex': AbilityScore(12),
          'con': AbilityScore(14),
          'int': AbilityScore(10),
          'wis': AbilityScore(10),
          'cha': AbilityScore(10),
        },
        chosenSkills: {'athletics', 'arcana'}, // <- "arcana" hors liste autorisée
        chosenEquipment: const [],
      );

      // ACT
      final result = await usecase(input);

      // ASSERT
      expect(result.isErr, isTrue);
      result.match(
        ok: (_) => fail('Devrait échouer'),
        err: (e) {
          expect(e.code, 'InvalidPrerequisite');
          expect(e.details['expectedChoose'], 2);
        },
      );
      // Et on confirme qu'aucune sauvegarde n'a eu lieu
      verifyNever(() => chars.save(any()));
    });

    test('échoue si speciesId est inconnu (UnknownCatalogId) et ne sauvegarde pas', () async {
      // On ne stub que ce qui est nécessaire pour provoquer l’erreur tôt.
      when(() => catalog.getSpecies('unknown-species'))
          .thenAnswer((_) async => null); // espèce introuvable

      final input = FinalizeLevel1Input(
        name: CharacterName('Rey'),
        speciesId: SpeciesId('unknown-species'),
        classId: ClassId('guardian'),
        backgroundId: BackgroundId('outlaw'),
        baseAbilities: {
          'str': AbilityScore(10),
          'dex': AbilityScore(12),
          'con': AbilityScore(14),
          'int': AbilityScore(10),
          'wis': AbilityScore(10),
          'cha': AbilityScore(10),
        },
        chosenSkills: const {'athletics', 'perception'},
        chosenEquipment: const [],
      );

      final result = await usecase(input);

      expect(result.isErr, isTrue);
      result.match(
        ok: (_) => fail('Devrait échouer'),
        err: (e) {
          expect(e.code, 'UnknownCatalogId');
          expect(e.details['id'], 'unknown-species');
        },
      );

      // La persistance ne doit pas être appelée
      verifyNever(() => chars.save(any()));
    });

    test('échoue si les caractéristiques ne contiennent pas les 6 clés (InvalidAbilities)', () async {
      // Mocks minimum pour passer les étapes précédant la validation
      when(() => catalog.getSpecies('human')).thenAnswer((_) async => const SpeciesDef(
            id: 'human',
            name: LocalizedText(en: 'Human', fr: 'Humain'),
            speed: 30,
            size: 'medium',
          ));

      when(() => catalog.getClass('guardian')).thenAnswer((_) async => const ClassDef(
            id: 'guardian',
            name: LocalizedText(en: 'Guardian', fr: 'Gardien'),
            hitDie: 10,
            level1: ClassLevel1Data(
              proficiencies: ClassLevel1Proficiencies(
                skillsChoose: 2,
                skillsFrom: ['athletics', 'perception', 'stealth', 'deception'],
              ),
              startingCredits: 150,
              startingEquipment: [StartingEquipmentLine(id: 'blaster-pistol', qty: 1)],
            ),
          ));

      when(() => catalog.getBackground('outlaw')).thenAnswer((_) async => const BackgroundDef(
            id: 'outlaw',
            name: LocalizedText(en: 'Outlaw', fr: 'Hors-la-loi'),
            grantedSkills: ['stealth', 'deception'],
          ));

      when(() => catalog.getFormulas()).thenAnswer((_) async => const FormulasDef(
            rulesVersion: '2025-10-06',
            hpLevel1: 'max(hit_die) + mod(CON)',
            defenseBase: '10 + mod(DEX)',
            initiative: 'mod(DEX)',
            superiorityDiceByClass: {
              'guardian': SuperiorityDiceRule(count: 0, die: null),
            },
          ));

      final input = FinalizeLevel1Input(
        name: CharacterName('Rey'),
        speciesId: SpeciesId('human'),
        classId: ClassId('guardian'),
        backgroundId: BackgroundId('outlaw'),
        // ❌ volontairement INCOMPLET (manque 'cha')
        baseAbilities: {
          'str': AbilityScore(10),
          'dex': AbilityScore(12),
          'con': AbilityScore(14),
          'int': AbilityScore(10),
          'wis': AbilityScore(10),
          // 'cha' manquant
        },
        chosenSkills: const {'athletics', 'perception'},
        chosenEquipment: const [],
      );

      final result = await usecase(input);

      expect(result.isErr, isTrue);
      result.match(
        ok: (_) => fail('Devrait échouer'),
        err: (e) => expect(e.code, 'InvalidAbilities'),
      );

      verifyNever(() => chars.save(any()));
    });

  });
}
