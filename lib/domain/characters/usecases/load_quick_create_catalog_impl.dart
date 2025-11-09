/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/load_quick_create_catalog_impl.dart
/// Rôle : Implémenter [LoadQuickCreateCatalog] à partir du [CatalogRepository].
/// Dépendances : CatalogRepository (port), Result/DomainError pour la gestion
///        d'erreur, entités de catalogue.
/// Exemple d'usage :
///   final useCase = LoadQuickCreateCatalogImpl(repository);
// ignore: unintended_html_in_doc_comment
///   final AppResult<QuickCreateCatalogSnapshot> result = await useCase();
/// ---------------------------------------------------------------------------
library;
import 'package:collection/collection.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

import 'package:sw5e_manager/domain/characters/usecases/load_quick_create_catalog.dart';

/// Implémentation par défaut utilisant le catalogue hors-ligne.
class LoadQuickCreateCatalogImpl implements LoadQuickCreateCatalog {
  /// Crée l'implémentation.
  LoadQuickCreateCatalogImpl(this._catalog);

  final CatalogRepository _catalog;

  @override
  Future<AppResult<QuickCreateCatalogSnapshot>> call() async {
    try {
      final List<String> species = await _catalog.listSpecies();
      final Map<String, LocalizedText> speciesLabels = <String, LocalizedText>{};
      for (final String id in species) {
        final SpeciesDef? def = await _catalog.getSpecies(id);
        if (def != null) {
          speciesLabels[id] = def.name;
        }
      }
      final List<String> sortedSpecies = List<String>.from(species)
        ..sort(
          (String a, String b) =>
              _compareLocalizedIds(speciesLabels[a], speciesLabels[b], a, b),
        );

      final List<String> classes = await _catalog.listClasses();
      final Map<String, LocalizedText> classLabels = <String, LocalizedText>{};
      for (final String id in classes) {
        final ClassDef? def = await _catalog.getClass(id);
        if (def != null) {
          classLabels[id] = def.name;
        }
      }
      final List<String> sortedClasses = List<String>.from(classes)
        ..sort(
          (String a, String b) =>
              _compareLocalizedIds(classLabels[a], classLabels[b], a, b),
        );

      final List<String> backgrounds = await _catalog.listBackgrounds();
      final Map<String, LocalizedText> backgroundLabels =
          <String, LocalizedText>{};
      for (final String id in backgrounds) {
        final BackgroundDef? def = await _catalog.getBackground(id);
        if (def != null) {
          backgroundLabels[id] = def.name;
        }
      }
      final List<String> sortedBackgrounds = List<String>.from(backgrounds)
        ..sort(
          (String a, String b) => _compareLocalizedIds(
            backgroundLabels[a],
            backgroundLabels[b],
            a,
            b,
          ),
        );

      final List<String> equipmentIds = await _catalog.listEquipment();
      final Map<String, EquipmentDef> equipmentById = <String, EquipmentDef>{};
      for (final String id in equipmentIds) {
        final EquipmentDef? def = await _catalog.getEquipment(id);
        if (def != null) {
          equipmentById[id] = def;
        }
      }

      final List<EquipmentDef> sortedEquipment = equipmentById.values.toList()
        ..sort(_compareEquipmentByLocalizedName);
      final List<String> sortedIds =
          sortedEquipment.map((EquipmentDef def) => def.id).toList();

      final List<String> abilityIds = await _catalog.listAbilities();
      final Map<String, AbilityDef> abilityDefinitions =
          <String, AbilityDef>{};
      for (final String id in abilityIds) {
        final AbilityDef? def = await _catalog.getAbility(id);
        if (def != null) {
          abilityDefinitions[id] = def;
        }
      }

      final List<String> languageIds = await _catalog.listLanguages();
      final Map<String, LanguageDef> languageDefinitions = <String, LanguageDef>{};
      for (final String id in languageIds) {
        final LanguageDef? def = await _catalog.getLanguage(id);
        if (def != null) {
          languageDefinitions[id] = def;
        }
      }

      final List<String> customizationIds =
          await _catalog.listCustomizationOptions();
      final Map<String, CustomizationOptionDef> customizationDefinitions =
          <String, CustomizationOptionDef>{};
      for (final String id in customizationIds) {
        final CustomizationOptionDef? def =
            await _catalog.getCustomizationOption(id);
        if (def != null) {
          customizationDefinitions[id] = def;
        }
      }

      final List<String> forcePowerIds = await _catalog.listForcePowers();
      final Map<String, PowerDef> forcePowerDefinitions = <String, PowerDef>{};
      for (final String id in forcePowerIds) {
        final PowerDef? def = await _catalog.getForcePower(id);
        if (def != null) {
          forcePowerDefinitions[id] = def;
        }
      }

      final List<String> techPowerIds = await _catalog.listTechPowers();
      final Map<String, PowerDef> techPowerDefinitions = <String, PowerDef>{};
      for (final String id in techPowerIds) {
        final PowerDef? def = await _catalog.getTechPower(id);
        if (def != null) {
          techPowerDefinitions[id] = def;
        }
      }

      return appOk(
        QuickCreateCatalogSnapshot(
          speciesIds: List<String>.unmodifiable(sortedSpecies),
          speciesNames: Map<String, LocalizedText>.unmodifiable(speciesLabels),
          classIds: List<String>.unmodifiable(sortedClasses),
          classNames: Map<String, LocalizedText>.unmodifiable(classLabels),
          backgroundIds: List<String>.unmodifiable(sortedBackgrounds),
          backgroundNames:
              Map<String, LocalizedText>.unmodifiable(backgroundLabels),
          equipmentById: Map<String, EquipmentDef>.unmodifiable(equipmentById),
          sortedEquipmentIds: List<String>.unmodifiable(sortedIds),
          abilityDefinitions:
              Map<String, AbilityDef>.unmodifiable(abilityDefinitions),
          languageDefinitions:
              Map<String, LanguageDef>.unmodifiable(languageDefinitions),
          customizationOptionDefinitions:
              Map<String, CustomizationOptionDef>.unmodifiable(
            customizationDefinitions,
          ),
          forcePowerDefinitions:
              Map<String, PowerDef>.unmodifiable(forcePowerDefinitions),
          techPowerDefinitions:
              Map<String, PowerDef>.unmodifiable(techPowerDefinitions),
          defaultSpeciesId: sortedSpecies.firstOrNull,
          defaultClassId: sortedClasses.firstOrNull,
          defaultBackgroundId: sortedBackgrounds.firstOrNull,
        ),
      );
    } catch (error, _) {
      return appErr(
        DomainError(
          'CatalogLoadFailed',
          message: error.toString(),
        ),
      );
    }
  }

  int _compareEquipmentByLocalizedName(EquipmentDef a, EquipmentDef b) {
    final String keyA = _sortKeyFromLocalized(a.name, a.id);
    final String keyB = _sortKeyFromLocalized(b.name, b.id);
    final int cmp = keyA.compareTo(keyB);
    if (cmp != 0) {
      return cmp;
    }
    return a.id.compareTo(b.id);
  }

  int _compareLocalizedIds(
    LocalizedText? a,
    LocalizedText? b,
    String fallbackA,
    String fallbackB,
  ) {
    final String keyA = _sortKeyFromLocalized(a, fallbackA);
    final String keyB = _sortKeyFromLocalized(b, fallbackB);
    final int cmp = keyA.compareTo(keyB);
    if (cmp != 0) {
      return cmp;
    }
    return fallbackA.compareTo(fallbackB);
  }

  String _sortKeyFromLocalized(LocalizedText? text, String fallback) {
    if (text != null) {
      final String resolved =
          text.resolve('en', fallbackLanguageCode: 'fr').trim();
      if (resolved.isNotEmpty) {
        return resolved.toLowerCase();
      }
    }
    return fallback.toLowerCase();
  }
}
