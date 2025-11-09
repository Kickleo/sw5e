/// ---------------------------------------------------------------------------
/// Fichier : lib/data/catalog/repositories/asset_catalog_repository.dart
/// Rôle : Adapter les DTO chargés depuis les assets en implémentation de
///        [CatalogRepository] pour la couche domaine.
/// Dépendances : DTO du catalogue et data source AssetBundle.
/// Exemple d'usage :
///   final repo = AssetCatalogRepository();
///   final species = await repo.getSpecies('human');
/// ---------------------------------------------------------------------------
library;
import 'package:sw5e_manager/data/catalog_v2/data_sources/asset_bundle_catalog_v2_data_source.dart';
import 'package:sw5e_manager/data/catalog_v2/dtos/catalog_v2_dtos.dart';
import 'package:sw5e_manager/domain/characters/localization/species_effect_localization.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// AssetCatalogRepository = adapter hors-ligne basé sur les assets JSON embarqués.
class AssetCatalogRepository implements CatalogRepository {
  final AssetBundleCatalogV2DataSource _dataSourceV2;

  Map<String, SpeciesDef>? _species; // Cache lazy des espèces indexées par id.
  Map<String, ClassDef>? _classes; // Cache des classes niveau 1.
  Map<String, BackgroundDef>? _backgrounds; // Cache des backgrounds disponibles.
  Map<String, SkillDef>? _skills; // Cache des compétences.
  Map<String, EquipmentDef>?
      _equipment; // Cache de l'équipement indexé par identifiant.
  Map<String, String>? _equipmentIdToSlug; // Mapping UUID -> slug pour l'équipement.
  Map<String, TraitDef>? _traits; // Cache des traits d'espèce/background.
  Map<String, CustomizationOptionDef>?
      _customizationOptions; // Cache des options de personnalisation (feats, styles...).
  Map<String, String>? _customizationOptionIdToSlug; // UUID -> slug pour ces options.
  FormulasDef? _formulas; // Formules métier (singleton).
  Map<String, AbilityDef>? _abilities; // Cache des caractéristiques.
  Map<String, DamageTypeDef>? _damageTypes; // Cache des types de dégâts.
  Map<String, PowerDef>? _forcePowers; // Cache des pouvoirs de Force.
  Map<String, PowerDef>? _techPowers; // Cache des pouvoirs techno.
  Map<String, String>? _forcePowerIdToSlug; // UUID -> slug Force.
  Map<String, String>? _techPowerIdToSlug; // UUID -> slug Tech.

  Map<String, String>? _abilityIdToSlug;
  Map<String, String>? _abilityAbbrToSlug;
  Map<String, LocalizedText>? _abilityNames; // Libellés localisés par caractéristique.
  Map<String, LanguageDef>? _languages; // Cache des langues (slug -> définition).
  Map<String, String>? _languageIdToSlug; // Mapping UUID -> slug pour résolutions.
  Map<String, String>? _traitIdToSlug;
  Map<String, String>? _skillIdToSlug; // Mapping UUID -> slug pour les compétences.
  Map<String, String>? _damageTypeIdToSlug; // Mapping UUID -> slug pour les dégâts.

  AssetCatalogRepository({
    AssetBundleCatalogV2DataSource? dataSourceV2,
  }) : _dataSourceV2 = dataSourceV2 ?? AssetBundleCatalogV2DataSource();

  @override
  Future<String> getRulesVersion() async {
    await _ensureFormulas(); // Charge les formules si nécessaire.
    return _formulas!.rulesVersion; // Retourne la version des règles embarquées.
  }

  @override
  Future<SpeciesDef?> getSpecies(String speciesId) async {
    await _ensureSpecies(); // Charge et met en cache les espèces au premier appel.
    return _species![speciesId]; // Lecture dans la map immuable.
  }

  @override
  Future<ClassDef?> getClass(String classId) async {
    await _ensureClasses();
    return _classes![classId];
  }

  @override
  Future<BackgroundDef?> getBackground(String backgroundId) async {
    await _ensureBackgrounds();
    return _backgrounds![backgroundId];
  }

  @override
  Future<SkillDef?> getSkill(String skillId) async {
    await _ensureSkills();
    await _ensureEquipment();
    return _skills![skillId];
  }

  @override
  Future<AbilityDef?> getAbility(String abilityId) async {
    await _ensureAbilities();
    return _abilities![abilityId];
  }

  @override
  Future<EquipmentDef?> getEquipment(String equipmentId) async {
    await _ensureEquipment();
    final EquipmentDef? direct = _equipment![equipmentId];
    if (direct != null) {
      return direct;
    }
    final String? slug = _equipmentIdToSlug?[equipmentId];
    if (slug != null) {
      return _equipment![slug];
    }
    return null;
  }

