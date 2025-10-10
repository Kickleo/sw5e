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
import 'package:meta/meta.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// LocalizedTextDto = version sérialisable de [LocalizedText].
@immutable
class LocalizedTextDto {
  final String en;
  final String fr;

  const LocalizedTextDto({required this.en, required this.fr});

  factory LocalizedTextDto.fromJson(Map<String, dynamic> json) {
    return LocalizedTextDto(
      en: json['en'] as String,
      fr: json['fr'] as String,
    );
  }

  LocalizedText toDomain() => LocalizedText(en: en, fr: fr);
}

/// SpeciesDto = structure JSON des espèces (assets/catalog/species.json).
@immutable
class SpeciesDto {
  final String id;
  final LocalizedTextDto name;
  final int speed;
  final String size;
  final List<String> traitIds;

  const SpeciesDto({
    required this.id,
    required this.name,
    required this.speed,
    required this.size,
    required this.traitIds,
  });

  factory SpeciesDto.fromJson(Map<String, dynamic> json) {
    return SpeciesDto(
      id: json['id'] as String,
      name: LocalizedTextDto.fromJson(
        Map<String, dynamic>.from(json['name'] as Map),
      ),
      speed: (json['speed'] as num).toInt(),
      size: json['size'] as String,
      traitIds: List<String>.from(json['traits'] as List? ?? const <String>[]),
    );
  }

  SpeciesDef toDomain() => SpeciesDef(
        id: id,
        name: name.toDomain(),
        speed: speed,
        size: size,
        traitIds: List<String>.unmodifiable(traitIds),
      );
}

/// StartingEquipmentLineDto = ligne d'équipement initial pour une classe.
@immutable
class StartingEquipmentLineDto {
  final String id;
  final int qty;

  const StartingEquipmentLineDto({required this.id, required this.qty});

  factory StartingEquipmentLineDto.fromJson(Map<String, dynamic> json) {
    return StartingEquipmentLineDto(
      id: json['id'] as String,
      qty: (json['qty'] as num).toInt(),
    );
  }

  StartingEquipmentLine toDomain() => StartingEquipmentLine(id: id, qty: qty);
}

/// ClassLevel1ProficienciesDto = DTO des maîtrises niveau 1.
@immutable
class ClassLevel1ProficienciesDto {
  final int skillsChoose;
  final List<String> skillsFrom;

  const ClassLevel1ProficienciesDto({
    required this.skillsChoose,
    required this.skillsFrom,
  });

  factory ClassLevel1ProficienciesDto.fromJson(Map<String, dynamic> json) {
    return ClassLevel1ProficienciesDto(
      skillsChoose: (json['skills_choose'] as num).toInt(),
      skillsFrom: List<String>.from(json['skills_from'] as List? ?? const <String>[]),
    );
  }

  ClassLevel1Proficiencies toDomain() => ClassLevel1Proficiencies(
        skillsChoose: skillsChoose,
        skillsFrom: List<String>.unmodifiable(skillsFrom),
      );
}

/// ClassLevel1Dto = bloc niveau 1 d'une classe (équipement, crédits...).
@immutable
class ClassLevel1Dto {
  final ClassLevel1ProficienciesDto proficiencies;
  final int? startingCredits;
  final String? startingCreditsRoll;
  final List<StartingEquipmentLineDto> startingEquipment;
  final List<String> startingEquipmentOptions;

  const ClassLevel1Dto({
    required this.proficiencies,
    required this.startingCredits,
    required this.startingCreditsRoll,
    required this.startingEquipment,
    required this.startingEquipmentOptions,
  });

  factory ClassLevel1Dto.fromJson(Map<String, dynamic> json) {
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
      startingEquipmentOptions: List<String>.from(
        json['starting_equipment_options'] as List? ?? const <String>[],
      ),
    );
  }

  ClassLevel1Data toDomain() => ClassLevel1Data(
        proficiencies: proficiencies.toDomain(),
        startingCredits: startingCredits,
        startingCreditsRoll: startingCreditsRoll,
        startingEquipment: startingEquipment
            .map((dto) => dto.toDomain())
            .toList(growable: false),
        startingEquipmentOptions:
            List<String>.unmodifiable(startingEquipmentOptions),
      );
}

/// ClassDto = représentation JSON d'une classe niveau 1.
@immutable
class ClassDto {
  final String id;
  final LocalizedTextDto name;
  final int hitDie;
  final ClassLevel1Dto level1;

  const ClassDto({
    required this.id,
    required this.name,
    required this.hitDie,
    required this.level1,
  });

  factory ClassDto.fromJson(Map<String, dynamic> json) {
    return ClassDto(
      id: json['id'] as String,
      name: LocalizedTextDto.fromJson(
        Map<String, dynamic>.from(json['name'] as Map),
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
        hitDie: hitDie,
        level1: level1.toDomain(),
      );
}

/// BackgroundDto = DTO des historiques.
@immutable
class BackgroundDto {
  final String id;
  final LocalizedTextDto name;
  final List<String> grantedSkills;

  const BackgroundDto({
    required this.id,
    required this.name,
    required this.grantedSkills,
  });

  factory BackgroundDto.fromJson(Map<String, dynamic> json) {
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
      );
}

/// SkillDto = DTO des compétences.
@immutable
class SkillDto {
  final String id;
  final String ability;

  const SkillDto({required this.id, required this.ability});

  factory SkillDto.fromJson(Map<String, dynamic> json) {
    return SkillDto(
      id: json['id'] as String,
      ability: json['ability'] as String,
    );
  }

  SkillDef toDomain() => SkillDef(id: id, ability: ability);
}

/// EquipmentDto = DTO du matériel.
@immutable
class EquipmentDto {
  final String id;
  final LocalizedTextDto name;
  final String type;
  final int weightG;
  final int cost;

  const EquipmentDto({
    required this.id,
    required this.name,
    required this.type,
    required this.weightG,
    required this.cost,
  });

  factory EquipmentDto.fromJson(Map<String, dynamic> json) {
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
      );
}

/// SuperiorityDiceRuleDto = DTO des règles de dés de supériorité.
@immutable
class SuperiorityDiceRuleDto {
  final int count;
  final int? die;

  const SuperiorityDiceRuleDto({required this.count, this.die});

  factory SuperiorityDiceRuleDto.fromJson(Map<String, dynamic> json) {
    return SuperiorityDiceRuleDto(
      count: (json['count'] as num).toInt(),
      die: (json['die'] as num?)?.toInt(),
    );
  }

  SuperiorityDiceRule toDomain() =>
      SuperiorityDiceRule(count: count, die: die);
}

/// FormulasDto = DTO des formules métier (hp, initiative...).
@immutable
class FormulasDto {
  final String rulesVersion;
  final String hpLevel1;
  final String defenseBase;
  final String initiative;
  final Map<String, SuperiorityDiceRuleDto> superiorityDiceByClass;

  const FormulasDto({
    required this.rulesVersion,
    required this.hpLevel1,
    required this.defenseBase,
    required this.initiative,
    required this.superiorityDiceByClass,
  });

  factory FormulasDto.fromJson(Map<String, dynamic> json) {
    final rawDice = Map<String, dynamic>.from(json['superiority_dice'] as Map);
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
      );
}

/// TraitDto = DTO des traits d'espèce.
@immutable
class TraitDto {
  final String id;
  final LocalizedTextDto name;
  final String description;

  const TraitDto({
    required this.id,
    required this.name,
    required this.description,
  });

  factory TraitDto.fromJson(Map<String, dynamic> json) {
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
      );
}
