// lib/features/character_creation/data/repositories/asset_catalog_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';

/// Implémentation Data lisant le catalogue depuis /assets/catalog/*.json
class AssetCatalogRepository implements CatalogRepository {
  final AssetBundle _bundle;

  AssetCatalogRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  // --- caches (chargés à la première demande) ---
  Map<String, SpeciesDef>? _species;
  Map<String, ClassDef>? _classes;
  Map<String, BackgroundDef>? _backgrounds;
  Map<String, SkillDef>? _skills;
  Map<String, EquipmentDef>? _equipment;
  FormulasDef? _formulas;

  Future<List<dynamic>> _loadArray(String path) async {
    final raw = await _bundle.loadString(path);
    final json = jsonDecode(raw);
    if (json is! List) throw StateError('$path must be a JSON array');
    return json;
  }

  Future<Map<String, dynamic>> _loadObject(String path) async {
    final raw = await _bundle.loadString(path);
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) {
      throw StateError('$path must be a JSON object');
    }
    return json;
  }

  // ---------------- Species ----------------
  Future<void> _ensureSpecies() async {
    if (_species != null) return;
    final arr = await _loadArray('assets/catalog/species.json');
    _species = {
      for (final e in arr.cast<Map>())
        (e['id'] as String): SpeciesDef(
          id: e['id'] as String,
          name: LocalizedText(
            en: (e['name'] as Map)['en'] as String,
            fr: (e['name'] as Map)['fr'] as String,
          ),
          speed: (e['speed'] as num).toInt(),
          size: e['size'] as String,
        ),
    };
  }

  // ---------------- Classes ----------------
  Future<void> _ensureClasses() async {
    if (_classes != null) return;
    final arr = await _loadArray('assets/catalog/classes.json');
    _classes = {
      for (final e in arr.cast<Map>())
        (e['id'] as String): _mapClass(e as Map<String, dynamic>),
    };
  }

  ClassDef _mapClass(Map<String, dynamic> e) {
    final lvl1 = e['level1'] as Map<String, dynamic>;
    final profs = lvl1['proficiencies'] as Map<String, dynamic>;
    final startEquip = (lvl1['starting_equipment'] as List)
        .cast<Map>()
        .map((m) => StartingEquipmentLine(
              id: m['id'] as String,
              qty: (m['qty'] as num).toInt(),
            ))
        .toList();

    return ClassDef(
      id: e['id'] as String,
      name: LocalizedText(
        en: (e['name'] as Map)['en'] as String,
        fr: (e['name'] as Map)['fr'] as String,
      ),
      hitDie: (e['hit_die'] as num).toInt(),
      level1: ClassLevel1Data(
        proficiencies: ClassLevel1Proficiencies(
          skillsChoose: (profs['skills_choose'] as num).toInt(),
          skillsFrom: (profs['skills_from'] as List).cast<String>(),
        ),
        startingCredits: (lvl1['starting_credits'] as num).toInt(),
        startingEquipment: startEquip,
      ),
    );
  }

  // -------------- Backgrounds --------------
  Future<void> _ensureBackgrounds() async {
    if (_backgrounds != null) return;
    final arr = await _loadArray('assets/catalog/backgrounds.json');
    _backgrounds = {
      for (final e in arr.cast<Map>())
        (e['id'] as String): BackgroundDef(
          id: e['id'] as String,
          name: LocalizedText(
            en: (e['name'] as Map)['en'] as String,
            fr: (e['name'] as Map)['fr'] as String,
          ),
          grantedSkills: (e['granted_skills'] as List).cast<String>(),
        ),
    };
  }

  // ----------------- Skills ----------------
  Future<void> _ensureSkills() async {
    if (_skills != null) return;
    final arr = await _loadArray('assets/catalog/skills.json');
    _skills = {
      for (final e in arr.cast<Map>())
        (e['id'] as String): SkillDef(
          id: e['id'] as String,
          ability: e['ability'] as String,
        ),
    };
  }

  // --------------- Equipment ---------------
  Future<void> _ensureEquipment() async {
    if (_equipment != null) return;
    final arr = await _loadArray('assets/catalog/equipment.json');
    _equipment = {
      for (final e in arr.cast<Map>())
        (e['id'] as String): EquipmentDef(
          id: e['id'] as String,
          name: LocalizedText(
            en: (e['name'] as Map)['en'] as String,
            fr: (e['name'] as Map)['fr'] as String,
          ),
          type: e['type'] as String,
          weightG: (e['weight_g'] as num).toInt(),
          cost: (e['cost'] as num).toInt(),
        ),
    };
  }

  // ---------------- Formulas ---------------
  Future<void> _ensureFormulas() async {
    if (_formulas != null) return;
    final obj = await _loadObject('assets/catalog/formulas.json');
    final Map<String, dynamic> sd = (obj['superiority_dice'] as Map).cast<String, dynamic>();
    final sup = <String, SuperiorityDiceRule>{
      for (final entry in sd.entries)
        entry.key: SuperiorityDiceRule(
          count: (entry.value['count'] as num).toInt(),
          die: entry.value['die'] == null ? null : (entry.value['die'] as num).toInt(),
        ),
    };
    _formulas = FormulasDef(
      rulesVersion: obj['rules_version'] as String,
      hpLevel1: obj['hp_level1'] as String,
      defenseBase: obj['defense_base'] as String,
      initiative: obj['initiative'] as String,
      superiorityDiceByClass: sup,
    );
  }

  // ------------ Impl CatalogRepository ------------
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
}