  @override
  Future<LanguageDef?> getLanguage(String languageId) async {
    await _ensureLanguages();
    return _languages![languageId];
  }

  @override
  Future<FormulasDef> getFormulas() async {
    await _ensureFormulas();
    return _formulas!; // Non nullable une fois chargé (assertion via bang).
  }

  @override
  Future<TraitDef?> getTrait(String traitId) async {
    await _ensureTraits();
    return _traits![traitId];
  }

  @override
  Future<CustomizationOptionDef?> getCustomizationOption(String optionId) async {
    await _ensureCustomizationOptions();
    final CustomizationOptionDef? direct = _customizationOptions![optionId];
    if (direct != null) {
      return direct;
    }
    final String? slug = _customizationOptionIdToSlug?[optionId];
    if (slug != null) {
      return _customizationOptions![slug];
    }
    return null;
  }

  @override
  Future<DamageTypeDef?> getDamageType(String damageTypeId) async {
    await _ensureDamageTypes();
    return _damageTypes![damageTypeId];
  }

  @override
  Future<PowerDef?> getForcePower(String powerId) async {
    await _ensureForcePowers();
    final PowerDef? direct = _forcePowers![powerId];
    if (direct != null) {
      return direct;
    }
    final String? slug = _forcePowerIdToSlug?[powerId];
    if (slug != null) {
      return _forcePowers![slug];
    }
    return null;
  }

  @override
  Future<PowerDef?> getTechPower(String powerId) async {
    await _ensureTechPowers();
    final PowerDef? direct = _techPowers![powerId];
    if (direct != null) {
      return direct;
    }
    final String? slug = _techPowerIdToSlug?[powerId];
    if (slug != null) {
      return _techPowers![slug];
    }
    return null;
  }

  @override
  Future<List<String>> listSkills() async {
    await _ensureSkills();
    return _skills!.keys.toList()..sort(); // Retourne les identifiants triés.
  }

  @override
  Future<List<String>> listAbilities() async {
    await _ensureAbilities();
    return _abilities!.keys.toList()..sort();
  }

  @override
  Future<List<String>> listSpecies() async {
    await _ensureSpecies();
    return _species!.keys.toList()..sort();
  }

  @override
  Future<List<String>> listClasses() async {
    await _ensureClasses();
    return _classes!.keys.toList()..sort();
  }

  @override
  Future<List<String>> listBackgrounds() async {
    await _ensureBackgrounds();
    return _backgrounds!.keys.toList()..sort();
  }

  @override
  Future<List<String>> listEquipment() async {
    await _ensureEquipment();
    return _equipment!.keys.toList()..sort();
  }

  @override
  Future<List<String>> listLanguages() async {
    await _ensureLanguages();
    return _languages!.keys.toList()..sort();
  }

  @override
  Future<List<String>> listTraits() async {
    await _ensureTraits();
    return _traits!.keys.toList()..sort();
  }

  @override
  Future<List<String>> listCustomizationOptions() async {
    await _ensureCustomizationOptions();
    return _customizationOptions!.keys.toList()..sort();
  }

  @override
  Future<List<String>> listDamageTypes() async {
    await _ensureDamageTypes();
    return _damageTypes!.keys.toList()..sort();
  }

  @override
  Future<List<String>> listForcePowers() async {
    await _ensureForcePowers();
    return _forcePowers!.keys.toList()..sort();
  }

  @override
  Future<List<String>> listTechPowers() async {
    await _ensureTechPowers();
    return _techPowers!.keys.toList()..sort();
  }

  Future<void> _ensureSpecies() async {
    if (_species != null) return; // Cache déjà rempli.
    await _ensureTraits();
    await _ensureLanguages();
    await _ensureAbilities();

    final List<CatalogV2SpeciesDto> dtos = await _dataSourceV2.loadSpecies();
    final Map<String, SpeciesDef> mapped = <String, SpeciesDef>{};
    for (final CatalogV2SpeciesDto dto in dtos) {
      final List<SpeciesAbilityBonus> bonuses = <SpeciesAbilityBonus>[];
      dto.abilityIncreases.forEach((String abbr, int amount) {
        final String abilitySlug =
            _abilityAbbrToSlug![abbr] ?? abbr.toLowerCase();
        bonuses.add(SpeciesAbilityBonus(ability: abilitySlug, amount: amount));
      });

      final List<String> traitSlugs = <String>[];
      for (final String traitId in dto.traitIds) {
        final String? slug = _traitIdToSlug![traitId];
        if (slug != null) {
          traitSlugs.add(slug);
        }
      }

      final LocalizedText? languages = _resolveSpeciesLanguages(dto);
      final List<String> languageSlugs = _resolveSpeciesLanguageSlugs(dto);

      mapped[dto.slug] = SpeciesDef(
        id: dto.slug,
        name: dto.name.toDomain(),
        speed: _metersToFeet(dto.speedMeters),
        size: dto.size,
        traitIds: List<String>.unmodifiable(traitSlugs),
        languageIds: List<String>.unmodifiable(languageSlugs),
        abilityBonuses: List<SpeciesAbilityBonus>.unmodifiable(bonuses),
        age: null,
        alignment: null,
        sizeText: null,
        speedText: null,
        languages: languages,
        descriptionShort: dto.descriptionShort?.toDomain(),
        description: dto.description?.toDomain(),
      );
    }
    _species = Map<String, SpeciesDef>.unmodifiable(mapped);
  }

