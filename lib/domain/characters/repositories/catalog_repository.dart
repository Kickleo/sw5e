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
  final Map<String, String> otherTranslations; // Traductions additionnelles.

  const LocalizedText({
    this.en = '',
    this.fr = '',
    this.otherTranslations = const <String, String>{},
  });

  /// Retourne l'ensemble des traductions connues, clé = code langue.
  Map<String, String> get translations {
    final Map<String, String> normalized = <String, String>{};
    if (en.trim().isNotEmpty) {
      normalized['en'] = en;
    }
    if (fr.trim().isNotEmpty) {
      normalized['fr'] = fr;
    }
    otherTranslations.forEach((String key, String value) {
      final String trimmedKey = key.toLowerCase();
      if ((trimmedKey == 'en') || (trimmedKey == 'fr')) {
        // Ces clés sont déjà gérées ci-dessus.
        return;
      }
      final String trimmedValue = value.trim();
      if (trimmedValue.isNotEmpty) {
        normalized[trimmedKey] = trimmedValue;
      }
    });
    return Map<String, String>.unmodifiable(normalized);
  }

  /// Renvoie la traduction dans la [languageCode] demandée, avec repli.
  String resolve(String languageCode, {String? fallbackLanguageCode}) {
    final Map<String, String> values = translations;
    final String normalized = languageCode.toLowerCase();
    final String? primary = values[normalized];
    if (primary != null && primary.trim().isNotEmpty) {
      return primary.trim();
    }

    if (fallbackLanguageCode != null) {
      final String? fallback =
          values[fallbackLanguageCode.toLowerCase()]?.trim();
      if (fallback != null && fallback.isNotEmpty) {
        return fallback;
      }
    }

    for (final String value in values.values) {
      final String trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return '';
  }

  /// Renvoie la traduction demandée ou `null` si aucune valeur disponible.
  String? maybeResolve(String languageCode, {String? fallbackLanguageCode}) {
    final String value =
        resolve(languageCode, fallbackLanguageCode: fallbackLanguageCode);
    return value.isEmpty ? null : value;
  }
}

@immutable
class SpeciesAbilityBonus {
  final String? ability; // slug ex: "int" ou null pour un choix libre.
  final int amount; // valeur positive/négative appliquée.
  final int? choose; // nombre d'aptitudes à choisir.
  final List<String> options; // aptitudes possibles lorsque [choose] est défini.
  final bool isAlternative; // indique une variante alternative.

  const SpeciesAbilityBonus({
    this.ability,
    required this.amount,
    this.choose,
    this.options = const <String>[],
    this.isAlternative = false,
  });

  bool get isChoice => choose != null && options.isNotEmpty;
}

@immutable
class SpeciesDef {
  final String id; // slug (ex: "human")
  final LocalizedText name; // Nom affichable localisé.
  final int speed; // ex: 30
  final String size; // ex: "medium"
  final List<String> traitIds; // Traits référencés dans [TraitDef].
  final List<String> languageIds; // Slugs des langues parlées par défaut.
  final List<SpeciesAbilityBonus> abilityBonuses; // bonus de caractéristique.
  final LocalizedText? age; // Texte descriptif de l'âge.
  final LocalizedText? alignment; // Inclinaison morale typique.
  final LocalizedText? sizeText; // Description détaillée de la taille.
  final LocalizedText? speedText; // Description détaillée de la vitesse.
  final LocalizedText? languages; // Langues parlées par défaut.
  final LocalizedText? descriptionShort; // Résumé narratif (catalogue v2).
  final LocalizedText? description; // Description longue (catalogue v2).

