/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/repositories/catalog_repository.dart
/// Rôle : Exposer les données de catalogue hors-ligne au domaine.
/// Dépendances : Types immuables définis dans ce fichier.
/// Exemple d'usage :
///   final species = await catalogRepository.getSpecies('bothan');
/// ---------------------------------------------------------------------------
library;
import 'package:meta/meta.dart';

/// ---- Types "catalogue" (lecture seule) ----

@immutable
class LocalizedText {
  final String en; // Libellé anglais.
  final String fr; // Libellé français.
  const LocalizedText({required this.en, required this.fr});
}

@immutable
class SpeciesAbilityBonus {
  final String ability; // slug ex: "int"
  final int amount; // valeur positive/négative appliquée.

  const SpeciesAbilityBonus({
    required this.ability,
    required this.amount,
  });
}

@immutable
class SpeciesDef {
  final String id; // slug (ex: "human")
  final LocalizedText name; // Nom affichable localisé.
  final int speed; // ex: 30
  final String size; // ex: "medium"
  final List<String> traitIds; // Traits référencés dans [TraitDef].
  final List<SpeciesAbilityBonus> abilityBonuses; // bonus de caractéristique.
  final String? age; // Texte descriptif de l'âge.
  final String? alignment; // Inclinaison morale typique.
  final String? sizeText; // Description détaillée de la taille.
  final String? speedText; // Description détaillée de la vitesse.
  final String? languages; // Langues parlées par défaut.

  const SpeciesDef({
    required this.id,
    required this.name,
    required this.speed,
    required this.size,
    this.traitIds = const <String>[],
    this.abilityBonuses = const <SpeciesAbilityBonus>[],
    this.age,
    this.alignment,
    this.sizeText,
    this.speedText,
    this.languages,
  });
}

@immutable
class ClassLevel1Proficiencies {
  final int skillsChoose; // Nombre de compétences que le joueur peut choisir.
  final List<String> skillsFrom; // slugs de skills éligibles.
  const ClassLevel1Proficiencies({
    required this.skillsChoose,
    required this.skillsFrom,
  });
}

@immutable
class ClassLevel1Data {
  final ClassLevel1Proficiencies proficiencies;
  final int? startingCredits; // Valeur fixe de crédits.
  final String? startingCreditsRoll; // Formule alternative (ex: "4d4 * 100").
  final List<StartingEquipmentLine>
      startingEquipment; // Pack d'équipement par défaut.
  final List<String>
      startingEquipmentOptions; // Identifiants d'options à choisir.
  const ClassLevel1Data({
    required this.proficiencies,
    this.startingCredits,
    this.startingCreditsRoll,
    required this.startingEquipment,
    this.startingEquipmentOptions = const <String>[],
  });
}

@immutable
class StartingEquipmentLine {
  final String id; // EquipmentItemId (slug)
  final int qty; // Quantité fournie.
  const StartingEquipmentLine({required this.id, required this.qty});
}

@immutable
class ClassDef {
  final String id; // slug (ex: "guardian")
  final LocalizedText name; // Titre localisé.
  final int hitDie; // ex: 10
  final ClassLevel1Data level1; // Informations spécifiques au niveau 1.
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
  final LocalizedText name; // Nom localisé.
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
  final String ability; // Caractéristique associée.
  const SkillDef({required this.id, required this.ability});
}

@immutable
class EquipmentDef {
  final String id; // slug (ex: "blaster-pistol")
  final LocalizedText name; // Nom lisible.
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
  final Map<String, SuperiorityDiceRule>
      superiorityDiceByClass; // Map immuable slug -> règle.
  const FormulasDef({
    required this.rulesVersion,
    required this.hpLevel1,
    required this.defenseBase,
    required this.initiative,
    required this.superiorityDiceByClass,
  });
}

/// Définition d’un trait d’espèce (affichage / compendium)
@immutable
class TraitDef {
  final String id;            // ex: "nimble-escape"
  final LocalizedText name;   // {en, fr}
  final String description;   // texte/markdown court décrivant le trait.

  const TraitDef({
    required this.id,
    required this.name,
    required this.description,
  });
}

/// CatalogRepository = port de lecture seule sur le catalogue Star Wars 5e.
///
/// * Pré-condition : les implémentations doivent fournir des données cohérentes
///   avec les Value Objects du domaine.
/// * Post-condition : aucune mutation des structures retournées (toutes immuables).
/// * Erreurs : la couche Data traduira les IO en exceptions/domain errors.

abstract class CatalogRepository {
  /// Métadonnées
  Future<String> getRulesVersion(); // doit matcher ADR

  /// Référentiels
  Future<SpeciesDef?> getSpecies(String speciesId); // Null si introuvable.
  Future<ClassDef?> getClass(String classId);
  Future<BackgroundDef?> getBackground(String backgroundId);
  Future<SkillDef?> getSkill(String skillId);
  Future<EquipmentDef?> getEquipment(String equipmentId);
  /// Formules/tableaux divers (niveau 1 au MVP)
  Future<FormulasDef> getFormulas(); // Toujours défini : nécessaire pour calculs.
  /// Récupère la définition d’un trait
  Future<TraitDef?> getTrait(String traitId);

  /// Listes utilitaires (optionnel pour l’UI/validation)
  Future<List<String>> listSkills();     // slugs
  Future<List<String>> listSpecies();    // slugs
  Future<List<String>> listClasses();    // slugs
  Future<List<String>> listBackgrounds();// slugs
  Future<List<String>> listEquipment();  // slugs
  /// (optionnel mais utile pour UI) — liste tous les IDs de traits
  Future<List<String>> listTraits(); // Slugs triés pour affichage/validation.
}