  Future<void> _ensureClasses() async {
    if (_classes != null) return;
    await _ensureAbilities();
    await _ensureSkills();
    await _ensureEquipment();
    final List<CatalogV2ClassDto> v2Dtos = await _dataSourceV2.loadClasses();
    final Map<String, ClassDef> mapped = <String, ClassDef>{};
    for (final CatalogV2ClassDto dto in v2Dtos) {
      final List<String> primaryAbilities = <String>[];
      for (final String abbr in dto.primaryAbilities) {
        final String slug = _abilityAbbrToSlug?[abbr] ?? abbr.toLowerCase();
        if (slug.isEmpty) continue;
        if (!primaryAbilities.contains(slug)) {
          primaryAbilities.add(slug);
        }
      }

      final List<String> savingThrows = <String>[];
      for (final String abbr in dto.savingThrows) {
        final String slug = _abilityAbbrToSlug?[abbr] ?? abbr.toLowerCase();
        if (slug.isEmpty) continue;
        if (!savingThrows.contains(slug)) {
          savingThrows.add(slug);
        }
      }

      final List<String> skillSlugs = <String>[];
      for (final String ref in dto.proficiencies.skillRefs) {
        final String? slug = _skillIdToSlug?[ref];
        if (slug != null && slug.isNotEmpty) {
          skillSlugs.add(slug);
        }
      }

      final List<ClassFeature> level1Features = <ClassFeature>[];
      final List<CatalogV2ClassFeatureDto>? v2Level1Features =
          dto.featuresByLevel[1];
      if (v2Level1Features != null && v2Level1Features.isNotEmpty) {
        for (final CatalogV2ClassFeatureDto feature in v2Level1Features) {
          final List<CatalogFeatureEffect> effects = feature.effects
              .map(
                (CatalogV2FeatureEffectDto effect) => CatalogFeatureEffect(
                  id: effect.id,
                  kind: effect.kind,
                  target: effect.target,
                  text: effect.text?.toDomain(),
                ),
              )
              .toList(growable: false);

          level1Features.add(
            ClassFeature(
              name: feature.name.toDomain(),
              description: feature.text?.toDomain(),
              effects: effects,
            ),
          );
        }
      }

      final List<StartingEquipmentLine> startingEquipment =
          <StartingEquipmentLine>[];
      for (final CatalogV2EquipmentGrantDto grant in dto.startingEquipment) {
        String itemId = grant.ref.id.isNotEmpty ? grant.ref.id : grant.ref.type;
        final String? slug = _equipmentIdToSlug?[itemId];
        if (slug != null && slug.isNotEmpty) {
          itemId = slug;
        } else {
          itemId = itemId.toLowerCase();
        }
        if (itemId.isEmpty) {
          continue;
        }
        final int quantity = grant.quantity > 0 ? grant.quantity : 1;
        startingEquipment.add(
          StartingEquipmentLine(id: itemId, qty: quantity),
        );
      }

      final List<LocalizedText> startingEquipmentOptions =
          dto.startingEquipmentOptions
              .map((LocalizedTextDto value) => value.toDomain())
              .toList(growable: false);

      final String? normalizedPowerSource = () {
        final String? raw = dto.powerSource?.trim();
        if (raw == null || raw.isEmpty) {
          return null;
        }
        return raw;
      }();

      final ClassPowerList? powerList = dto.powerList != null
          ? ClassPowerList(
              forceAllowed: dto.powerList!.forceAllowed,
              techAllowed: dto.powerList!.techAllowed,
              spellcastingProgression: dto.powerList!.spellcastingProgression,
            )
          : null;

      ClassMulticlassing? multiclassing;
      if (dto.multiclassing != null &&
          dto.multiclassing!.requirements.isNotEmpty) {
        final Map<String, int> abilityRequirements = <String, int>{};
        dto.multiclassing!.requirements.forEach((String abbr, int score) {
          final String slug =
              _abilityAbbrToSlug?[abbr] ?? abbr.toLowerCase().trim();
          if (slug.isEmpty) {
            return;
          }
          abilityRequirements[slug] = score;
        });
        if (abilityRequirements.isNotEmpty) {
          multiclassing = ClassMulticlassing(
            abilityRequirements:
                Map<String, int>.unmodifiable(abilityRequirements),
          );
        }
      }

      final String? rawCreditsRoll = dto.startingCreditsRoll?.trim();
      final String? creditsRoll =
          (rawCreditsRoll == null || rawCreditsRoll.isEmpty)
              ? null
              : rawCreditsRoll;

      mapped[dto.slug] = ClassDef(
        id: dto.slug,
        name: dto.name.toDomain(),
        description: dto.description?.toDomain(),
        hitDie: dto.hitDie,
        level1: ClassLevel1Data(
          proficiencies: ClassLevel1Proficiencies(
            skillsChoose: dto.proficiencies.skillsPick,
            skillsFrom: List<String>.unmodifiable(skillSlugs),
          ),
          startingCredits: dto.startingCredits,
          startingCreditsRoll: creditsRoll,
          startingEquipment:
              List<StartingEquipmentLine>.unmodifiable(startingEquipment),
          startingEquipmentOptions:
              List<LocalizedText>.unmodifiable(startingEquipmentOptions),
          classFeatures: level1Features.isNotEmpty
              ? List<ClassFeature>.unmodifiable(level1Features)
              : const <ClassFeature>[],
        ),
        primaryAbilities: List<String>.unmodifiable(primaryAbilities),
        savingThrows: List<String>.unmodifiable(savingThrows),
        weaponProficiencies:
            List<String>.unmodifiable(dto.proficiencies.weaponCategories),
        armorProficiencies:
            List<String>.unmodifiable(dto.proficiencies.armorCategories),
        toolProficiencies:
            List<String>.unmodifiable(dto.proficiencies.toolProficiencies),
        powerSource: normalizedPowerSource,
        powerList: powerList,
        multiclassing: multiclassing,
      );
    }

    _classes = Map<String, ClassDef>.unmodifiable(mapped);
  }

