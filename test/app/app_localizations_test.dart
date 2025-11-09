import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
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
  group('AppLocalizations equipment helpers', () {
    test('formats weapon metadata in English', () {
      final l10n = AppLocalizations(const Locale('en'));
      expect(l10n.equipmentStepWeaponCategory('Ranged'), 'Category: Ranged');
      expect(
        l10n.equipmentStepWeaponDamage('1d8', 'Energy'),
        'Damage: 1d8 Energy',
      );
      expect(
        l10n.equipmentStepWeaponRange(12, 48),
        'Range: 12 m / 48 m',
      );
      expect(l10n.equipmentStepWeaponRange(12, null), 'Range: 12 m');
      expect(
        l10n.equipmentStepWeaponProperties('Finesse, Light'),
        'Properties: Finesse, Light',
      );
      expect(l10n.equipmentStepRarity('Common'), 'Rarity: Common');
    });

    test('formats weapon metadata in French', () {
      final l10n = AppLocalizations(const Locale('fr'));
      expect(
        l10n.equipmentStepWeaponCategory('À distance'),
        'Catégorie : À distance',
      );
      expect(
        l10n.equipmentStepWeaponDamage('1d8', 'Énergie'),
        'Dégâts : 1d8 Énergie',
      );
      expect(
        l10n.equipmentStepWeaponRange(12, 48),
        'Portée : 12 m / 48 m',
      );
      expect(l10n.equipmentStepWeaponRange(null, null), 'Portée : —');
      expect(
        l10n.equipmentStepWeaponProperties('Finesse, Légère'),
        'Propriétés : Finesse, Légère',
      );
      expect(l10n.equipmentStepRarity('Peu commune'), 'Rareté : Peu commune');
      expect(
        l10n.equipmentStepDamageNotes('Décharges de plasma'),
        'Notes de dégâts : Décharges de plasma',
      );
    });

    test('aggregates weapon metadata lines in English', () {
      final l10n = AppLocalizations(const Locale('en'));
      const EquipmentDef def = EquipmentDef(
        id: 'test-blaster',
        name: LocalizedText(en: 'Test Blaster'),
        type: 'weapon',
        weightG: 2500,
        cost: 500,
        rarity: 'common',
        weaponCategory: 'ranged',
        weaponDamage: <WeaponDamage>[
          WeaponDamage(
            damageType: 'energy',
            damageTypeName: LocalizedText(en: 'Energy'),
            damageTypeNotes: LocalizedText(
              en: 'Blasters, lightsabers, plasma discharges.',
            ),
            diceCount: 1,
            diceDie: 8,
          ),
        ],
        weaponRange: WeaponRange(primary: 12, maximum: 48),
        weaponProperties: <String>['light', 'finesse'],
      );

      final List<String> lines = l10n.equipmentMetadataLines(def);

      expect(
        lines,
        containsAllInOrder(<String>[
          'Weight: 2.50 kg',
          'Damage: 1d8 Energy',
          'Damage notes: Blasters, lightsabers, plasma discharges.',
          'Range: 12 m / 48 m',
          'Properties: Light, Finesse',
          'Rarity: Common',
        ]),
      );
    });

    test('aggregates weapon metadata lines in French', () {
      final l10n = AppLocalizations(const Locale('fr'));
      const EquipmentDef def = EquipmentDef(
        id: 'test-blaster',
        name: LocalizedText(en: 'Test Blaster', fr: 'Blaster de test'),
        type: 'weapon',
        weightG: 2500,
        cost: 500,
        rarity: 'rare',
        weaponCategory: 'distance',
        weaponDamage: <WeaponDamage>[
          WeaponDamage(
            damageType: 'energy',
            damageTypeName: LocalizedText(en: 'Energy', fr: 'Énergie'),
            damageTypeNotes: LocalizedText(
              en: 'Blasters, lightsabers, plasma discharges.',
              fr: 'Blasters, sabres laser et décharges de plasma.',
            ),
            diceCount: 1,
            diceDie: 8,
            diceModifier: 2,
          ),
        ],
        weaponRange: WeaponRange(primary: 20, maximum: 60),
        weaponProperties: <String>['lourde'],
      );

      final List<String> lines = l10n.equipmentMetadataLines(def);

      expect(
        lines,
        containsAllInOrder(<String>[
          'Poids : 2.50 kg',
          'Dégâts : 1d8+2 Énergie',
          'Notes de dégâts : Blasters, sabres laser et décharges de plasma.',
          'Portée : 20 m / 60 m',
          'Propriétés : Lourde',
          'Rareté : Rare',
        ]),
      );
    });
  });

  group('AppLocalizations.quickCreateCharacterSummary', () {
    test('uses localized catalog labels when provided', () {
      final l10n = AppLocalizations(const Locale('fr'));
      final character = Character(
        id: CharacterId('char-test'),
        name: CharacterName('Zara Lor'),
        speciesId: SpeciesId('columi'),
        classId: ClassId('consular'),
        backgroundId: BackgroundId('diplomat'),
        level: Level.one,
        abilities: <String, AbilityScore>{
          'str': AbilityScore(8),
          'dex': AbilityScore(10),
          'con': AbilityScore(12),
          'int': AbilityScore(16),
          'wis': AbilityScore(14),
          'cha': AbilityScore(18),
        },
        skills: <SkillProficiency>{
          SkillProficiency(
            skillId: 'persuasion',
            state: ProficiencyState.proficient,
            sources: const <ProficiencySource>{ProficiencySource.species},
          ),
        },
        proficiencyBonus: ProficiencyBonus.fromLevel(Level.one),
        hitPoints: HitPoints(12),
        defense: Defense(14),
        initiative: Initiative(2),
        credits: Credits(150),
        inventory: <InventoryLine>[
          InventoryLine(
            itemId: EquipmentItemId('gravity-throne'),
            quantity: Quantity(1),
          ),
        ],
        encumbrance: Encumbrance(4500),
        maneuversKnown: ManeuversKnown(0),
        superiorityDice: SuperiorityDice(count: 0),
        speciesTraits: <CharacterTrait>{
          CharacterTrait(id: TraitId('gravity-throne-savants')),
        },
        customizationOptionIds: const <String>{'gravity-throne-poise'},
        forcePowerIds: const <String>{'battle-meditation'},
        techPowerIds: const <String>{'combat-suite'},
      );

      const BackgroundDef diplomatBackground = BackgroundDef(
        id: 'diplomat',
        name: LocalizedText(en: 'Diplomat', fr: 'Diplomate'),
        grantedSkills: <String>['persuasion'],
        languagesPick: 1,
        toolProficiencies: <String>['diplomat-kit'],
        feature: BackgroundFeature(
          name: LocalizedText(
            en: 'Envoy Networks',
            fr: 'Réseaux diplomatiques',
          ),
          effects: <CatalogFeatureEffect>[
            CatalogFeatureEffect(
              id: 'effect-1',
              kind: 'sense',
              text: LocalizedText(
                en: 'Negotiate with allied envoys.',
                fr: 'Négocier avec les envoyés alliés.',
              ),
            ),
          ],
        ),
        personality: BackgroundPersonality(
          traits: <LocalizedText>[
            LocalizedText(
              en: 'Calm under pressure',
              fr: 'Calme sous pression',
            ),
          ],
          ideals: <LocalizedText>[
            LocalizedText(
              en: 'Unity across systems',
              fr: 'Unité entre les systèmes',
            ),
          ],
          bonds: <LocalizedText>[
            LocalizedText(
              en: 'Ally to planetary delegates',
              fr: 'Alliée des délégués planétaires',
            ),
          ],
          flaws: <LocalizedText>[
            LocalizedText(
              en: 'Trusts too easily',
              fr: 'Fait trop vite confiance',
            ),
          ],
        ),
        equipment: <BackgroundEquipmentGrant>[
          BackgroundEquipmentGrant(
            itemId: 'gravity-throne',
            refType: 'gear',
            quantity: 1,
          ),
        ],
      );

      const ClassDef consularClass = ClassDef(
        id: 'consular',
        name: LocalizedText(en: 'Consular', fr: 'Consulaire'),
        hitDie: 8,
        level1: ClassLevel1Data(
          proficiencies: ClassLevel1Proficiencies(
            skillsChoose: 2,
            skillsFrom: <String>['insight'],
          ),
          startingEquipment: <StartingEquipmentLine>[],
          classFeatures: <ClassFeature>[
            ClassFeature(
              name: LocalizedText(
                en: 'Force Insight',
                fr: 'Intuition de la Force',
              ),
              description: LocalizedText(
                en: 'Sense conflicts through the Force.',
                fr: 'Ressentez les conflits grâce à la Force.',
              ),
              effects: <CatalogFeatureEffect>[
                CatalogFeatureEffect(
                  id: 'effect-1',
                  kind: 'bonus',
                  text: LocalizedText(
                    en: 'Gain advantage on Insight checks.',
                    fr: 'Gagnez l’avantage sur les tests d’Intuition.',
                  ),
                ),
              ],
            ),
          ],
        ),
        powerSource: 'force',
        powerList: ClassPowerList(
          forceAllowed: true,
          techAllowed: false,
          spellcastingProgression: 'full',
        ),
        multiclassing: ClassMulticlassing(
          abilityRequirements: const <String, int>{'wis': 13, 'cha': 13},
        ),
      );

      const CustomizationOptionDef poiseOption = CustomizationOptionDef(
        id: 'gravity-throne-poise',
        name: LocalizedText(
          en: 'Gravity Poise',
          fr: 'Maintien gravitationnel',
        ),
        category: 'feat',
        effects: <CatalogFeatureEffect>[
          CatalogFeatureEffect(
            id: 'effect-custom-1',
            kind: 'bonus',
            text: LocalizedText(
              en: 'Advantage on checks to resist being moved.',
              fr: 'Avantage pour résister aux déplacements forcés.',
            ),
          ),
        ],
      );

      const PowerDef battleMeditation = PowerDef(
        id: 'battle-meditation',
        powerType: 'force',
        name: LocalizedText(en: 'Battle Meditation', fr: 'Méditation de bataille'),
        level: 3,
        castingTime: '1 action',
        description: LocalizedText(
          en: 'Bolster allies with the Force.',
          fr: 'Renforcez vos alliés grâce à la Force.',
        ),
      );

      const PowerDef combatSuite = PowerDef(
        id: 'combat-suite',
        powerType: 'tech',
        name: LocalizedText(en: 'Combat Suite', fr: 'Suite de combat'),
        level: 1,
        castingTime: '1 action bonus',
        description: LocalizedText(
          en: 'Upload tactical subroutines to allies.',
          fr: 'Télécharge des routines tactiques pour les alliés.',
        ),
      );

      final summary = l10n.quickCreateCharacterSummary(
        character,
        speciesNames: <String, LocalizedText>{
          'columi': const LocalizedText(en: 'Columi', fr: 'Columi (FR)'),
        },
        classNames: <String, LocalizedText>{
          'consular': const LocalizedText(en: 'Consular', fr: 'Consulaire'),
        },
        classDefinitions: const <String, ClassDef>{
          'consular': consularClass,
        },
        backgroundNames: <String, LocalizedText>{
          'diplomat': const LocalizedText(en: 'Diplomat', fr: 'Diplomate'),
        },
        backgroundDefinitions: const <String, BackgroundDef>{
          'diplomat': diplomatBackground,
        },
        skillDefinitions: <String, SkillDef>{
          'persuasion': SkillDef(
            id: 'persuasion',
            ability: 'cha',
            name: const LocalizedText(en: 'Persuasion', fr: 'Persuasion (FR)'),
          ),
        },
        equipmentDefinitions: <String, EquipmentDef>{
          'gravity-throne': EquipmentDef(
            id: 'gravity-throne',
            name: const LocalizedText(
              en: 'Gravity Throne',
              fr: 'Trône gravitationnel',
            ),
            type: 'gear',
            weightG: 40000,
            cost: 5000,
          ),
          'diplomat-kit': EquipmentDef(
            id: 'diplomat-kit',
            name: const LocalizedText(
              en: 'Diplomat Kit',
              fr: 'Kit diplomatique',
            ),
            type: 'tool',
            weightG: 1500,
            cost: 250,
          ),
        },
        traitDefinitions: <String, TraitDef>{
          'gravity-throne-savants': TraitDef(
            id: 'gravity-throne-savants',
            name: const LocalizedText(
              en: 'Gravity Throne Savants',
              fr: 'Savants du trône',
            ),
            description: const LocalizedText(
              en: 'Linked to their gravity thrones.',
              fr: 'Reliés à leurs trônes de gravité.',
            ),
          ),
        },
        abilityDefinitions: <String, AbilityDef>{
          'wis': const AbilityDef(
            id: 'wis',
            abbreviation: 'WIS',
            name: LocalizedText(en: 'Wisdom', fr: 'Sagesse'),
          ),
          'cha': const AbilityDef(
            id: 'cha',
            abbreviation: 'CHA',
            name: LocalizedText(en: 'Charisma', fr: 'Charisme'),
          ),
        },
        speciesDefinition: const SpeciesDef(
          id: 'columi',
          name: LocalizedText(en: 'Columi', fr: 'Columi (FR)'),
          speed: 25,
          size: 'medium',
          languages: LocalizedText(en: 'Basic, Columese', fr: 'Basic, Columese (FR)'),
          abilityBonuses: <SpeciesAbilityBonus>[
            SpeciesAbilityBonus(ability: 'int', amount: 2),
            SpeciesAbilityBonus(ability: 'wis', amount: 1),
          ],
        ),
        speciesLanguages: const <LanguageDef>[
          LanguageDef(
            id: 'galactic-basic',
            name: LocalizedText(
              en: 'Galactic Basic',
              fr: 'Basique galactique',
            ),
          ),
          LanguageDef(
            id: 'columese',
            name: LocalizedText(
              en: 'Columese',
              fr: 'Columese (FR)',
            ),
          ),
        ],
        customizationOptionDefinitions: const <String, CustomizationOptionDef>{
          'gravity-throne-poise': poiseOption,
        },
        forcePowerDefinitions: const <String, PowerDef>{
          'battle-meditation': battleMeditation,
        },
        techPowerDefinitions: const <String, PowerDef>{
          'combat-suite': combatSuite,
        },
      );

      expect(summary, contains('Espèce : Columi (FR)'));
      expect(summary, contains('Classe : Consulaire'));
      expect(summary, contains('Historique : Diplomate'));
      expect(summary, contains('Langues : Basique galactique, Columese (FR)'));
      expect(
        summary,
        contains('Augmentation de caractéristiques : +2 Intelligence, +1 Sagesse'),
      );
      expect(
        summary,
        contains('Prérequis multi-classe : Charisme 13, Sagesse 13'),
      );
      expect(summary, contains('Source de pouvoirs : Force'));
      expect(summary, contains('Pouvoirs de la Force : autorisés'));
      expect(summary, contains('Pouvoirs technologiques : interdits'));
      expect(summary, contains('Progression de lanceur : Lanceur complet'));
      expect(
        summary,
        contains('Inventaire : Trône gravitationnel x1 — Poids : 40.0 kg'),
      );
      expect(summary, contains('Compétences : Persuasion (FR)'));
      expect(summary, contains('Traits : Savants du trône'));
      expect(summary, contains('Caractéristiques de classe :'));
      expect(summary, contains('• Intuition de la Force: Ressentez les conflits grâce à la Force. Gagnez l’avantage sur les tests d’Intuition.'));
      expect(summary, contains('Options de personnalisation :'));
      expect(
        summary,
        contains('• Maintien gravitationnel: Avantage pour résister aux déplacements forcés.'),
      );
      expect(summary, contains('Pouvoirs de la Force :'));
      expect(
        summary,
        contains('• Méditation de bataille: Renforcez vos alliés grâce à la Force.'),
      );
      expect(summary, contains('Pouvoirs technologiques :'));
      expect(
        summary,
        contains('• Suite de combat: Télécharge des routines tactiques pour les alliés.'),
      );
      expect(
        summary,
        contains('Historique :\n• Compétences accordées : Persuasion (FR)'),
      );
      expect(summary, contains('• Langues supplémentaires à choisir : 1'));
      expect(summary, contains('• Maîtrises d’outils : Kit diplomatique'));
      expect(summary, contains('• Capacité d’historique : Réseaux diplomatiques'));
      expect(summary, contains('• Négocier avec les envoyés alliés.'));
      expect(summary, contains('• Traits de personnalité : Calme sous pression'));
      expect(summary, contains('• Idéaux : Unité entre les systèmes'));
      expect(summary, contains('• Liens : Alliée des délégués planétaires'));
      expect(summary, contains('• Défauts : Fait trop vite confiance'));
      expect(
        summary,
        contains('• Équipement associé : Trône gravitationnel x1 — Poids : 40.0 kg'),
      );
    });
  });

  group('AppLocalizations.savedCharacterShareSubject', () {
    test('formats subject in French', () {
      final l10n = AppLocalizations(const Locale('fr'));
      expect(l10n.savedCharacterShareSubject('Ahsoka'),
          'Personnage SW5e : Ahsoka');
    });

    test('formats subject in English', () {
      final l10n = AppLocalizations(const Locale('en'));
      expect(
        l10n.savedCharacterShareSubject('Ahsoka'),
        'SW5e character: Ahsoka',
      );
    });
  });

  group('AppLocalizations.skillStepAbilitySubtitle', () {
    test('uses catalog ability name when provided', () {
      final l10n = AppLocalizations(const Locale('fr'));
      final text = l10n.skillStepAbilitySubtitle(
        'str',
        catalogName: const LocalizedText(
          en: 'Strength',
          fr: 'Force (FR)',
        ),
      );

      expect(text, 'Basée sur Force (FR) (FOR)');
    });

    test('falls back to default labels when catalog data missing', () {
      final l10n = AppLocalizations(const Locale('en'));
      final text = l10n.skillStepAbilitySubtitle('dex');

      expect(text, 'Based on Dexterity (DEX)');
    });
  });

  test('localizes class picker ability and proficiency headers', () {
    final AppLocalizations en = AppLocalizations(const Locale('en'));
    final AppLocalizations fr = AppLocalizations(const Locale('fr'));

    expect(en.classPickerPrimaryAbilitiesTitle, 'Primary abilities');
    expect(fr.classPickerPrimaryAbilitiesTitle, 'Caractéristiques principales');

    expect(en.classPickerSavingThrowsTitle, 'Saving throws');
    expect(fr.classPickerSavingThrowsTitle, 'Jets de sauvegarde');

    expect(en.classPickerWeaponProficienciesTitle, 'Weapon proficiencies');
    expect(fr.classPickerWeaponProficienciesTitle, 'Maîtrises d’armes');

    expect(en.classPickerArmorProficienciesTitle, 'Armor proficiencies');
    expect(fr.classPickerArmorProficienciesTitle, 'Maîtrises d’armures');

    expect(en.classPickerToolProficienciesTitle, 'Tool proficiencies');
    expect(fr.classPickerToolProficienciesTitle, 'Maîtrises d’outils');
  });

  group('class proficiency category labels', () {
    test('returns localized weapon categories', () {
      final AppLocalizations en = AppLocalizations(const Locale('en'));
      final AppLocalizations fr = AppLocalizations(const Locale('fr'));

      expect(en.classWeaponCategoryLabel('simple'), 'Simple weapons');
      expect(fr.classWeaponCategoryLabel('simple'), 'Armes simples');
    });

    test('returns localized armor categories', () {
      final AppLocalizations en = AppLocalizations(const Locale('en'));
      final AppLocalizations fr = AppLocalizations(const Locale('fr'));

      expect(en.classArmorCategoryLabel('medium'), 'Medium armor');
      expect(fr.classArmorCategoryLabel('medium'), 'Armure intermédiaire');
    });

    test('falls back to title case for unknown categories', () {
      final AppLocalizations en = AppLocalizations(const Locale('en'));

      expect(en.classWeaponCategoryLabel('custom-entry'), 'Custom Entry');
      expect(en.classArmorCategoryLabel('custom-entry'), 'Custom Entry');
      expect(en.classToolCategoryLabel('custom-entry'), 'Custom Entry');
    });

    test('resolves tool categories when mapping exists', () {
      final AppLocalizations en = AppLocalizations(const Locale('en'));
      final AppLocalizations fr = AppLocalizations(const Locale('fr'));

      expect(en.classToolCategoryLabel('disguise-kit'), 'Disguise kit');
      expect(fr.classToolCategoryLabel('disguise-kit'), 'Trousse de déguisement');
    });
  });

  group('language labels', () {
    test('languageScriptLabel provides localized prefixes', () {
      final AppLocalizations en = AppLocalizations(const Locale('en'));
      final AppLocalizations fr = AppLocalizations(const Locale('fr'));

      expect(en.languageScriptLabel('Aurebesh'), 'Script: Aurebesh');
      expect(fr.languageScriptLabel('Aurebesh'), 'Alphabet : Aurebesh');
    });

    test('languageTypicalSpeakersLabel lists localized speakers', () {
      final AppLocalizations en = AppLocalizations(const Locale('en'));
      final AppLocalizations fr = AppLocalizations(const Locale('fr'));

      expect(
        en.languageTypicalSpeakersLabel("Twi'lek, Human"),
        "Typical speakers: Twi'lek, Human",
      );
      expect(
        fr.languageTypicalSpeakersLabel("Twi'lek, Humain"),
        "Locuteurs typiques : Twi'lek, Humain",
      );
    });
  });
}
