/// ---------------------------------------------------------------------------
/// Fichier test : catalog_lookup_service_test.dart
/// Rôle : Vérifier que [CatalogLookupService] charge correctement les définitions
///        nécessaires pour afficher les personnages sauvegardés.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/services/catalog_lookup_service.dart';
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

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _FakeLogger implements AppLogger {
  @override
  void error(String message, {Object? payload, Object? error, StackTrace? stackTrace}) {}

  @override
  void info(String message, {Object? payload}) {}

  @override
  void warn(String message, {Object? payload, Object? error, StackTrace? stackTrace}) {}
}

Character _buildCharacter() {
  return Character(
    id: CharacterId('char-1'),
    name: CharacterName('Test Character'),
    speciesId: SpeciesId('human'),
    classId: ClassId('guardian'),
    backgroundId: BackgroundId('outlaw'),
    level: Level.one,
    abilities: <String, AbilityScore>{
      'str': AbilityScore(10),
      'dex': AbilityScore(12),
      'con': AbilityScore(11),
      'int': AbilityScore(10),
      'wis': AbilityScore(12),
      'cha': AbilityScore(14),
    },
    skills: <SkillProficiency>{
      SkillProficiency(
        skillId: 'perception',
        state: ProficiencyState.proficient,
        sources: const <ProficiencySource>{ProficiencySource.species},
      ),
    },
    proficiencyBonus: ProficiencyBonus.fromLevel(Level.one),
    hitPoints: HitPoints(10),
    defense: Defense(12),
    initiative: Initiative(1),
    credits: Credits(150),
    inventory: <InventoryLine>[
      InventoryLine(
        itemId: EquipmentItemId('medkit'),
        quantity: Quantity(1),
      ),
    ],
    encumbrance: Encumbrance(0),
    maneuversKnown: ManeuversKnown(0),
    superiorityDice: SuperiorityDice(count: 0, die: null),
    speciesTraits: <CharacterTrait>{
      CharacterTrait(id: TraitId('gravity-throne-savants')),
    },
    customizationOptionIds: const <String>{'improvised-style'},
    forcePowerIds: const <String>{'force-push'},
    techPowerIds: const <String>{'tech-barrier'},
  );
}