  Future<void> _ensureBackgrounds() async {
    if (_backgrounds != null) return;
    await _ensureSkills();
    await _ensureEquipment();
    final List<CatalogV2BackgroundDto> v2Dtos =
        await _dataSourceV2.loadBackgrounds();
    final Map<String, BackgroundDef> mapped = <String, BackgroundDef>{};
    for (final CatalogV2BackgroundDto dto in v2Dtos) {
      final List<String> skillSlugs = <String>[];
      for (final String skillId in dto.skillProficiencies) {
        final String? slug = _skillIdToSlug?[skillId];
        if (slug != null && slug.isNotEmpty) {
          skillSlugs.add(slug);
        }
      }

      final BackgroundFeature? feature = dto.feature == null
          ? null
          : BackgroundFeature(
              name: dto.feature!.name.toDomain(),
              effects: dto.feature!.effects
                  .map(
                    (CatalogV2FeatureEffectDto effect) =>
                        CatalogFeatureEffect(
                      id: effect.id,
                      kind: effect.kind,
                      target: effect.target,
                      text: effect.text?.toDomain(),
                    ),
                  )
                  .toList(growable: false),
            );

      final BackgroundPersonality? personality = dto.personality == null
          ? null
          : BackgroundPersonality(
              traits: dto.personality!.traits
                  .map((LocalizedTextDto value) => value.toDomain())
                  .toList(growable: false),
              ideals: dto.personality!.ideals
                  .map((LocalizedTextDto value) => value.toDomain())
                  .toList(growable: false),
              bonds: dto.personality!.bonds
                  .map((LocalizedTextDto value) => value.toDomain())
                  .toList(growable: false),
              flaws: dto.personality!.flaws
                  .map((LocalizedTextDto value) => value.toDomain())
                  .toList(growable: false),
            );

      final List<BackgroundEquipmentGrant> equipment = dto.equipment
          .map((CatalogV2EquipmentGrantDto e) {
            String itemId = e.ref.id.isNotEmpty ? e.ref.id : e.ref.type;
            final String? slug = _equipmentIdToSlug?[itemId];
            if (slug != null && slug.isNotEmpty) {
              itemId = slug;
            }
            return BackgroundEquipmentGrant(
              itemId: itemId,
              refType: e.ref.type,
              quantity: e.quantity,
            );
          })
          .toList(growable: false);
      mapped[dto.slug] = BackgroundDef(
        id: dto.slug,
        name: dto.name.toDomain(),
        grantedSkills: List<String>.unmodifiable(skillSlugs),
        languagesPick: dto.languagesPick,
        toolProficiencies: List<String>.unmodifiable(
          dto.toolProficiencies.map((String value) => value.toLowerCase()),
        ),
        feature: feature,
        personality: personality,
        equipment: List<BackgroundEquipmentGrant>.unmodifiable(equipment),
      );
    }

    _backgrounds = Map<String, BackgroundDef>.unmodifiable(mapped);
  }

