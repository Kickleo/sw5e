/// ---------------------------------------------------------------------------
/// Fichier : lib/data/catalog/data_sources/asset_bundle_catalog_data_source.dart
/// Rôle : Charger les JSON du catalogue depuis les assets Flutter via AssetBundle.
/// Dépendances : `flutter/services.dart` pour l'accès aux assets, DTO du catalogue.
/// Exemple d'usage :
///   final source = AssetBundleCatalogDataSource();
///   final classes = await source.loadClasses();
/// ---------------------------------------------------------------------------
library;
import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'package:sw5e_manager/data/catalog/dtos/catalog_dtos.dart';

/// AssetBundleCatalogDataSource = source de données hors-ligne basée sur les assets.
class AssetBundleCatalogDataSource {
  final AssetBundle _bundle;

  AssetBundleCatalogDataSource({AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  Future<List<SpeciesDto>> loadSpecies() async {
    final raw = await _loadArray('assets/catalog/species.json');
    return raw.map(SpeciesDto.fromJson).toList(growable: false);
  }

  Future<List<ClassDto>> loadClasses() async {
    final raw = await _loadArray('assets/catalog/classes.json');
    return raw.map(ClassDto.fromJson).toList(growable: false);
  }

  Future<List<BackgroundDto>> loadBackgrounds() async {
    final raw = await _loadArray('assets/catalog/backgrounds.json');
    return raw.map(BackgroundDto.fromJson).toList(growable: false);
  }

  Future<List<SkillDto>> loadSkills() async {
    final raw = await _loadArray('assets/catalog/skills.json');
    return raw.map(SkillDto.fromJson).toList(growable: false);
  }

  Future<List<EquipmentDto>> loadEquipment() async {
    final raw = await _loadArray('assets/catalog/equipment.json');
    return raw.map(EquipmentDto.fromJson).toList(growable: false);
  }

  Future<FormulasDto> loadFormulas() async {
    final raw = await _loadObject('assets/catalog/formulas.json');
    return FormulasDto.fromJson(raw);
  }

  Future<List<TraitDto>> loadTraits() async {
    final raw = await _loadArray('assets/catalog/traits.json');
    return raw.map(TraitDto.fromJson).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _loadArray(String path) async {
    final content = await _bundle.loadString(path);
    final json = jsonDecode(content);
    if (json is! List) {
      throw StateError('$path must decode to a JSON array');
    }
    return List<Map<String, dynamic>>.from(
      json.map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  Future<Map<String, dynamic>> _loadObject(String path) async {
    final content = await _bundle.loadString(path);
    final json = jsonDecode(content);
    if (json is! Map) {
      throw StateError('$path must decode to a JSON object');
    }
    return Map<String, dynamic>.from(json);
  }
}
