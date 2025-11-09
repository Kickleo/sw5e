/// ---------------------------------------------------------------------------
/// Fichier : test/data/catalog/asset_catalog_repository_test.dart
/// Rôle : Vérifier que l'adapter AssetCatalogRepository lit correctement les assets
///        JSON et hydrate les entités domaine attendues.
/// Dépendances : `flutter_test` pour l'environnement widget/AssetBundle.
/// Exemple d'usage : lancer `flutter test` pour garantir le comportement.
/// ---------------------------------------------------------------------------
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/data/catalog/repositories/asset_catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/localization/species_effect_localization.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

void main() {
  // Nécessaire pour accéder à rootBundle dans les tests
  TestWidgetsFlutterBinding.ensureInitialized();

  test('charge le catalogue depuis assets/catalog_v2/*', () async {
    SpeciesEffectLocalizationCatalog.resetToDefaults();
    final repo = AssetCatalogRepository();

    // Skills
    final skills = await repo.listSkills();
    expect(skills, containsAll(<String>['perception', 'athletics', 'stealth', 'deception']));
    final SkillDef? perception = await repo.getSkill('perception');
    expect(perception, isNotNull);
    expect(perception!.name.en, 'Perception');
    expect(perception.name.fr, isNotEmpty);

    // Species
    final human = await repo.getSpecies('human');
    expect(human, isNotNull);
    expect(human!.speed, 30);
    expect(human.size, 'medium');
    expect(
      human.descriptionShort?.en,
      contains('Adaptive settlers'),
    );
    expect(
      human.description?.fr,
      contains('curiosité'),
    );

    // Class
    final sentinel = await repo.getClass('sentinel');
    expect(sentinel, isNotNull);
    expect(sentinel!.primaryAbilities, containsAll(<String>['dex', 'wis']));
    expect(sentinel.savingThrows, containsAll(<String>['dex', 'wis']));
    expect(sentinel.weaponProficiencies, contains('martial'));
    expect(sentinel.armorProficiencies, contains('medium'));
    expect(sentinel.powerSource, 'force');
    expect(sentinel.powerList, isNotNull);
    expect(sentinel.powerList!.forceAllowed, isTrue);
    expect(sentinel.powerList!.techAllowed, isFalse);
    expect(sentinel.powerList!.spellcastingProgression, 'half');
    expect(sentinel.level1.startingEquipment, isNotEmpty);
    expect(sentinel.level1.startingEquipment.first.id, 'blaster-pistol');
    expect(sentinel.level1.startingEquipment.first.qty, 1);
    expect(sentinel.multiclassing, isNotNull);
    expect(sentinel.multiclassing!.abilityRequirements['dex'], 13);
    expect(sentinel.multiclassing!.abilityRequirements['wis'], 13);

    // Equipment
    final blaster = await repo.getEquipment('blaster-pistol');
    expect(blaster, isNotNull);
    expect(blaster!.weightG, 1000);
    expect(blaster.rarity, 'common');
    expect(blaster.weaponCategory, 'ranged');
    expect(blaster.weaponDamage, isNotEmpty);
    final WeaponDamage damage = blaster.weaponDamage.first;
    expect(damage.diceCount, 1);
    expect(damage.diceDie, 8);
    expect(damage.damageType, 'energy');
    expect(damage.damageTypeName?.en, 'Energy');
    expect(
      damage.damageTypeNotes?.en,
      contains('Blasters, lightsabers'),
    );
    expect(blaster.weaponRange?.primary, 12);
    expect(blaster.weaponRange?.maximum, 48);
    expect(blaster.description?.en, contains('Reliable sidearm'));

    // Background
    final outlander = await repo.getBackground('outlander');
    expect(outlander, isNotNull);
    expect(outlander!.grantedSkills, contains('athletics'));
    expect(outlander.languagesPick, 1);
    expect(outlander.feature?.name.en, 'Wanderer');
    expect(outlander.personality?.traits, isNotEmpty);

    // Formulas
    final formulas = await repo.getFormulas();
    expect(formulas.rulesVersion, '2024-05-01');
    expect(formulas.superiorityDiceByClass['sentinel']!.count, 0);
    expect(formulas.attackBonus, 'proficiency + ability_mod');
    expect(
      formulas.powerSaveDc,
      '8 + proficiency + casting_ability_mod',
    );

    // Abilities
    final abilities = await repo.listAbilities();
    expect(abilities, containsAll(<String>['str', 'dex', 'cha']));
    final AbilityDef? strength = await repo.getAbility('str');
    expect(strength, isNotNull);
    expect(strength!.name.en, 'Strength');
    expect(strength.abbreviation, 'STR');

    final Map<String, SpeciesEffectLanguageBundle> bundles =
        SpeciesEffectLocalizationCatalog.snapshot();
    expect(bundles.keys, containsAll(<String>['en', 'fr']));
    expect(bundles['en']!.abilityNames['str'], isNotEmpty);
    expect(bundles['fr']!.abilityNames['str'], isNotEmpty);

    // Damage types
    final damageTypes = await repo.listDamageTypes();
    expect(damageTypes, contains('energy'));
    final DamageTypeDef? energy = await repo.getDamageType('energy');
    expect(energy, isNotNull);
    expect(energy!.name.fr, contains('Énergie'));

    // Customization options
    final List<String> customizationOptions =
        await repo.listCustomizationOptions();
    expect(customizationOptions, contains('form-ii-makashi'));
    final CustomizationOptionDef? makashi =
        await repo.getCustomizationOption('form-ii-makashi');
    expect(makashi, isNotNull);
    expect(makashi!.category, 'lightsaber-form');
    expect(makashi.name.fr, contains('Forme II'));
    expect(makashi.effects, isNotEmpty);
    expect(makashi.prerequisite, isNotNull);
    expect(makashi.prerequisite!.all, isNotEmpty);
    expect(
      makashi.prerequisite!.all.first.condition?.classId,
      '4dc8dba9-32a6-5289-b428-f733eee23bf5',
    );
    final CustomizationOptionDef? makashiByUuid = await repo.getCustomizationOption(
      '99ff7464-d4cc-5ebe-b5f3-72ecac188eb6',
    );
    expect(makashiByUuid, same(makashi));

    // Force powers
    final List<String> forcePowers = await repo.listForcePowers();
    expect(forcePowers, contains('battle-meditation'));
    final PowerDef? battleMeditation =
        await repo.getForcePower('battle-meditation');
    expect(battleMeditation, isNotNull);
    expect(battleMeditation!.powerType, 'force');
    expect(battleMeditation.level, 2);
    expect(battleMeditation.alignment, 'light');
    expect(battleMeditation.school, isNotEmpty);
    expect(battleMeditation.range, isNotNull);
    expect(battleMeditation.range!.type, 'area');
    expect(battleMeditation.range!.distanceMeters, 18);
    expect(battleMeditation.range!.distanceFeet, greaterThan(0));
    expect(battleMeditation.components, containsAll(<String>['vocal', 'somatic']));
    expect(battleMeditation.classes, isNotEmpty);
    final PowerDef? battleMeditationByUuid = await repo.getForcePower(
      '7b64e23e-9f44-5121-9b44-841e35b5e57e',
    );
    expect(battleMeditationByUuid, same(battleMeditation));

    // Tech powers
    final List<String> techPowers = await repo.listTechPowers();
    expect(techPowers, contains('voltaic-shielding'));
    final PowerDef? voltaicShielding =
        await repo.getTechPower('voltaic-shielding');
    expect(voltaicShielding, isNotNull);
    expect(voltaicShielding!.powerType, 'tech');
    expect(voltaicShielding.level, 2);
    expect(voltaicShielding.alignment, isNull);
    expect(voltaicShielding.range, isNotNull);
    expect(voltaicShielding.range!.type, 'self');
    expect(voltaicShielding.range!.distanceMeters, isNull);
    expect(voltaicShielding.duration, isNotNull);
    expect(voltaicShielding.duration!.concentration, isTrue);
    expect(voltaicShielding.components, contains('tech'));
    expect(voltaicShielding.effects, isNotEmpty);
    final PowerDef? voltaicShieldingByUuid = await repo.getTechPower(
      '64ea13ef-8e05-5afa-84bf-01daa57c7694',
    );
    expect(voltaicShieldingByUuid, same(voltaicShielding));
  });
}