  const SpeciesDef({
    required this.id,
    required this.name,
    required this.speed,
    required this.size,
    this.traitIds = const <String>[],
    this.languageIds = const <String>[],
    this.abilityBonuses = const <SpeciesAbilityBonus>[],
    this.age,
    this.alignment,
    this.sizeText,
    this.speedText,
    this.languages,
    this.descriptionShort,
    this.description,
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
  final List<LocalizedText>
      startingEquipmentOptions; // Libellés localisés des options.
  final List<ClassFeature>
      classFeatures; // Capacités gagnées au niveau 1 (catalogue v2).
  const ClassLevel1Data({
    required this.proficiencies,
    this.startingCredits,
    this.startingCreditsRoll,
    required this.startingEquipment,
    this.startingEquipmentOptions = const <LocalizedText>[],
    this.classFeatures = const <ClassFeature>[],
  });
}

@immutable
class ClassMulticlassing {
  final Map<String, int>
      abilityRequirements; // Prérequis de caractéristiques (slug -> score).

  const ClassMulticlassing({
    this.abilityRequirements = const <String, int>{},
  });

  bool get hasAbilityRequirements => abilityRequirements.isNotEmpty;
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
  final LocalizedText? description; // Présentation courte.
  final int hitDie; // ex: 10
  final ClassLevel1Data level1; // Informations spécifiques au niveau 1.
  final List<String> primaryAbilities; // Caractéristiques principales (slugs).
  final List<String> savingThrows; // Jets de sauvegarde maîtrisés (slugs).
  final List<String> weaponProficiencies; // Catégories d'armes maîtrisées.
  final List<String> armorProficiencies; // Catégories d'armures maîtrisées.
  final List<String> toolProficiencies; // Outils supplémentaires maîtrisés.
  final String? powerSource; // Origine des pouvoirs (force, tech...).
  final ClassPowerList? powerList; // Autorisations d'accès aux pouvoirs.
  final ClassMulticlassing? multiclassing; // Informations de multi-classe.
  const ClassDef({
    required this.id,
    required this.name,
    this.description,
    required this.hitDie,
    required this.level1,
    this.primaryAbilities = const <String>[],
    this.savingThrows = const <String>[],
    this.weaponProficiencies = const <String>[],
    this.armorProficiencies = const <String>[],
    this.toolProficiencies = const <String>[],
    this.powerSource,
    this.powerList,
    this.multiclassing,
  });
}

@immutable
class ClassPowerList {
  final bool forceAllowed; // Autorise les pouvoirs de Force.
  final bool techAllowed; // Autorise les pouvoirs technologiques.
  final String? spellcastingProgression; // Progression (full, half...).

  const ClassPowerList({
    this.forceAllowed = false,
    this.techAllowed = false,
    this.spellcastingProgression,
  });
}

@immutable
class CatalogFeatureEffect {
  final String id; // Identifiant unique de l'effet (UUID catalogue v2).
  final String kind; // Nature de l'effet (ex: "sense").
  final String? target; // Cible de l'effet si renseignée.
  final LocalizedText? text; // Description localisée de l'effet.

  const CatalogFeatureEffect({
    required this.id,
    required this.kind,
    this.target,
    this.text,
  });
}

@immutable
class CatalogPowerClassRef {
  final String type; // ex: class, archetype, tradition...
  final String id; // Identifiant UUID de la cible.

  const CatalogPowerClassRef({
    required this.type,
    required this.id,
  });
}

@immutable
class CatalogPowerRange {
  final String type; // self, area, line, etc.
  final int? distanceMeters; // Distance en mètres si fournie.
  final int? distanceFeet; // Distance convertie en pieds.

  const CatalogPowerRange({
    required this.type,
    this.distanceMeters,
    this.distanceFeet,
  });
}

@immutable
class CatalogPowerDuration {
  final String unit; // round, minute, hour...
  final int? value; // Quantité (ex: 10 minutes).
  final bool concentration; // Vrai si la durée requiert la concentration.

  const CatalogPowerDuration({
    required this.unit,
    this.value,
    this.concentration = false,
  });
}

@immutable
class PowerDef {
  final String id; // slug du pouvoir (ex: "battle-meditation").
  final String powerType; // force ou tech.
  final LocalizedText name; // Nom localisé du pouvoir.
  final int level; // Niveau du pouvoir.
  final String castingTime; // Action requise pour lancer le pouvoir.
  final CatalogPowerRange? range; // Portée structurée.
  final CatalogPowerDuration? duration; // Durée du pouvoir.
  final List<String> components; // Composants requis (vocal, somatic, tech...).
  final LocalizedText description; // Description narrative/effets.
  final List<CatalogFeatureEffect> effects; // Effets structurés supplémentaires.
  final List<CatalogPowerClassRef> classes; // Listes des classes autorisées.
  final String? alignment; // (Force) alignement requis (light, dark, etc.).
  final String? school; // Discipline/école du pouvoir.

  const PowerDef({
    required this.id,
    required this.powerType,
    required this.name,
    required this.level,
    required this.castingTime,
    this.range,
    this.duration,
    this.components = const <String>[],
    required this.description,
    this.effects = const <CatalogFeatureEffect>[],
    this.classes = const <CatalogPowerClassRef>[],
    this.alignment,
    this.school,
  });
}

@immutable
class CustomizationPrerequisiteCondition {
  final String? classId; // UUID de classe requis.
  final int? minLevel; // Niveau minimum requis.
  final String? optionId; // UUID d'une autre option à posséder.
  final String? traitId; // UUID de trait requis.
  final String? speciesId; // UUID d'espèce requis.
  final String? backgroundId; // UUID de background requis.
  final Map<String, dynamic> raw; // Autres champs non encore typés.

  const CustomizationPrerequisiteCondition({
    this.classId,
    this.minLevel,
    this.optionId,
    this.traitId,
    this.speciesId,
    this.backgroundId,
    this.raw = const <String, dynamic>{},
  });
}

@immutable
class CustomizationPrerequisite {
  final List<CustomizationPrerequisite> all; // Toutes les conditions doivent être vraies.
  final List<CustomizationPrerequisite> any; // Au moins une condition doit être vraie.
  final CustomizationPrerequisiteCondition? condition; // Feuille de l'arbre logique.

  const CustomizationPrerequisite({
    this.all = const <CustomizationPrerequisite>[],
    this.any = const <CustomizationPrerequisite>[],
    this.condition,
  });

  bool get isEmpty =>
      all.isEmpty && any.isEmpty && condition == null; // Prérequis vide = option libre.
}

@immutable
class CustomizationOptionDef {
  final String id; // slug de l'option (ex: "form-ii-makashi")
  final LocalizedText name; // Nom localisé.
  final String category; // Catégorie (lightsaber-form, feat, etc.).
  final List<CatalogFeatureEffect> effects; // Effets mécaniques.
  final CustomizationPrerequisite? prerequisite; // Conditions d'accès éventuelles.

  const CustomizationOptionDef({
    required this.id,
    required this.name,
    required this.category,
    this.effects = const <CatalogFeatureEffect>[],
    this.prerequisite,
  });
}

@immutable
class BackgroundFeature {
  final LocalizedText name; // Nom localisé de la capacité de background.
  final List<CatalogFeatureEffect> effects; // Liste des effets décrits.

  const BackgroundFeature({
    required this.name,
    this.effects = const <CatalogFeatureEffect>[],
  });
}

@immutable
class ClassFeature {
  final LocalizedText name; // Nom localisé de la capacité de classe.
  final LocalizedText? description; // Texte descriptif (optionnel).
  final List<CatalogFeatureEffect> effects; // Effets structurés du catalogue.

  const ClassFeature({
    required this.name,
    this.description,
    this.effects = const <CatalogFeatureEffect>[],
  });
}

@immutable
class BackgroundPersonality {
  final List<LocalizedText> traits; // Suggestions de traits de personnalité.
  final List<LocalizedText> ideals; // Suggestions d'idéaux.
  final List<LocalizedText> bonds; // Suggestions de liens.
  final List<LocalizedText> flaws; // Suggestions de défauts.

  const BackgroundPersonality({
    this.traits = const <LocalizedText>[],
    this.ideals = const <LocalizedText>[],
    this.bonds = const <LocalizedText>[],
    this.flaws = const <LocalizedText>[],
  });
}

@immutable
class BackgroundEquipmentGrant {
  final String itemId; // Identifiant de l'objet (slug ou référence catalogue).
  final String refType; // Type de référence (ex: "gear").
  final int quantity; // Quantité fournie, par défaut 1.

  const BackgroundEquipmentGrant({
    required this.itemId,
    required this.refType,
    this.quantity = 1,
  });
}

@immutable
class BackgroundDef {
  final String id; // slug (ex: "outlaw")
  final LocalizedText name; // Nom localisé.
  final List<String> grantedSkills; // slugs de skills
  final int languagesPick; // Nombre de langues supplémentaires à choisir.
  final List<String> toolProficiencies; // Identifiants de maîtrises d'outils.
  final BackgroundFeature? feature; // Capacité narrative/mécanique du background.
  final BackgroundPersonality? personality; // Tables de personnalité.
  final List<BackgroundEquipmentGrant> equipment; // Pack d'équipement fourni.
  const BackgroundDef({
    required this.id,
    required this.name,
    required this.grantedSkills,
    this.languagesPick = 0,
    this.toolProficiencies = const <String>[],
    this.feature,
    this.personality,
    this.equipment = const <BackgroundEquipmentGrant>[],
  });
}

@immutable
class LanguageDef {
  final String id; // slug (ex: "galactic-basic")
  final LocalizedText name; // Nom localisé de la langue.
  final LocalizedText? description; // Description/sources lorsque disponible.
  final LocalizedText? script; // Nom localisé de l'alphabet/script.
  final List<LanguageTypicalSpeaker> typicalSpeakers; // Ex: espèces associées.

  const LanguageDef({
    required this.id,
    required this.name,
    this.description,
    this.script,
    this.typicalSpeakers = const <LanguageTypicalSpeaker>[],
  });
}

class LanguageTypicalSpeaker {
  final String type; // ex: species, culture, etc.
  final String id; // identifiant brut (UUID dans le catalogue v2).
  final LocalizedText? name; // Nom localisé fourni par le catalogue.

  const LanguageTypicalSpeaker({
    required this.type,
    required this.id,
    this.name,
  });
}

@immutable
class SkillDef {
  final String id; // slug (ex: "perception")
  /// one of: str, dex, con, int, wis, cha
  final String ability; // Caractéristique associée.
  final LocalizedText name; // Nom localisé de la compétence (catalogue v2).

  const SkillDef({
    required this.id,
    required this.ability,
    this.name = const LocalizedText(),
  });
}

@immutable
class AbilityDef {
  final String id; // slug (ex: "str")
  final String abbreviation; // ex: "STR"
  final LocalizedText name; // Nom localisé de la caractéristique.
  final LocalizedText? description; // Description optionnelle.

  const AbilityDef({
    required this.id,
    required this.abbreviation,
    required this.name,
    this.description,
  });
}

@immutable
class EquipmentDef {
  final String id; // slug (ex: "blaster-pistol")
  final LocalizedText name; // Nom lisible.
  final String type; // ex: "weapon"
  final int weightG; // grammes
  final int cost; // crédits
  final String? rarity; // rareté éventuelle (common, uncommon, ...)
  final LocalizedText? description; // Description localisée de l'objet.
  final String? weaponCategory; // sous-type d'arme (ex: ranged)
  final List<WeaponDamage> weaponDamage; // Dégâts associés si arme.
  final WeaponRange? weaponRange; // Portée primaire / maximale pour les armes.
  final List<String> weaponProperties; // Propriétés additionnelles.
  const EquipmentDef({
    required this.id,
    required this.name,
    required this.type,
    required this.weightG,
    required this.cost,
    this.rarity,
    this.description,
    this.weaponCategory,
    this.weaponDamage = const <WeaponDamage>[],
    this.weaponRange,
    this.weaponProperties = const <String>[],
  });
}

@immutable
class WeaponDamage {
  final String damageType; // slug (ex: "energy")
  final LocalizedText? damageTypeName; // Nom localisé du type de dégâts.
  final LocalizedText? damageTypeNotes; // Notes ou effets supplémentaires.
  final int? diceCount; // Nombre de dés (peut être null si inconnu)
  final int? diceDie; // Taille du dé (d4, d6, ...)
  final int? diceModifier; // Bonus fixe éventuel.

  const WeaponDamage({
    required this.damageType,
    this.damageTypeName,
    this.damageTypeNotes,
    this.diceCount,
    this.diceDie,
    this.diceModifier,
  });
}

@immutable
class WeaponRange {
  final int? primary; // Portée optimale en mètres.
  final int? maximum; // Portée maximale en mètres.

  const WeaponRange({this.primary, this.maximum});
}

@immutable
class DamageTypeDef {
  final String id; // slug (ex: "energy")
  final LocalizedText name; // Nom localisé du type de dégâts.
  final LocalizedText? notes; // Notes ou exemples.

  const DamageTypeDef({
    required this.id,
    required this.name,
    this.notes,
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
  /// Formule pour calculer le bonus d'attaque (catalogue v2).
  final String? attackBonus;
  /// Formule pour calculer le DD de sauvegarde des pouvoirs (catalogue v2).
  final String? powerSaveDc;
  const FormulasDef({
    required this.rulesVersion,
    required this.hpLevel1,
    required this.defenseBase,
    required this.initiative,
    required this.superiorityDiceByClass,
    this.attackBonus,
    this.powerSaveDc,
  });
}

/// Définition d’un trait d’espèce (affichage / compendium)
@immutable
class TraitDef {
  final String id; // ex: "nimble-escape"
  final LocalizedText name; // {en, fr, ...}
  final LocalizedText description; // Texte localisé décrivant le trait.

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
  Future<AbilityDef?> getAbility(String abilityId);
  Future<EquipmentDef?> getEquipment(String equipmentId);
  Future<LanguageDef?> getLanguage(String languageId);
  /// Formules/tableaux divers (niveau 1 au MVP)
  Future<FormulasDef> getFormulas(); // Toujours défini : nécessaire pour calculs.
  /// Récupère la définition d’un trait
  Future<TraitDef?> getTrait(String traitId);
  Future<CustomizationOptionDef?> getCustomizationOption(String optionId);
  Future<PowerDef?> getForcePower(String powerId);
  Future<PowerDef?> getTechPower(String powerId);

  /// Listes utilitaires (optionnel pour l’UI/validation)
  Future<List<String>> listSkills();     // slugs
  Future<List<String>> listAbilities();  // slugs
  Future<List<String>> listSpecies();    // slugs
  Future<List<String>> listClasses();    // slugs
  Future<List<String>> listBackgrounds();// slugs
  Future<List<String>> listEquipment();  // slugs
  Future<List<String>> listLanguages();  // slugs
  /// (optionnel mais utile pour UI) — liste tous les IDs de traits
  Future<List<String>> listTraits(); // Slugs triés pour affichage/validation.
  Future<List<String>> listCustomizationOptions(); // Slugs triés.
  Future<List<String>> listForcePowers(); // Slugs triés.
  Future<List<String>> listTechPowers(); // Slugs triés.

  /// Types de dégâts (catalogue v2)
  Future<DamageTypeDef?> getDamageType(String damageTypeId);
  Future<List<String>> listDamageTypes();
}