  Future<void> _ensureSkills() async {
    if (_skills != null) return;
    await _ensureAbilities();
    final List<CatalogV2SkillDto> dtos = await _dataSourceV2.loadSkills();
    final Map<String, SkillDef> mapped = <String, SkillDef>{};
    final Map<String, String> idToSlug = <String, String>{};
    for (final CatalogV2SkillDto dto in dtos) {
      final String abilitySlug =
          _abilityIdToSlug![dto.abilityRef] ?? dto.abilityRef.toLowerCase();
      idToSlug[dto.id] = dto.slug;
      mapped[dto.slug] = SkillDef(
        id: dto.slug,
        ability: abilitySlug,
        name: dto.name.toDomain(),
      );
    }
    _skills = Map<String, SkillDef>.unmodifiable(mapped);
    _skillIdToSlug = Map<String, String>.unmodifiable(idToSlug);
  }

  Future<void> _ensureEquipment() async {
    if (_equipment != null) return;
    await _ensureDamageTypes();
    final Map<String, EquipmentDef> mapped = <String, EquipmentDef>{};
    final Map<String, String> idToSlug = <String, String>{};

    final List<CatalogV2EquipmentDto> v2Dtos =
        await _dataSourceV2.loadEquipment();
    for (final CatalogV2EquipmentDto dto in v2Dtos) {
      final int cost = dto.costCredits ?? 0;
      final int weightG = dto.weightKg != null
          ? (dto.weightKg! * 1000).round()
          : 0;
      mapped[dto.slug] = EquipmentDef(
        id: dto.slug,
        name: dto.name.toDomain(),
        type: dto.category,
        weightG: weightG,
        cost: cost,
        rarity: dto.rarity,
        description: dto.description?.toDomain(),
        weaponCategory: null,
        weaponDamage: const <WeaponDamage>[],
        weaponRange: null,
        weaponProperties: const <String>[],
      );
      idToSlug[dto.id] = dto.slug;
    }

    final List<CatalogV2WeaponDto> weaponDtos =
        await _dataSourceV2.loadWeapons();
    for (final CatalogV2WeaponDto dto in weaponDtos) {
      final EquipmentDef? existing = mapped[dto.slug];
      final int cost = dto.costCredits ?? existing?.cost ?? 0;
      final int weightG = dto.weightKg != null
          ? (dto.weightKg! * 1000).round()
          : existing?.weightG ?? 0;
      final LocalizedText? description =
          dto.description?.toDomain() ?? existing?.description;
      final String? rarity = dto.rarity ?? existing?.rarity;

      final List<WeaponDamage> damages = <WeaponDamage>[];
      for (final CatalogV2WeaponDamageDto damageDto in dto.damage) {
        final String? typeSlug = _damageTypeIdToSlug?[damageDto.typeRef];
        final DamageTypeDef? damageDef =
            typeSlug != null ? _damageTypes?[typeSlug] : null;
        damages.add(
          WeaponDamage(
            damageType: typeSlug ?? damageDto.typeRef.toLowerCase(),
            damageTypeName: damageDef?.name,
            damageTypeNotes: damageDef?.notes,
            diceCount: damageDto.diceCount,
            diceDie: damageDto.diceDie,
            diceModifier: damageDto.diceModifier,
          ),
        );
      }

      final WeaponRange? range = (dto.rangePrimaryMeters != null ||
              dto.rangeMaxMeters != null)
          ? WeaponRange(
              primary: dto.rangePrimaryMeters,
              maximum: dto.rangeMaxMeters,
            )
          : existing?.weaponRange;

      final List<String> properties = dto.properties.isNotEmpty
          ? List<String>.unmodifiable(dto.properties)
          : (existing?.weaponProperties ?? const <String>[]);

      mapped[dto.slug] = EquipmentDef(
        id: dto.slug,
        name: dto.name.toDomain(),
        type: 'weapon',
        weightG: weightG,
        cost: cost,
        rarity: rarity,
        description: description,
        weaponCategory: dto.category,
        weaponDamage: List<WeaponDamage>.unmodifiable(damages),
        weaponRange: range,
        weaponProperties: properties,
      );
      idToSlug[dto.id] = dto.slug;
    }

    _equipment = Map<String, EquipmentDef>.unmodifiable(mapped);
    _equipmentIdToSlug = Map<String, String>.unmodifiable(idToSlug);
  }

