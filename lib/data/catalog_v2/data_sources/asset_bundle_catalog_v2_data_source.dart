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

  Future<List<Map<String, dynamic>>> _loadArray(String path) async {
    final String content = await _bundle.loadString(path);
    final dynamic json = jsonDecode(content);
    if (json is! List) {
      throw StateError('$path must decode to a JSON array');
    }
    return List<Map<String, dynamic>>.from(
      json.map((dynamic e) => Map<String, dynamic>.from(e as Map)),
    );
  }
}
