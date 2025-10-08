// test/features/character_creation/domain/usecases/finalize_level1_character_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/core/domain/result.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/character_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/ability_score.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/background_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_name.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/class_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/species_id.dart';

// 👇 On référencera une implémentation concrète à créer ensuite.
class MockCatalogRepository extends Mock implements CatalogRepository {}
class MockCharacterRepository extends Mock implements CharacterRepository {}

void main() {
  group('FinalizeLevel1Character (happy path)', () {
    late MockCatalogRepository catalog;
    late MockCharacterRepository chars;

    // ⚠️ On utilisera "FinalizeLevel1CharacterImpl" à l’étape suivante.
    late FinalizeLevel1Character usecase;

    setUp(() {
      catalog = MockCatalogRepository();
      chars = MockCharacterRepository();

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

      // ACT — Appel du use case
      // ⚠️ Cette ligne échouera tant que l’implémentation concrète n’existe pas :
      // usecase = FinalizeLevel1CharacterImpl(catalog: catalog, characters: chars);
      // final result = await usecase(input);

      // ⛳ Pour avancer par étapes, on force un faux "result" ici — décommente les lignes ci-dessus
      // quand tu auras créé l'implémentation, et supprime ce bloc fictif.
      final Result<Character> result = Result.err(
        const DomainError('TODO', message: 'Implémente FinalizeLevel1CharacterImpl'),
      );

      // ASSERT — On attend un Ok<Character> (quand l’impl sera faite)
      expect(result.isOk, isTrue, reason: 'Le use case devrait réussir (happy path).');

      // --- Les assertions suivantes devront passer quand l’implémentation sera prête.
      // final character = result.match(
      //   ok: (c) => c,
      //   err: (e) => fail('Unexpected error: $e'),
      // );

      // // Identité & niveau
      // expect(character.name.value, 'Rey');
      // expect(character.level.value, 1);
      // expect(character.classId.value, 'guardian');
      // expect(character.speciesId.value, 'human');
      // expect(character.backgroundId.value, 'outlaw');

      // // Dérivés attendus (MVP)
      // expect(character.proficiencyBonus.value, 2); // level 1
      // expect(character.hitPoints.value, 12);       // d10 + mod CON (+2) = 12
      // expect(character.initiative.value, 1);       // mod DEX +1
      // expect(character.defense.value, 11);         // 10 + mod DEX +1 (sans armure/bouclier)

      // // Économie & inventaire
      // expect(character.credits.value, 150);        // crédits de départ (équipement pack = gratuit)
      // expect(character.inventory.length, 1);
      // expect(character.inventory.first.itemId.value, 'blaster-pistol');
      // expect(character.inventory.first.quantity.value, 1);
      // expect(character.encumbrance.grams, 800);    // 800g

      // // Manœuvres (guardian: none au level 1 ici)
      // expect(character.maneuversKnown.value, 0);
      // expect(character.superiorityDice.count, 0);
      // expect(character.superiorityDice.die, isNull);

      // // Compétences (2 de classe choisies + 2 de background)
      // expect(character.skills.length, 4);
      // bool has(String id, ProficiencySource src) =>
      //     character.skills.any((s) => s.skillId == id && s.state == ProficiencyState.proficient && s.sources.contains(src));
      // expect(has('athletics', ProficiencySource.classSource), isTrue);
      // expect(has('perception', ProficiencySource.classSource), isTrue);
      // expect(has('stealth', ProficiencySource.background), isTrue);
      // expect(has('deception', ProficiencySource.background), isTrue);

      // // Persistance
      // verify(() => chars.save(any())).called(1);
    });
  });
}
