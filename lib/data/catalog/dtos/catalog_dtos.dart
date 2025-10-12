/// ---------------------------------------------------------------------------
/// Fichier : lib/data/catalog/dtos/catalog_dtos.dart
/// Rôle : Définir les DTO (Data Transfer Object = objet intermédiaire sérialisable)
///        utilisés pour hydrater le catalogue hors-ligne depuis les assets JSON.
/// Dépendances : Domaine `CatalogRepository` pour la conversion vers les types
///               immuables exposés au reste de l'application.
/// Exemple d'usage :
///   final dto = SpeciesDto.fromJson(jsonMap);
///   final species = dto.toDomain();
/// ---------------------------------------------------------------------------
library;
import 'package:meta/meta.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// LocalizedTextDto = version sérialisable de [LocalizedText].
@immutable
class LocalizedTextDto {
  final String en; // Traduction anglaise de l'intitulé.
  final String fr; // Traduction française.

  const LocalizedTextDto({required this.en, required this.fr});

  factory LocalizedTextDto.fromJson(Map<String, dynamic> json) {
    // On lit directement les champs texte en s'assurant qu'ils sont bien des String.
    return LocalizedTextDto(
      en: json['en'] as String,
      fr: json['fr'] as String,
    );
  }

  LocalizedText toDomain() =>
      LocalizedText(en: en, fr: fr); // Conversion vers le modèle de domaine.
}

/// SpeciesDto = structure JSON des espèces (assets/catalog/species.json).
@immutable
class SpeciesAbilityBonusDto {
  final String? ability; // Identifiant fixe de caractéristique.
  final int amount; // Bonus/malus appliqué par l'espèce.
  final int? choose; // Nombre d'aptitudes à sélectionner.
  final List<String> options; // Liste des options possibles lorsqu'il y a un choix.
  final bool alternative; // Indique si ce bloc est une alternative.

  const SpeciesAbilityBonusDto({
    required this.ability,
    required this.amount,
    required this.choose,
    required this.options,
    required this.alternative,
  });

  factory SpeciesAbilityBonusDto.fromJson(Map<String, dynamic> json) {
    return SpeciesAbilityBonusDto(
      ability: json['ability'] as String?,
      amount: (json['amount'] as num).toInt(),
      choose: (json['choose'] as num?)?.toInt(),
      options: List<String>.from(json['options'] as List? ?? const <String>[]),
      alternative: json['alternative'] as bool? ?? false,
    );
  }

  SpeciesAbilityBonus toDomain() => SpeciesAbilityBonus(
        ability: ability,
        amount: amount,
        choose: choose,
        options: List<String>.unmodifiable(options),
        isAlternative: alternative,
      );
}

class SpeciesDto {
  final String id; // Identifiant unique de l'espèce.
  final LocalizedTextDto name; // Nom localisé de l'espèce.
  final int speed; // Vitesse de déplacement en pieds.
  final String size; // Catégorie de taille (small, medium...).
  final List<String> traitIds; // Traits conférés par l'espèce.
  final List<SpeciesAbilityBonusDto> abilityBonuses; // Bonus aux caractéristiques.
  final String? age; // Description d'âge.
  final String? alignment; // Alignement typique.
  final String? sizeText; // Texte détaillant la taille.
  final String? speedText; // Texte détaillant la vitesse.
  final String? languages; // Langues connues.

  const SpeciesDto({
    required this.id,
    required this.name,
    required this.speed,
    required this.size,
    required this.traitIds,
    required this.abilityBonuses,
    required this.age,
    required this.alignment,
    required this.sizeText,
    required this.speedText,
    required this.languages,
  });

  factory SpeciesDto.fromJson(Map<String, dynamic> json) {
    // Extrait et convertit chaque propriété du JSON brut.
    return SpeciesDto(
      id: json['id'] as String,
      name: LocalizedTextDto.fromJson(
        Map<String, dynamic>.from(json['name'] as Map),
      ),
      speed: (json['speed'] as num).toInt(),
      size: json['size'] as String,
      traitIds: List<String>.from(json['traits'] as List? ?? const <String>[]),
      abilityBonuses: List<Map<String, dynamic>>.from(
        json['ability_bonuses'] as List? ?? const <Map<String, dynamic>>[],
      )
          .map(SpeciesAbilityBonusDto.fromJson)
          .toList(growable: false),
      age: json['age'] as String?,
      alignment: json['alignment'] as String?,
      sizeText: json['size_text'] as String?,
      speedText: json['speed_text'] as String?,
      languages: json['languages'] as String?,
    );
  }