  Future<void> _ensureDamageTypes() async {
    if (_damageTypes != null && _damageTypeIdToSlug != null) return;
    final List<CatalogV2DamageTypeDto> dtos =
        await _dataSourceV2.loadDamageTypes();
    final Map<String, DamageTypeDef> mapped = <String, DamageTypeDef>{};
    final Map<String, String> idToSlug = <String, String>{};
    for (final CatalogV2DamageTypeDto dto in dtos) {
      mapped[dto.slug] = DamageTypeDef(
        id: dto.slug,
        name: dto.name.toDomain(),
        notes: dto.notes?.toDomain(),
      );
      idToSlug[dto.id] = dto.slug;
    }
    _damageTypes = Map<String, DamageTypeDef>.unmodifiable(mapped);
    _damageTypeIdToSlug = Map<String, String>.unmodifiable(idToSlug);
  }

  Future<void> _ensureFormulas() async {
    if (_formulas != null) return;
    final CatalogV2FormulasDto v2Dto = await _dataSourceV2.loadFormulas();
    final Map<String, SuperiorityDiceRule> superiorityDice =
        <String, SuperiorityDiceRule>{};
    v2Dto.superiorityDiceByClass.forEach(
      (String key, CatalogV2SuperiorityDiceRuleDto value) {
        superiorityDice[key] =
            SuperiorityDiceRule(count: value.count, die: value.die);
      },
    );
    _formulas = FormulasDef(
      rulesVersion: v2Dto.rulesVersion,
      hpLevel1: v2Dto.hpLevel1,
      defenseBase: v2Dto.defenseBase,
      initiative: v2Dto.initiative,
      superiorityDiceByClass:
          Map<String, SuperiorityDiceRule>.unmodifiable(superiorityDice),
      attackBonus: v2Dto.attackBonus,
      powerSaveDc: v2Dto.powerSaveDc,
    );
  }

  Future<void> _ensureTraits() async {
    if (_traits != null) return;
    final List<CatalogV2TraitDto> dtos = await _dataSourceV2.loadTraits();
    final Map<String, TraitDef> mapped = <String, TraitDef>{};
    final Map<String, String> idToSlug = <String, String>{};
    for (final CatalogV2TraitDto dto in dtos) {
      mapped[dto.slug] = TraitDef(
        id: dto.slug,
        name: dto.name.toDomain(),
        description: dto.description.toDomain(),
      );
      idToSlug[dto.id] = dto.slug;
    }
    _traits = Map<String, TraitDef>.unmodifiable(mapped);
    _traitIdToSlug = Map<String, String>.unmodifiable(idToSlug);
  }

  Future<void> _ensureCustomizationOptions() async {
    if (_customizationOptions != null) return;
    final List<CatalogV2CustomizationOptionDto> dtos =
        await _dataSourceV2.loadCustomizationOptions();

    final Map<String, CustomizationOptionDef> mapped =
        <String, CustomizationOptionDef>{};
    final Map<String, String> idToSlug = <String, String>{};

    for (final CatalogV2CustomizationOptionDto dto in dtos) {
      final List<CatalogFeatureEffect> effects = dto.effects
          .map(
            (CatalogV2FeatureEffectDto effect) => CatalogFeatureEffect(
              id: effect.id,
              kind: effect.kind,
              target: effect.target,
              text: effect.text?.toDomain(),
            ),
          )
          .toList(growable: false);

      final CustomizationPrerequisite? prerequisite =
          _mapCustomizationPrerequisite(dto.prerequisite);

      mapped[dto.slug] = CustomizationOptionDef(
        id: dto.slug,
        name: dto.name.toDomain(),
        category: dto.category,
        effects: List<CatalogFeatureEffect>.unmodifiable(effects),
        prerequisite: prerequisite,
      );

      if (dto.id.isNotEmpty) {
        idToSlug[dto.id] = dto.slug;
      }
    }

    _customizationOptions =
        Map<String, CustomizationOptionDef>.unmodifiable(mapped);
    _customizationOptionIdToSlug = Map<String, String>.unmodifiable(idToSlug);
  }

  Future<void> _ensureForcePowers() async {
    if (_forcePowers != null && _forcePowerIdToSlug != null) {
      return;
    }
    final List<CatalogV2PowerDto> dtos = await _dataSourceV2.loadForcePowers();
    final Map<String, PowerDef> mapped = <String, PowerDef>{};
    final Map<String, String> idToSlug = <String, String>{};
    for (final CatalogV2PowerDto dto in dtos) {
      if (dto.slug.isEmpty) {
        continue;
      }
      mapped[dto.slug] = _mapPowerDto(dto, 'force');
      if (dto.id.isNotEmpty) {
        idToSlug[dto.id] = dto.slug;
      }
    }
    _forcePowers = Map<String, PowerDef>.unmodifiable(mapped);
    _forcePowerIdToSlug = Map<String, String>.unmodifiable(idToSlug);
  }