void main() {
  late _MockCatalogRepository catalog;
  late AppLogger logger;
  late CatalogLookupService service;

  setUp(() {
    catalog = _MockCatalogRepository();
    logger = _FakeLogger();
    service = CatalogLookupService(catalog: catalog, logger: logger);
  });

  test('renvoie un résultat vide lorsque la liste est vide', () async {
    final CatalogLookupResult result =
        await service.buildForCharacters(characters: const <Character>[]);

    expect(result.speciesNames, isEmpty);
    expect(result.speciesDefinitions, isEmpty);
    expect(result.classNames, isEmpty);
    expect(result.classDefinitions, isEmpty);
    expect(result.backgroundNames, isEmpty);
    expect(result.backgroundDefinitions, isEmpty);
    expect(result.skillDefinitions, isEmpty);
    expect(result.equipmentDefinitions, isEmpty);
    expect(result.traitDefinitions, isEmpty);
    expect(result.languageDefinitions, isEmpty);
    expect(result.abilityDefinitions, isEmpty);

    verifyNever(() => catalog.getSpecies(any()));
    verifyNever(() => catalog.getClass(any()));
    verifyNever(() => catalog.getBackground(any()));
    verifyNever(() => catalog.getSkill(any()));
    verifyNever(() => catalog.getEquipment(any()));
    verifyNever(() => catalog.getTrait(any()));
    verifyNever(() => catalog.getLanguage(any()));
    verifyNever(() => catalog.getAbility(any()));
  });

  test('charge les définitions de catalogue référencées par le personnage', () async {
    final Character character = _buildCharacter();

    when(() => catalog.getSpecies('human')).thenAnswer(
      (_) async => const SpeciesDef(
        id: 'human',
        name: LocalizedText(en: 'Human', fr: 'Humain'),
        speed: 30,
        size: 'medium',
        languageIds: <String>['galactic-basic'],
        languages: LocalizedText(en: 'Basic', fr: 'Basique'),
      ),
    );

    when(() => catalog.getLanguage('galactic-basic')).thenAnswer(
      (_) async => const LanguageDef(
        id: 'galactic-basic',
        name: LocalizedText(en: 'Galactic Basic', fr: 'Basic galactique'),
        description: null,
      ),
    );

    when(() => catalog.getClass('guardian')).thenAnswer(
      (_) async => ClassDef(
        id: 'guardian',
        name: const LocalizedText(en: 'Guardian', fr: 'Gardien'),
        hitDie: 10,
        level1: const ClassLevel1Data(
          proficiencies: ClassLevel1Proficiencies(
            skillsChoose: 0,
            skillsFrom: <String>[],
          ),
          startingEquipment: <StartingEquipmentLine>[],
        ),
      ),
    );

    when(() => catalog.getBackground('outlaw')).thenAnswer(
      (_) async => const BackgroundDef(
        id: 'outlaw',
        name: LocalizedText(en: 'Outlaw', fr: 'Hors-la-loi'),
        grantedSkills: <String>[],
        toolProficiencies: <String>['disguise-kit'],
      ),
    );

    when(() => catalog.getSkill('perception')).thenAnswer(
      (_) async => const SkillDef(
        id: 'perception',
        ability: 'wis',
        name: LocalizedText(en: 'Perception', fr: 'Perception'),
      ),
    );

    when(() => catalog.getEquipment('medkit')).thenAnswer(
      (_) async => const EquipmentDef(
        id: 'medkit',
        name: LocalizedText(en: 'Medkit', fr: 'Kit médical'),
        type: 'gear',
        weightG: 500,
        cost: 50,
      ),
    );

    when(() => catalog.getEquipment('disguise-kit')).thenAnswer(
      (_) async => const EquipmentDef(
        id: 'disguise-kit',
        name: LocalizedText(en: 'Disguise Kit', fr: 'Kit de déguisement'),
        type: 'tool',
        weightG: 400,
        cost: 25,
      ),
    );

    when(() => catalog.getTrait('gravity-throne-savants')).thenAnswer(
      (_) async => const TraitDef(
        id: 'gravity-throne-savants',
        name: LocalizedText(
          en: 'Gravity Throne Savants',
          fr: 'Savant du trône gravitationnel',
        ),
        description: LocalizedText(en: 'description', fr: 'description'),
      ),
    );

    when(() => catalog.getCustomizationOption('improvised-style')).thenAnswer(
      (_) async => const CustomizationOptionDef(
        id: 'improvised-style',
        name: LocalizedText(en: 'Improvised Style', fr: 'Style improvisé'),
        category: 'feat',
      ),
    );

    when(() => catalog.getForcePower('force-push')).thenAnswer(
      (_) async => const PowerDef(
        id: 'force-push',
        powerType: 'force',
        name: LocalizedText(en: 'Force Push', fr: 'Projection de Force'),
        level: 1,
        castingTime: '1 action',
        description: LocalizedText(
          en: 'Push a creature away.',
          fr: 'Repousse une créature.',
        ),
      ),
    );

    when(() => catalog.getTechPower('tech-barrier')).thenAnswer(
      (_) async => const PowerDef(
        id: 'tech-barrier',
        powerType: 'tech',
        name: LocalizedText(en: 'Tech Barrier', fr: 'Barrière technologique'),
        level: 1,
        castingTime: '1 action bonus',
        description: LocalizedText(
          en: 'Deploy a protective barrier.',
          fr: 'Déploie une barrière protectrice.',
        ),
      ),
    );

    when(() => catalog.getAbility(any())).thenAnswer((invocation) async {
      final String id = invocation.positionalArguments.first as String;
      return AbilityDef(
        id: id,
        abbreviation: id.toUpperCase(),
        name: LocalizedText(en: id, fr: id),
      );
    });

    final CatalogLookupResult result = await service.buildForCharacters(
      characters: <Character>[character],
    );

    expect(result.speciesNames['human']?.fr, 'Humain');
    expect(result.speciesDefinitions['human']?.languages?.fr, 'Basique');
    expect(result.classNames['guardian']?.en, 'Guardian');
    expect(result.classDefinitions.containsKey('guardian'), isTrue);
    expect(result.backgroundNames['outlaw']?.fr, 'Hors-la-loi');
    expect(result.backgroundDefinitions['outlaw']?.name.en, 'Outlaw');
    expect(result.skillDefinitions.containsKey('perception'), isTrue);
    expect(result.equipmentDefinitions.containsKey('medkit'), isTrue);
    expect(result.equipmentDefinitions.containsKey('disguise-kit'), isTrue);
    expect(result.traitDefinitions.containsKey('gravity-throne-savants'), isTrue);
    expect(result.languageDefinitions['galactic-basic']?.name.fr,
        'Basic galactique');
    expect(result.abilityDefinitions.containsKey('str'), isTrue);
    expect(
        result.customizationOptionDefinitions.containsKey('improvised-style'),
        isTrue);
    expect(result.forcePowerDefinitions.containsKey('force-push'), isTrue);
    expect(result.techPowerDefinitions.containsKey('tech-barrier'), isTrue);

    verify(() => catalog.getSpecies('human')).called(1);
    verify(() => catalog.getClass('guardian')).called(1);
    verify(() => catalog.getBackground('outlaw')).called(1);
    verify(() => catalog.getSkill('perception')).called(1);
    verify(() => catalog.getEquipment('medkit')).called(1);
    verify(() => catalog.getEquipment('disguise-kit')).called(1);
    verify(() => catalog.getTrait('gravity-throne-savants')).called(1);
    verify(() => catalog.getLanguage('galactic-basic')).called(1);
    verify(() => catalog.getAbility(any())).called(greaterThanOrEqualTo(1));
    verify(() => catalog.getCustomizationOption('improvised-style')).called(1);
    verify(() => catalog.getForcePower('force-push')).called(1);
    verify(() => catalog.getTechPower('tech-barrier')).called(1);
  });
}
