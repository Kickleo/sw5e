/// ---------------------------------------------------------------------------
/// Fichier : lib/data/catalog/repositories/asset_catalog_repository.dart
/// Rôle : Adapter les DTO chargés depuis les assets en implémentation de
///        [CatalogRepository] pour la couche domaine.
/// Dépendances : DTO du catalogue et data source AssetBundle.
/// Exemple d'usage :
///   final repo = AssetCatalogRepository();
///   final species = await repo.getSpecies('human');
/// ---------------------------------------------------------------------------
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

import '../data_sources/asset_bundle_catalog_data_source.dart';
import '../dtos/catalog_dtos.dart';

/// AssetCatalogRepository = adapter hors-ligne basé sur les assets JSON embarqués.
class AssetCatalogRepository implements CatalogRepository {
  final AssetBundleCatalogDataSource _dataSource;

  Map<String, SpeciesDef>? _species;
  Map<String, ClassDef>? _classes;
  Map<String, BackgroundDef>? _backgrounds;
  Map<String, SkillDef>? _skills;
  Map<String, EquipmentDef>? _equipment;
  Map<String, TraitDef>? _traits;
  FormulasDef? _formulas;

  AssetCatalogRepository({AssetBundleCatalogDataSource? dataSource})
      : _dataSource = dataSource ?? AssetBundleCatalogDataSource();

  @override
  Future<String> getRulesVersion() async {
    await _ensureFormulas();
    return _formulas!.rulesVersion;
  }

  @override
  Future<SpeciesDef?> getSpecies(String speciesId) async {
    await _ensureSpecies();
    return _species![speciesId];
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
    return _skills![skillId];
  }

  @override
  Future<EquipmentDef?> getEquipment(String equipmentId) async {
    await _ensureEquipment();
    return _equipment![equipmentId];
  }

  @override
  Future<FormulasDef> getFormulas() async {
    await _ensureFormulas();
    return _formulas!;
  }

  @override
  Future<TraitDef?> getTrait(String traitId) async {
    await _ensureTraits();
    return _traits![traitId];
  }

  @override
  Future<List<String>> listSkills() async {
    await _ensureSkills();
    return _skills!.keys.toList()..sort();
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
  Future<List<String>> listTraits() async {
    await _ensureTraits();
    return _traits!.keys.toList()..sort();
  }

  Future<void> _ensureSpecies() async {
    if (_species != null) return;
    final dtos = await _dataSource.loadSpecies();
    _species = <String, SpeciesDef>{
      for (final dto in dtos) dto.id: dto.toDomain(),
    };
  }

  Future<void> _ensureClasses() async {
    if (_classes != null) return;
    final dtos = await _dataSource.loadClasses();
    _classes = <String, ClassDef>{
      for (final dto in dtos) dto.id: dto.toDomain(),
    };
  }

  Future<void> _ensureBackgrounds() async {
    if (_backgrounds != null) return;
    final dtos = await _dataSource.loadBackgrounds();
    _backgrounds = <String, BackgroundDef>{
      for (final dto in dtos) dto.id: dto.toDomain(),
    };
  }

  Future<void> _ensureSkills() async {
    if (_skills != null) return;
    final dtos = await _dataSource.loadSkills();
    _skills = <String, SkillDef>{
      for (final dto in dtos) dto.id: dto.toDomain(),
    };
  }

  Future<void> _ensureEquipment() async {
    if (_equipment != null) return;
    final dtos = await _dataSource.loadEquipment();
    _equipment = <String, EquipmentDef>{
      for (final dto in dtos) dto.id: dto.toDomain(),
    };
  }

  Future<void> _ensureFormulas() async {
    if (_formulas != null) return;
    final dto = await _dataSource.loadFormulas();
    _formulas = dto.toDomain();
  }

  Future<void> _ensureTraits() async {
    if (_traits != null) return;
    final dtos = await _dataSource.loadTraits();
    _traits = <String, TraitDef>{
      for (final dto in dtos) dto.id: dto.toDomain(),
    };
  }
}