  Future<void> _ensureTechPowers() async {
    if (_techPowers != null && _techPowerIdToSlug != null) {
      return;
    }
    final List<CatalogV2PowerDto> dtos = await _dataSourceV2.loadTechPowers();
    final Map<String, PowerDef> mapped = <String, PowerDef>{};
    final Map<String, String> idToSlug = <String, String>{};
    for (final CatalogV2PowerDto dto in dtos) {
      if (dto.slug.isEmpty) {
        continue;
      }
      mapped[dto.slug] = _mapPowerDto(dto, 'tech');
      if (dto.id.isNotEmpty) {
        idToSlug[dto.id] = dto.slug;
      }
    }
    _techPowers = Map<String, PowerDef>.unmodifiable(mapped);
    _techPowerIdToSlug = Map<String, String>.unmodifiable(idToSlug);
  }

  CustomizationPrerequisite? _mapCustomizationPrerequisite(
    CatalogV2CustomizationPrerequisiteDto? dto,
  ) {
    if (dto == null) {
      return null;
    }

    final List<CustomizationPrerequisite> all = <CustomizationPrerequisite>[];
    for (final CatalogV2CustomizationPrerequisiteDto child in dto.all) {
      final CustomizationPrerequisite? mapped =
          _mapCustomizationPrerequisite(child);
      if (mapped != null && !mapped.isEmpty) {
        all.add(mapped);
      }
    }

    final List<CustomizationPrerequisite> any = <CustomizationPrerequisite>[];
    for (final CatalogV2CustomizationPrerequisiteDto child in dto.any) {
      final CustomizationPrerequisite? mapped =
          _mapCustomizationPrerequisite(child);
      if (mapped != null && !mapped.isEmpty) {
        any.add(mapped);
      }
    }

    CustomizationPrerequisiteCondition? condition;
    if (dto.condition != null) {
      condition = CustomizationPrerequisiteCondition(
        classId: dto.condition!.classId,
        minLevel: dto.condition!.minLevel,
        optionId: dto.condition!.optionId,
        traitId: dto.condition!.traitId,
        speciesId: dto.condition!.speciesId,
        backgroundId: dto.condition!.backgroundId,
        raw: dto.condition!.raw,
      );
    }

    if (all.isEmpty && any.isEmpty && condition == null) {
      return null;
    }

    return CustomizationPrerequisite(
      all: List<CustomizationPrerequisite>.unmodifiable(all),
      any: List<CustomizationPrerequisite>.unmodifiable(any),
      condition: condition,
    );
  }

  Future<void> _ensureLanguages() async {
    if (_languages != null && _languageIdToSlug != null) return;
    final List<CatalogV2LanguageDto> dtos = await _dataSourceV2.loadLanguages();
    final Map<String, LanguageDef> mapped = <String, LanguageDef>{};
    final Map<String, String> idToSlug = <String, String>{};
    for (final CatalogV2LanguageDto dto in dtos) {
      final String slug = dto.slug;
      final List<LanguageTypicalSpeaker> speakers = dto.typicalSpeakers
          .map(
            (CatalogV2LanguageSpeakerDto speaker) => LanguageTypicalSpeaker(
              type: speaker.type,
              id: speaker.id,
              name: speaker.name?.toDomain(),
            ),
          )
          .toList(growable: false);
      mapped[slug] = LanguageDef(
        id: slug,
        name: dto.name.toDomain(),
        description: dto.description?.toDomain(),
        script: dto.script?.toDomain(),
        typicalSpeakers:
            List<LanguageTypicalSpeaker>.unmodifiable(speakers),
      );
      idToSlug[dto.id] = slug;
    }
    _languages = Map<String, LanguageDef>.unmodifiable(mapped);
    _languageIdToSlug = Map<String, String>.unmodifiable(idToSlug);
  }