  SpeciesDef toDomain() => SpeciesDef(
        id: id,
        name: name.toDomain(),
        speed: speed,
        size: size,
        traitIds: List<String>.unmodifiable(traitIds),
        abilityBonuses:
            abilityBonuses.map((bonus) => bonus.toDomain()).toList(growable: false),
        age: age,
        alignment: alignment,
        sizeText: sizeText,
        speedText: speedText,
        languages: languages,
      ); // Crée l'entité de domaine immuable correspondante.
}

/// StartingEquipmentLineDto = ligne d'équipement initial pour une classe.
@immutable
class StartingEquipmentLineDto {
  final String id; // Identifiant d'un équipement.
  final int qty; // Quantité fournie au personnage.

  const StartingEquipmentLineDto({required this.id, required this.qty});

  factory StartingEquipmentLineDto.fromJson(Map<String, dynamic> json) {
    // Convertit la quantité numérique potentiellement double en int.
    return StartingEquipmentLineDto(
      id: json['id'] as String,
      qty: (json['qty'] as num).toInt(),
    );
  }

  StartingEquipmentLine toDomain() => StartingEquipmentLine(
        id: id,
        qty: qty,
      ); // Transforme en modèle de domaine prêt à l'usage.
}

/// ClassLevel1ProficienciesDto = DTO des maîtrises niveau 1.
@immutable
class ClassLevel1ProficienciesDto {
  final int skillsChoose; // Nombre de compétences à choisir.
  final List<String> skillsFrom; // Liste des compétences éligibles.

  const ClassLevel1ProficienciesDto({
    required this.skillsChoose,
    required this.skillsFrom,
  });

  factory ClassLevel1ProficienciesDto.fromJson(Map<String, dynamic> json) {
    // Normalise la liste JSON en `List<String>`.
    return ClassLevel1ProficienciesDto(
      skillsChoose: (json['skills_choose'] as num).toInt(),
      skillsFrom: List<String>.from(json['skills_from'] as List? ?? const <String>[]),
    );
  }

  ClassLevel1Proficiencies toDomain() => ClassLevel1Proficiencies(
        skillsChoose: skillsChoose,
        skillsFrom: List<String>.unmodifiable(skillsFrom),
      ); // Retourne une structure immuable dans la couche domaine.
}

/// ClassLevel1Dto = bloc niveau 1 d'une classe (équipement, crédits...).
@immutable
class ClassLevel1Dto {
  final ClassLevel1ProficienciesDto
      proficiencies; // Config des maîtrises niveau 1.
  final int? startingCredits; // Montant fixe de crédits offert.
  final String? startingCreditsRoll; // Formule de dés pour déterminer les crédits.
  final List<StartingEquipmentLineDto>
      startingEquipment; // Pack d'équipement accordé d'office.
  final List<LocalizedTextDto>
      startingEquipmentOptions; // Options d'équipement localisées.

  const ClassLevel1Dto({
    required this.proficiencies,
    required this.startingCredits,
    required this.startingCreditsRoll,
    required this.startingEquipment,
    required this.startingEquipmentOptions,
  });

  factory ClassLevel1Dto.fromJson(Map<String, dynamic> json) {
    // Chaque bloc JSON est converti en DTO spécifique, puis en listes typées.
    return ClassLevel1Dto(
      proficiencies: ClassLevel1ProficienciesDto.fromJson(
        Map<String, dynamic>.from(json['proficiencies'] as Map),
      ),
      startingCredits: (json['starting_credits'] as num?)?.toInt(),
      startingCreditsRoll: json['starting_credits_roll'] as String?,
      startingEquipment: List<Map<String, dynamic>>.from(
        json['starting_equipment'] as List? ?? const <Map<String, dynamic>>[],
      )
          .map(StartingEquipmentLineDto.fromJson)
          .toList(),
      startingEquipmentOptions: List<Map<String, dynamic>>.from(
        json['starting_equipment_options']
                as List? ??
            const <Map<String, dynamic>>[],
      )
          .map(
            (entry) => LocalizedTextDto.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          )
          .toList(growable: false),
    );
  }

