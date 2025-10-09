// lib/features/character_creation/domain/repositories/catalog_repository.dart
import 'package:meta/meta.dart';

/// ---- Types "catalogue" (lecture seule) ----

@immutable
class LocalizedText {
  final String en;
  final String fr;
  const LocalizedText({required this.en, required this.fr});
}

@immutable
class SpeciesDef {
  final String id; // slug (ex: "human")
  final LocalizedText name;
  final int speed; // ex: 30
  final String size; // ex: "medium"
  final List<String> traitIds;
  // Simplifié : on ne modèle pas encore ability_bonuses/traits au niveau du domaine.
  const SpeciesDef({
    required this.id,
    required this.name,
    required this.speed,
    required this.size,
    this.traitIds = const <String>[],
  });
}

@immutable
class ClassLevel1Proficiencies {
  final int skillsChoose;
  final List<String> skillsFrom; // slugs de skills
  const ClassLevel1Proficiencies({
    required this.skillsChoose,
    required this.skillsFrom,
  });
}

@immutable
class ClassLevel1Data {
  final ClassLevel1Proficiencies proficiencies;
  final int startingCredits;
  final List<StartingEquipmentLine> startingEquipment;
  const ClassLevel1Data({
    required this.proficiencies,
    required this.startingCredits,
    required this.startingEquipment,
  });
}

@immutable
class StartingEquipmentLine {
  final String id; // EquipmentItemId (slug)
  final int qty;
  const StartingEquipmentLine({required this.id, required this.qty});
}

@immutable
class ClassDef {
  final String id; // slug (ex: "guardian")
  final LocalizedText name;
  final int hitDie; // ex: 10
  final ClassLevel1Data level1;
  const ClassDef({
    required this.id,
    required this.name,
    required this.hitDie,
    required this.level1,
  });
}

@immutable
class BackgroundDef {
  final String id; // slug (ex: "outlaw")
  final LocalizedText name;
  final List<String> grantedSkills; // slugs de skills
  const BackgroundDef({
    required this.id,
    required this.name,
    required this.grantedSkills,
  });
}

@immutable
class SkillDef {
  final String id; // slug (ex: "perception")
  /// one of: str, dex, con, int, wis, cha
  final String ability;
  const SkillDef({required this.id, required this.ability});
}

@immutable
class EquipmentDef {
  final String id; // slug (ex: "blaster-pistol")
  final LocalizedText name;
  final String type; // ex: "weapon"
  final int weightG; // grammes
  final int cost; // crédits
  const EquipmentDef({
    required this.id,
    required this.name,
    required this.type,
    required this.weightG,
    required this.cost,
  });
}

@immutable
class SuperiorityDiceRule {
  final int count; // 0 autorisé
  final int? die; // null si count=0
  const SuperiorityDiceRule({required this.count, this.die});
}

@immutable
class FormulasDef {
  final String rulesVersion; // ex: "2025-10-06" (doit matcher ADR)
  final String hpLevel1;     // ex: "max(hit_die) + mod(CON)"
  final String defenseBase;  // ex: "armor_base + mod(DEX) + shield + misc"
  final String initiative;   // ex: "mod(DEX) + misc"
  /// Règle par classe (slug) pour les dés de supériorité au niveau 1
  final Map<String, SuperiorityDiceRule> superiorityDiceByClass;
  const FormulasDef({
    required this.rulesVersion,
    required this.hpLevel1,
    required this.defenseBase,
    required this.initiative,
    required this.superiorityDiceByClass,
  });
}

/// ---- Port du domaine : lecture du catalogue figé (snapshot) ----
/// Le domaine ne connaît PAS d’IO : une implémentation Data lira
/// les JSON d'assets et mapppera vers ces types.

abstract class CatalogRepository {
  /// Métadonnées
  Future<String> getRulesVersion(); // doit matcher ADR

  /// Référentiels
  Future<SpeciesDef?> getSpecies(String speciesId);
  Future<ClassDef?> getClass(String classId);
  Future<BackgroundDef?> getBackground(String backgroundId);
  Future<SkillDef?> getSkill(String skillId);
  Future<EquipmentDef?> getEquipment(String equipmentId);

  /// Formules/tableaux divers (niveau 1 au MVP)
  Future<FormulasDef> getFormulas();

  /// Listes utilitaires (optionnel pour l’UI/validation)
  Future<List<String>> listSkills();     // slugs
  Future<List<String>> listSpecies();    // slugs
  Future<List<String>> listClasses();    // slugs
  Future<List<String>> listBackgrounds();// slugs
  Future<List<String>> listEquipment();  // slugs
}
