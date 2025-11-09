/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/services/catalog_lookup_service.dart
/// Rôle : Centraliser le chargement des libellés/définitions associés aux
///        personnages sauvegardés (espèces, classes, historiques, etc.) en
///        s'appuyant sur le catalogue v2.
/// Dépendances : CatalogRepository (accès aux données), AppLogger (traces).
/// Exemple d'usage :
///   final lookups = await CatalogLookupService(catalog: repo, logger: logger)
///       .buildForCharacters(characters);
/// ---------------------------------------------------------------------------
library;

import 'package:meta/meta.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_trait.dart';
import 'package:sw5e_manager/domain/characters/value_objects/skill_proficiency.dart';

/// Contient les dictionnaires nécessaires pour résoudre les identifiants de
/// catalogue en libellés localisés/definitions complètes.
@immutable
class CatalogLookupResult {
  const CatalogLookupResult({
    required this.speciesDefinitions,
    required this.speciesNames,
    required this.classNames,
    required this.classDefinitions,
    required this.backgroundNames,
    required this.backgroundDefinitions,
    required this.skillDefinitions,
    required this.equipmentDefinitions,
    required this.traitDefinitions,
    required this.languageDefinitions,
    required this.abilityDefinitions,
    required this.customizationOptionDefinitions,
    required this.forcePowerDefinitions,
    required this.techPowerDefinitions,
  });

  const CatalogLookupResult.empty()
      : speciesDefinitions = const <String, SpeciesDef>{},
        speciesNames = const <String, LocalizedText>{},
        classNames = const <String, LocalizedText>{},
        classDefinitions = const <String, ClassDef>{},
        backgroundNames = const <String, LocalizedText>{},
        backgroundDefinitions = const <String, BackgroundDef>{},
        skillDefinitions = const <String, SkillDef>{},
        equipmentDefinitions = const <String, EquipmentDef>{},
        traitDefinitions = const <String, TraitDef>{},
        languageDefinitions = const <String, LanguageDef>{},
        abilityDefinitions = const <String, AbilityDef>{},
        customizationOptionDefinitions =
            const <String, CustomizationOptionDef>{},
        forcePowerDefinitions = const <String, PowerDef>{},
        techPowerDefinitions = const <String, PowerDef>{};

  final Map<String, SpeciesDef> speciesDefinitions;
  final Map<String, LocalizedText> speciesNames;
  final Map<String, LocalizedText> classNames;
  final Map<String, ClassDef> classDefinitions;
  final Map<String, LocalizedText> backgroundNames;
  final Map<String, BackgroundDef> backgroundDefinitions;
  final Map<String, SkillDef> skillDefinitions;
  final Map<String, EquipmentDef> equipmentDefinitions;
  final Map<String, TraitDef> traitDefinitions;
  final Map<String, LanguageDef> languageDefinitions;
  final Map<String, AbilityDef> abilityDefinitions;
  final Map<String, CustomizationOptionDef> customizationOptionDefinitions;
  final Map<String, PowerDef> forcePowerDefinitions;
  final Map<String, PowerDef> techPowerDefinitions;
}

/// Service utilitaire chargé de préparer les tables de correspondance utilisées
/// par les écrans (ex : page des personnages sauvegardés, résumé, partage).
class CatalogLookupService {
  CatalogLookupService({
    required CatalogRepository catalog,
    AppLogger? logger,
  })  : _catalog = catalog,
        _logger = logger ?? _NoopAppLogger();

  final CatalogRepository _catalog;
  final AppLogger _logger;