  ClassLevel1Data toDomain() => ClassLevel1Data(
        proficiencies: proficiencies.toDomain(),
        startingCredits: startingCredits,
        startingCreditsRoll: startingCreditsRoll,
        startingEquipment: startingEquipment
            .map((dto) => dto.toDomain())
            .toList(growable: false),
        startingEquipmentOptions: startingEquipmentOptions
            .map((dto) => dto.toDomain())
            .toList(growable: false),
      ); // Construit la structure métier consommée par la logique de création.
}

/// ClassDto = représentation JSON d'une classe niveau 1.
@immutable
class ClassDto {
  final String id; // Identifiant unique de la classe.
  final LocalizedTextDto name; // Nom localisé affiché à l'utilisateur.
  final LocalizedTextDto? description; // Résumé localisé de la classe.
  final int hitDie; // Taille du dé de vie (ex: d8, d10).
  final ClassLevel1Dto level1; // Données spécifiques au niveau 1.

  const ClassDto({
    required this.id,
    required this.name,
    this.description,
    required this.hitDie,
    required this.level1,
  });

  factory ClassDto.fromJson(Map<String, dynamic> json) {
    // Parse le JSON brut en appelant les constructeurs des DTO imbriqués.
    return ClassDto(
      id: json['id'] as String,
      name: LocalizedTextDto.fromJson(
        Map<String, dynamic>.from(json['name'] as Map),
      ),
      description: json['description'] == null
          ? null
          : LocalizedTextDto.fromJson(
              Map<String, dynamic>.from(json['description'] as Map),
            ),
      hitDie: (json['hit_die'] as num).toInt(),
      level1: ClassLevel1Dto.fromJson(
        Map<String, dynamic>.from(json['level1'] as Map),
      ),
    );
  }

  ClassDef toDomain() => ClassDef(
        id: id,
        name: name.toDomain(),
        description: description?.toDomain(),
        hitDie: hitDie,
        level1: level1.toDomain(),
      ); // Produit la représentation métier utilisée dans les use cases.
}

/// BackgroundDto = DTO des historiques.
@immutable
class BackgroundDto {
  final String id; // Identifiant du background.
  final LocalizedTextDto name; // Libellé localisé.
  final List<String> grantedSkills; // Compétences automatiquement acquises.

  const BackgroundDto({
    required this.id,
    required this.name,
    required this.grantedSkills,
  });

  factory BackgroundDto.fromJson(Map<String, dynamic> json) {
    // Convertit la liste `granted_skills` (potentiellement absente) en `List<String>`.
    return BackgroundDto(
      id: json['id'] as String,
      name: LocalizedTextDto.fromJson(
        Map<String, dynamic>.from(json['name'] as Map),
      ),
      grantedSkills: List<String>.from(
        json['granted_skills'] as List? ?? const <String>[],
      ),
    );
  }

  BackgroundDef toDomain() => BackgroundDef(
        id: id,
        name: name.toDomain(),
        grantedSkills: List<String>.unmodifiable(grantedSkills),
      ); // Fige la liste pour empêcher des modifications ultérieures.
}

/// SkillDto = DTO des compétences.
@immutable
class SkillDto {
  final String id; // Identifiant de la compétence.
  final String ability; // Caractéristique associée (ex : STR, DEX).

  const SkillDto({required this.id, required this.ability});

  factory SkillDto.fromJson(Map<String, dynamic> json) {
    // Le JSON fournit des chaînes simples : on les extrait directement.
    return SkillDto(
      id: json['id'] as String,
      ability: json['ability'] as String,
    );
  }

  SkillDef toDomain() =>
      SkillDef(id: id, ability: ability); // Conversion directe vers le domaine.
}

/// EquipmentDto = DTO du matériel.
@immutable
class EquipmentDto {
  final String id; // Identifiant de l'objet.
  final LocalizedTextDto name; // Nom localisé.
  final String type; // Catégorie d'équipement (arme, armure...).
  final int weightG; // Poids en grammes.
  final int cost; // Coût en crédits.

