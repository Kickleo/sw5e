/// ---------------------------------------------------------------------------
/// Fichier : lib/data/catalog_v2/data_sources/asset_bundle_catalog_v2_data_source.dart
/// Rôle : Charger les JSON du catalogue v2 depuis les assets Flutter.
/// Dépendances : AssetBundle et DTOs v2.
/// Exemple :
///   final source = AssetBundleCatalogV2DataSource();
///   final species = await source.loadSpecies();
/// ---------------------------------------------------------------------------
library;

import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'package:sw5e_manager/data/catalog_v2/dtos/catalog_v2_dtos.dart';

class AssetBundleCatalogV2DataSource {
  AssetBundleCatalogV2DataSource({AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<List<CatalogV2AbilityDto>> loadAbilities() async {
    final List<Map<String, dynamic>> raw =
        await _loadArray('assets/catalog_v2/abilities.json');
    return raw.map(CatalogV2AbilityDto.fromJson).toList(growable: false);
  }

  Future<List<CatalogV2SkillDto>> loadSkills() async {
    final List<Map<String, dynamic>> raw =
        await _loadArray('assets/catalog_v2/skills.json');
    return raw.map(CatalogV2SkillDto.fromJson).toList(growable: false);
  }

  Future<List<CatalogV2LanguageDto>> loadLanguages() async {
    final List<Map<String, dynamic>> raw =
        await _loadArray('assets/catalog_v2/languages.json');
    return raw.map(CatalogV2LanguageDto.fromJson).toList(growable: false);
  }

  Future<List<CatalogV2CustomizationOptionDto>> loadCustomizationOptions() async {
    final List<Map<String, dynamic>> raw =
        await _loadArray('assets/catalog_v2/customization_options.json');
    return raw
        .map(CatalogV2CustomizationOptionDto.fromJson)
        .toList(growable: false);
  }

  Future<List<CatalogV2PowerDto>> loadForcePowers() async {
    final List<Map<String, dynamic>> raw =
        await _loadArray('assets/catalog_v2/force_powers.json');
    return raw.map(CatalogV2PowerDto.fromJson).toList(growable: false);
  }

  Future<List<CatalogV2PowerDto>> loadTechPowers() async {
    final List<Map<String, dynamic>> raw =
        await _loadArray('assets/catalog_v2/tech_powers.json');
    return raw.map(CatalogV2PowerDto.fromJson).toList(growable: false);
  }

  Future<List<CatalogV2EquipmentDto>> loadEquipment() async {
    final List<Map<String, dynamic>> raw =
        await _loadArray('assets/catalog_v2/equipment.json');
    return raw.map(CatalogV2EquipmentDto.fromJson).toList(growable: false);
  }

  Future<List<CatalogV2WeaponDto>> loadWeapons() async {
    final List<Map<String, dynamic>> raw =
        await _loadArray('assets/catalog_v2/weapons.json');
    return raw.map(CatalogV2WeaponDto.fromJson).toList(growable: false);
  }

  Future<List<CatalogV2DamageTypeDto>> loadDamageTypes() async {
    final List<Map<String, dynamic>> raw =
        await _loadArray('assets/catalog_v2/damage_types.json');
    return raw.map(CatalogV2DamageTypeDto.fromJson).toList(growable: false);
  }

  Future<List<CatalogV2ClassDto>> loadClasses() async {
    final List<Map<String, dynamic>> raw =
        await _loadArray('assets/catalog_v2/classes.json');
    return raw.map(CatalogV2ClassDto.fromJson).toList(growable: false);
  }

  Future<List<CatalogV2BackgroundDto>> loadBackgrounds() async {
    final List<Map<String, dynamic>> raw =
        await _loadArray('assets/catalog_v2/backgrounds.json');
    return raw.map(CatalogV2BackgroundDto.fromJson).toList(growable: false);
  }

  Future<List<CatalogV2TraitDto>> loadTraits() async {
    final List<Map<String, dynamic>> raw =
        await _loadArray('assets/catalog_v2/traits.json');
    return raw.map(CatalogV2TraitDto.fromJson).toList(growable: false);
  }

  Future<List<CatalogV2SpeciesDto>> loadSpecies() async {
    final List<Map<String, dynamic>> raw =
        await _loadArray('assets/catalog_v2/species.json');
    return raw.map(CatalogV2SpeciesDto.fromJson).toList(growable: false);
  }

  Future<CatalogV2FormulasDto> loadFormulas() async {
    final Map<String, dynamic> raw =
        await _loadObject('assets/catalog_v2/formulas.json');
    return CatalogV2FormulasDto.fromJson(raw);
  }

  Future<List<Map<String, dynamic>>> _loadArray(String path) async {
    final String content = await _bundle.loadString(path);
    final dynamic json = jsonDecode(content);
    if (json is! List) {
      throw StateError('$path must decode to a JSON array');
    }
    return json.map<Map<String, dynamic>>((dynamic entry) {
      if (entry is! Map) {
        throw StateError('$path must contain only JSON objects');
      }
      return Map<String, dynamic>.from(entry);
    }).toList(growable: false);
  }

  Future<Map<String, dynamic>> _loadObject(String path) async {
    final String content = await _bundle.loadString(path);
    final dynamic json = jsonDecode(content);
    if (json is! Map) {
      throw StateError('$path must decode to a JSON object');
    }
    return Map<String, dynamic>.from(json);
  }
}
