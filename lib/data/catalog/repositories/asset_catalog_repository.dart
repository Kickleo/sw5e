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
import 'package:sw5e_manager/data/catalog_v2/data_sources/asset_bundle_catalog_v2_data_source.dart';
import 'package:sw5e_manager/data/catalog_v2/dtos/catalog_v2_dtos.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// AssetCatalogRepository = adapter hors-ligne basé sur les assets JSON embarqués.
class AssetCatalogRepository implements CatalogRepository {
  final AssetBundleCatalogDataSource
      _dataSource; // Source brute pour charger les assets JSON.
  final AssetBundleCatalogV2DataSource _dataSourceV2;

  Map<String, SpeciesDef>? _species; // Cache lazy des espèces indexées par id.
  Map<String, ClassDef>? _classes; // Cache des classes niveau 1.
  Map<String, BackgroundDef>? _backgrounds; // Cache des backgrounds disponibles.
  Map<String, SkillDef>? _skills; // Cache des compétences.
  Map<String, EquipmentDef>?
      _equipment; // Cache de l'équipement indexé par identifiant.
  Map<String, TraitDef>? _traits; // Cache des traits d'espèce/background.
  FormulasDef? _formulas; // Formules métier (singleton).

  Map<String, String>? _abilityIdToSlug;
  Map<String, String>? _abilityAbbrToSlug;
  Map<String, LocalizedText>? _languagesById;
  Map<String, String>? _traitIdToSlug;

  AssetCatalogRepository({
    AssetBundleCatalogDataSource? dataSource,
    AssetBundleCatalogV2DataSource? dataSourceV2,
  })  : _dataSource = dataSource ?? AssetBundleCatalogDataSource(),
        _dataSourceV2 = dataSourceV2 ?? AssetBundleCatalogV2DataSource();

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

      mapped[dto.slug] = SpeciesDef(
        id: dto.slug,
        name: dto.name.toDomain(),
        speed: _metersToFeet(dto.speedMeters),
        size: dto.size,
        traitIds: List<String>.unmodifiable(traitSlugs),
        abilityBonuses: List<SpeciesAbilityBonus>.unmodifiable(bonuses),
        age: null,
        alignment: null,
        sizeText: null,
        speedText: null,
        languages: languages,
      );
    }
    _species = Map<String, SpeciesDef>.unmodifiable(mapped);
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
    await _ensureAbilities();
    final List<CatalogV2SkillDto> dtos = await _dataSourceV2.loadSkills();
    final Map<String, SkillDef> mapped = <String, SkillDef>{};
    for (final CatalogV2SkillDto dto in dtos) {
      final String abilitySlug =
          _abilityIdToSlug![dto.abilityRef] ?? dto.abilityRef.toLowerCase();
      mapped[dto.slug] = SkillDef(id: dto.slug, ability: abilitySlug);
    }
    _skills = Map<String, SkillDef>.unmodifiable(mapped);
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

  Future<void> _ensureLanguages() async {
    if (_languagesById != null) return;
    final List<CatalogV2LanguageDto> dtos = await _dataSourceV2.loadLanguages();
    final Map<String, LocalizedText> mapped = <String, LocalizedText>{};
    for (final CatalogV2LanguageDto dto in dtos) {
      mapped[dto.id] = dto.name.toDomain();
    }
    _languagesById = Map<String, LocalizedText>.unmodifiable(mapped);
  }

  Future<void> _ensureAbilities() async {
    if (_abilityIdToSlug != null && _abilityAbbrToSlug != null) {
      return;
    }
    final List<CatalogV2AbilityDto> dtos = await _dataSourceV2.loadAbilities();
    final Map<String, String> idToSlug = <String, String>{};
    final Map<String, String> abbrToSlug = <String, String>{};
    for (final CatalogV2AbilityDto dto in dtos) {
      idToSlug[dto.id] = dto.slug;
      abbrToSlug[dto.abbr] = dto.slug;
    }
    _abilityIdToSlug = Map<String, String>.unmodifiable(idToSlug);
    _abilityAbbrToSlug = Map<String, String>.unmodifiable(abbrToSlug);
  }

  LocalizedText? _resolveSpeciesLanguages(CatalogV2SpeciesDto dto) {
    if (dto.languageIds.isEmpty || _languagesById == null) {
      return null;
    }
    final List<String> enNames = <String>[];
    final List<String> frNames = <String>[];
    for (final String id in dto.languageIds) {
      final LocalizedText? language = _languagesById![id];
      if (language == null) {
        continue;
      }
      final String? en = language.maybeResolve('en');
      final String? fr = language.maybeResolve('fr', fallbackLanguageCode: 'en');
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

  int _metersToFeet(double? meters) {
    if (meters == null) {
      return 0;
    }
    return (meters * 3.28084).round();
  }
}
