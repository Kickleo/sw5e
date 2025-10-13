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
import 'package:sw5e_manager/data/catalog/data_sources/asset_bundle_catalog_data_source.dart';
import 'package:sw5e_manager/data/catalog/dtos/catalog_dtos.dart';
import 'package:sw5e_manager/domain/characters/localization/species_effect_localization.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// AssetCatalogRepository = adapter hors-ligne basé sur les assets JSON embarqués.
class AssetCatalogRepository implements CatalogRepository {
  final AssetBundleCatalogDataSource
      _dataSource; // Source brute pour charger les assets JSON.

  Map<String, SpeciesDef>? _species; // Cache lazy des espèces indexées par id.
  Map<String, ClassDef>? _classes; // Cache des classes niveau 1.
  Map<String, BackgroundDef>? _backgrounds; // Cache des backgrounds disponibles.
  Map<String, SkillDef>? _skills; // Cache des compétences.
  Map<String, EquipmentDef>?
      _equipment; // Cache de l'équipement indexé par identifiant.
  Map<String, TraitDef>? _traits; // Cache des traits d'espèce/background.
  FormulasDef? _formulas; // Formules métier (singleton).
  bool _speciesLocalizationConfigured = false;

  AssetCatalogRepository({AssetBundleCatalogDataSource? dataSource})
      : _dataSource = dataSource ??
            AssetBundleCatalogDataSource(); // Permet le remplacement en tests.

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
    return _formulas!; // Non nullable une fois chargé (assertion via bang).
  }

  @override
  Future<TraitDef?> getTrait(String traitId) async {
    await _ensureTraits();
    return _traits![traitId];
  }

  @override
  Future<List<String>> listSkills() async {
    await _ensureSkills();
    return _skills!.keys.toList()..sort(); // Retourne les identifiants triés.
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
    if (_species != null) return; // Cache déjà rempli.
    await _ensureSpeciesEffectLocalization();
    final dtos = await _dataSource.loadSpecies();
    _species = <String, SpeciesDef>{
      for (final dto in dtos) dto.id: dto.toDomain(),
    }; // Conversion en map indexée par identifiant.
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
    final TraitLocalizationConfigDto? traitLocalization =
        await _dataSource.loadTraitLocalizations();
    _traits = <String, TraitDef>{
      for (final dto in dtos)
        dto.id: dto.toDomain(
          descriptionOverride: traitLocalization?.forTrait(dto.id),
        ),
    };
  }

  Future<void> _ensureSpeciesEffectLocalization() async {
    if (_speciesLocalizationConfigured) {
      return;
    }
    final SpeciesEffectLocalizationConfigDto? config =
        await _dataSource.loadSpeciesEffectLocalizations();
    if (config != null && config.bundles.isNotEmpty) {
      SpeciesEffectLocalizationCatalog.configure(
        bundles: config.toDomainBundles(),
        fallbackLanguageCode: config.fallbackLanguageCode,
      );
    }
    _speciesLocalizationConfigured = true;
  }
}