  /// Construit les correspondances nécessaires pour une liste de [characters].
  ///
  /// Le service ne lève pas d'exception : si un identifiant est introuvable dans
  /// le catalogue, il est simplement ignoré (avec un log `warn`).
  Future<CatalogLookupResult> buildForCharacters({
    required List<Character> characters,
  }) async {
    if (characters.isEmpty) {
      return const CatalogLookupResult.empty();
    }

    final Set<String> speciesIds = <String>{};
    final Set<String> classIds = <String>{};
    final Set<String> backgroundIds = <String>{};
    final Set<String> skillIds = <String>{};
    final Set<String> equipmentIds = <String>{};
    final Set<String> traitIds = <String>{};
    final Set<String> languageIds = <String>{};
    final Set<String> abilityIds = <String>{};
    final Set<String> customizationOptionIds = <String>{};
    final Set<String> forcePowerIds = <String>{};
    final Set<String> techPowerIds = <String>{};

    for (final Character character in characters) {
      speciesIds.add(character.speciesId.value);
      classIds.add(character.classId.value);
      backgroundIds.add(character.backgroundId.value);
      for (final SkillProficiency proficiency in character.skills) {
        skillIds.add(proficiency.skillId);
      }
      for (final InventoryLine line in character.inventory) {
        equipmentIds.add(line.itemId.value);
      }
      for (final CharacterTrait trait in character.speciesTraits) {
        traitIds.add(trait.id.value);
      }
      abilityIds.addAll(
        character.abilities.keys.map((String key) => key.toLowerCase()),
      );
      customizationOptionIds.addAll(character.customizationOptionIds);
      forcePowerIds.addAll(character.forcePowerIds);
      techPowerIds.addAll(character.techPowerIds);
    }

    final Map<String, SpeciesDef> speciesDefinitions =
        <String, SpeciesDef>{};
    final Map<String, LocalizedText> speciesNames = <String, LocalizedText>{};
    final Map<String, LocalizedText> classNames = <String, LocalizedText>{};
    final Map<String, ClassDef> classDefinitions = <String, ClassDef>{};
    final Map<String, LocalizedText> backgroundNames =
        <String, LocalizedText>{};
    final Map<String, BackgroundDef> backgroundDefinitions =
        <String, BackgroundDef>{};
    final Map<String, SkillDef> skillDefinitions = <String, SkillDef>{};
    final Map<String, EquipmentDef> equipmentDefinitions =
        <String, EquipmentDef>{};
    final Map<String, TraitDef> traitDefinitions = <String, TraitDef>{};
    final Map<String, LanguageDef> languageDefinitions =
        <String, LanguageDef>{};
    final Map<String, AbilityDef> abilityDefinitions = <String, AbilityDef>{};
    final Map<String, CustomizationOptionDef> customizationDefinitions =
        <String, CustomizationOptionDef>{};
    final Map<String, PowerDef> forcePowerDefinitions = <String, PowerDef>{};
    final Map<String, PowerDef> techPowerDefinitions = <String, PowerDef>{};

    for (final String id in speciesIds) {
      try {
        final SpeciesDef? def = await _catalog.getSpecies(id);
        if (def != null) {
          speciesDefinitions[id] = def;
          speciesNames[id] = def.name;
          languageIds.addAll(def.languageIds);
        }
      } catch (error, stackTrace) {
        _logger.warn(
          'CatalogLookupService.lookup: species introuvable',
          payload: {'speciesId': id},
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    for (final String id in classIds) {
      try {
        final ClassDef? def = await _catalog.getClass(id);
        if (def != null) {
          classNames[id] = def.name;
          classDefinitions[id] = def;
          final ClassMulticlassing? multiclassing = def.multiclassing;
          if (multiclassing != null &&
              multiclassing.hasAbilityRequirements) {
            abilityIds.addAll(multiclassing.abilityRequirements.keys);
          }
        }
      } catch (error, stackTrace) {
        _logger.warn(
          'CatalogLookupService.lookup: classe introuvable',
          payload: {'classId': id},
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    for (final String id in backgroundIds) {
      try {
        final BackgroundDef? def = await _catalog.getBackground(id);
        if (def != null) {
          backgroundNames[id] = def.name;
          backgroundDefinitions[id] = def;
          for (final BackgroundEquipmentGrant grant in def.equipment) {
            if (equipmentDefinitions.containsKey(grant.itemId)) {
              continue;
            }
            try {
              final EquipmentDef? equipment =
                  await _catalog.getEquipment(grant.itemId);
              if (equipment != null) {
                equipmentDefinitions[grant.itemId] = equipment;
              }
            } catch (error, stackTrace) {
              _logger.warn(
                'CatalogLookupService.lookup: équipement de background introuvable',
                payload: {
                  'backgroundId': id,
                  'equipmentId': grant.itemId,
                },
                error: error,
                stackTrace: stackTrace,
              );
            }
          }
          for (final String toolId in def.toolProficiencies) {
            if (equipmentDefinitions.containsKey(toolId)) {
              continue;
            }
            try {
              final EquipmentDef? tool = await _catalog.getEquipment(toolId);
              if (tool != null) {
                equipmentDefinitions[toolId] = tool;
              }
            } catch (error, stackTrace) {
              _logger.warn(
                'CatalogLookupService.lookup: outil de background introuvable',
                payload: {
                  'backgroundId': id,
                  'toolId': toolId,
                },
                error: error,
                stackTrace: stackTrace,
              );
            }
          }
        }
      } catch (error, stackTrace) {
        _logger.warn(
          'CatalogLookupService.lookup: background introuvable',
          payload: {'backgroundId': id},
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    for (final String id in skillIds) {
      try {
        final SkillDef? def = await _catalog.getSkill(id);
        if (def != null) {
          skillDefinitions[id] = def;
        }
      } catch (error, stackTrace) {
        _logger.warn(
          'CatalogLookupService.lookup: skill introuvable',
          payload: {'skillId': id},
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    for (final String id in equipmentIds) {
      try {
        final EquipmentDef? def = await _catalog.getEquipment(id);
        if (def != null) {
          equipmentDefinitions[id] = def;
        }
      } catch (error, stackTrace) {
        _logger.warn(
          'CatalogLookupService.lookup: équipement introuvable',
          payload: {'equipmentId': id},
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    for (final String id in traitIds) {
      try {
        final TraitDef? def = await _catalog.getTrait(id);
        if (def != null) {
          traitDefinitions[id] = def;
        }
      } catch (error, stackTrace) {
        _logger.warn(
          'CatalogLookupService.lookup: trait introuvable',
          payload: {'traitId': id},
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    for (final String id in abilityIds) {
      if (abilityDefinitions.containsKey(id)) {
        continue;
      }
      try {
        final AbilityDef? def = await _catalog.getAbility(id);
        if (def != null) {
          abilityDefinitions[id] = def;
        }
      } catch (error, stackTrace) {
        _logger.warn(
          'CatalogLookupService.lookup: ability introuvable',
          payload: {'abilityId': id},
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    for (final String id in customizationOptionIds) {
      if (customizationDefinitions.containsKey(id)) {
        continue;
      }
      try {
        final CustomizationOptionDef? def =
            await _catalog.getCustomizationOption(id);
        if (def != null) {
          customizationDefinitions[id] = def;
        }
      } catch (error, stackTrace) {
        _logger.warn(
          'CatalogLookupService.lookup: customization option introuvable',
          payload: {'optionId': id},
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    for (final String id in forcePowerIds) {
      if (forcePowerDefinitions.containsKey(id)) {
        continue;
      }
      try {
        final PowerDef? def = await _catalog.getForcePower(id);
        if (def != null) {
          forcePowerDefinitions[id] = def;
        }
      } catch (error, stackTrace) {
        _logger.warn(
          'CatalogLookupService.lookup: pouvoir de Force introuvable',
          payload: {'powerId': id},
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    for (final String id in techPowerIds) {
      if (techPowerDefinitions.containsKey(id)) {
        continue;
      }
      try {
        final PowerDef? def = await _catalog.getTechPower(id);
        if (def != null) {
          techPowerDefinitions[id] = def;
        }
      } catch (error, stackTrace) {
        _logger.warn(
          'CatalogLookupService.lookup: pouvoir technologique introuvable',
          payload: {'powerId': id},
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    for (final String id in languageIds) {
      if (languageDefinitions.containsKey(id)) {
        continue;
      }
      try {
        final LanguageDef? def = await _catalog.getLanguage(id);
        if (def != null) {
          languageDefinitions[id] = def;
        }
      } catch (error, stackTrace) {
        _logger.warn(
          'CatalogLookupService.lookup: langue introuvable',
          payload: {'languageId': id},
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    return CatalogLookupResult(
      speciesDefinitions:
          Map<String, SpeciesDef>.unmodifiable(speciesDefinitions),
      speciesNames: Map<String, LocalizedText>.unmodifiable(speciesNames),
      classNames: Map<String, LocalizedText>.unmodifiable(classNames),
      classDefinitions: Map<String, ClassDef>.unmodifiable(classDefinitions),
      backgroundNames:
          Map<String, LocalizedText>.unmodifiable(backgroundNames),
      backgroundDefinitions:
          Map<String, BackgroundDef>.unmodifiable(backgroundDefinitions),
      skillDefinitions: Map<String, SkillDef>.unmodifiable(skillDefinitions),
      equipmentDefinitions:
          Map<String, EquipmentDef>.unmodifiable(equipmentDefinitions),
      traitDefinitions: Map<String, TraitDef>.unmodifiable(traitDefinitions),
      languageDefinitions:
          Map<String, LanguageDef>.unmodifiable(languageDefinitions),
      abilityDefinitions:
          Map<String, AbilityDef>.unmodifiable(abilityDefinitions),
      customizationOptionDefinitions:
          Map<String, CustomizationOptionDef>.unmodifiable(
        customizationDefinitions,
      ),
      forcePowerDefinitions:
          Map<String, PowerDef>.unmodifiable(forcePowerDefinitions),
      techPowerDefinitions:
          Map<String, PowerDef>.unmodifiable(techPowerDefinitions),
    );
  }
}

class _NoopAppLogger implements AppLogger {
  @override
  void error(String message, {Object? payload, Object? error, StackTrace? stackTrace}) {}

  @override
  void info(String message, {Object? payload}) {}

  @override
  void warn(String message, {Object? payload, Object? error, StackTrace? stackTrace}) {}
}