  Future<void> _ensureAbilities() async {
    if (_abilityIdToSlug != null &&
        _abilityAbbrToSlug != null &&
        _abilityNames != null &&
        _abilities != null) {
      return;
    }
    final List<CatalogV2AbilityDto> dtos = await _dataSourceV2.loadAbilities();
    final Map<String, String> idToSlug = <String, String>{};
    final Map<String, String> abbrToSlug = <String, String>{};
    final Map<String, LocalizedText> names = <String, LocalizedText>{};
    final Map<String, AbilityDef> abilities = <String, AbilityDef>{};
    for (final CatalogV2AbilityDto dto in dtos) {
      idToSlug[dto.id] = dto.slug;
      abbrToSlug[dto.abbr] = dto.slug;
      final LocalizedText name = dto.name.toDomain();
      names[dto.slug] = name;
      abilities[dto.slug] = AbilityDef(
        id: dto.slug,
        abbreviation: dto.abbr,
        name: name,
        description: dto.description?.toDomain(),
      );
    }
    _abilityIdToSlug = Map<String, String>.unmodifiable(idToSlug);
    _abilityAbbrToSlug = Map<String, String>.unmodifiable(abbrToSlug);
    _abilityNames = Map<String, LocalizedText>.unmodifiable(names);
    _abilities = Map<String, AbilityDef>.unmodifiable(abilities);
    _refreshAbilityLocalization(names);
  }

  void _refreshAbilityLocalization(Map<String, LocalizedText> names) {
    if (names.isEmpty) {
      return;
    }
    SpeciesEffectLocalizationCatalog.updateAbilityNames(names);
  }

  LocalizedText? _resolveSpeciesLanguages(CatalogV2SpeciesDto dto) {
    if (dto.languageIds.isEmpty || _languages == null || _languageIdToSlug == null) {
      return null;
    }
    final List<String> enNames = <String>[];
    final List<String> frNames = <String>[];
    for (final String id in dto.languageIds) {
      final String? slug = _languageIdToSlug![id];
      if (slug == null) {
        continue;
      }
      final LanguageDef? language = _languages![slug];
      if (language == null) {
        continue;
      }
      final LocalizedText name = language.name;
      final String? en = name.maybeResolve('en');
      final String? fr =
          name.maybeResolve('fr', fallbackLanguageCode: 'en');
      if (en != null && en.trim().isNotEmpty) {
        enNames.add(en.trim());
      }
      if (fr != null && fr.trim().isNotEmpty) {
        frNames.add(fr.trim());
      }
    }
    if (enNames.isEmpty && frNames.isEmpty) {
      return null;
    }
    return LocalizedText(
      en: enNames.join(', '),
      fr: frNames.isEmpty ? enNames.join(', ') : frNames.join(', '),
    );
  }

  List<String> _resolveSpeciesLanguageSlugs(CatalogV2SpeciesDto dto) {
    if (dto.languageIds.isEmpty || _languageIdToSlug == null) {
      return const <String>[];
    }
    final Set<String> slugs = <String>{};
    for (final String id in dto.languageIds) {
      final String? slug = _languageIdToSlug![id];
      if (slug != null && !_isEmpty(slug)) {
        slugs.add(slug);
      }
    }
    return List<String>.unmodifiable(slugs);
  }

  bool _isEmpty(String value) => value.trim().isEmpty;

  int _metersToFeet(double? meters) {
    if (meters == null) {
      return 0;
    }
    return (meters * 3.28084).round();
  }

  PowerDef _mapPowerDto(CatalogV2PowerDto dto, String powerType) {
    CatalogPowerRange? range;
    if (dto.range != null) {
      final double? meters = dto.range!.distanceMeters;
      final int? metersRounded = meters == null ? null : meters.round();
      final int? feet = meters == null ? null : _metersToFeet(meters);
      range = CatalogPowerRange(
        type: dto.range!.type,
        distanceMeters: metersRounded,
        distanceFeet: feet,
      );
    }

    CatalogPowerDuration? duration;
    if (dto.duration != null) {
      duration = CatalogPowerDuration(
        unit: dto.duration!.unit,
        value: dto.duration!.value,
        concentration: dto.duration!.concentration,
      );
    }

    final List<CatalogFeatureEffect> effects = dto.effects
        .map(
          (CatalogV2FeatureEffectDto effect) => CatalogFeatureEffect(
            id: effect.id,
            kind: effect.kind,
            target: effect.target,
            text: effect.text?.toDomain(),
          ),
        )
        .toList(growable: false);

    final List<CatalogPowerClassRef> classes = dto.classes
        .map(
          (CatalogV2PowerClassRefDto entry) => CatalogPowerClassRef(
            type: entry.type,
            id: entry.id,
          ),
        )
        .toList(growable: false);

    return PowerDef(
      id: dto.slug,
      powerType: powerType,
      name: dto.name.toDomain(),
      level: dto.level,
      castingTime: dto.castingTime,
      range: range,
      duration: duration,
      components: List<String>.unmodifiable(dto.components),
      description: dto.description.toDomain(),
      effects: List<CatalogFeatureEffect>.unmodifiable(effects),
      classes: List<CatalogPowerClassRef>.unmodifiable(classes),
      alignment: dto.alignment,
      school: dto.school,
    );
  }
}