  const EquipmentDto({
    required this.id,
    required this.name,
    required this.type,
    required this.weightG,
    required this.cost,
  });

  factory EquipmentDto.fromJson(Map<String, dynamic> json) {
    // Les valeurs numériques sont converties en `int` pour correspondre au domaine.
    return EquipmentDto(
      id: json['id'] as String,
      name: LocalizedTextDto.fromJson(
        Map<String, dynamic>.from(json['name'] as Map),
      ),
      type: json['type'] as String,
      weightG: (json['weight_g'] as num).toInt(),
      cost: (json['cost'] as num).toInt(),
    );
  }

  EquipmentDef toDomain() => EquipmentDef(
        id: id,
        name: name.toDomain(),
        type: type,
        weightG: weightG,
        cost: cost,
      ); // Création du modèle de domaine utilisé par l'UI.
}

/// SuperiorityDiceRuleDto = DTO des règles de dés de supériorité.
@immutable
class SuperiorityDiceRuleDto {
  final int count; // Nombre de dés disponibles.
  final int? die; // Taille du dé (null si non applicable).

  const SuperiorityDiceRuleDto({required this.count, this.die});

  factory SuperiorityDiceRuleDto.fromJson(Map<String, dynamic> json) {
    // Les valeurs numériques sont converties en int afin d'éviter les doubles.
    return SuperiorityDiceRuleDto(
      count: (json['count'] as num).toInt(),
      die: (json['die'] as num?)?.toInt(),
    );
  }

  SuperiorityDiceRule toDomain() =>
      SuperiorityDiceRule(count: count, die: die); // Mapping 1:1 vers le domaine.
}

/// FormulasDto = DTO des formules métier (hp, initiative...).
@immutable
class FormulasDto {
  final String rulesVersion; // Version des règles utilisées pour les formules.
  final String hpLevel1; // Formule de points de vie de niveau 1.
  final String defenseBase; // Expression calculant la Défense de base.
  final String initiative; // Expression de calcul de l'initiative.
  final Map<String, SuperiorityDiceRuleDto>
      superiorityDiceByClass; // Règles par identifiant de classe.

  const FormulasDto({
    required this.rulesVersion,
    required this.hpLevel1,
    required this.defenseBase,
    required this.initiative,
    required this.superiorityDiceByClass,
  });

  factory FormulasDto.fromJson(Map<String, dynamic> json) {
    final rawDice = Map<String, dynamic>.from(
        json['superiority_dice'] as Map); // Map brute "classe" -> définition.
    return FormulasDto(
      rulesVersion: json['rules_version'] as String,
      hpLevel1: json['hp_level1'] as String,
      defenseBase: json['defense_base'] as String,
      initiative: json['initiative'] as String,
      superiorityDiceByClass: rawDice.map(
        (key, value) => MapEntry(
          key,
          SuperiorityDiceRuleDto.fromJson(
            Map<String, dynamic>.from(value as Map),
          ),
        ),
      ),
    );
  }

  FormulasDef toDomain() => FormulasDef(
        rulesVersion: rulesVersion,
        hpLevel1: hpLevel1,
        defenseBase: defenseBase,
        initiative: initiative,
        superiorityDiceByClass: superiorityDiceByClass.map(
          (key, value) => MapEntry(key, value.toDomain()),
        ),
      ); // Retourne une map immuable de règles métiers exploitables.
}

/// TraitDto = DTO des traits d'espèce.
@immutable
class TraitDto {
  final String id; // Identifiant unique du trait.
  final LocalizedTextDto name; // Nom localisé.
  final String description; // Description longue montrée à l'utilisateur.

  const TraitDto({
    required this.id,
    required this.name,
    required this.description,
  });

  factory TraitDto.fromJson(Map<String, dynamic> json) {
    // Décodage direct des champs et conversion du nom localisé.
    return TraitDto(
      id: json['id'] as String,
      name: LocalizedTextDto.fromJson(
        Map<String, dynamic>.from(json['name'] as Map),
      ),
      description: json['description'] as String,
    );
  }

  TraitDef toDomain() => TraitDef(
        id: id,
        name: name.toDomain(),
        description: description,
      ); // Structure métier finale exposée à la présentation.
}
