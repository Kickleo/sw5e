/// ---------------------------------------------------------------------------
/// Fichier : lib/data/catalog_v2/dtos/catalog_v2_dtos.dart
/// Rôle : Définir les DTOs propres au catalogue v2 (assets/catalog_v2).
/// Dépendances : LocalizedTextDto pour convertir les champs localisés.
/// Exemple :
///   final dto = CatalogV2SpeciesDto.fromJson(jsonMap);
/// ---------------------------------------------------------------------------
library;

import 'package:meta/meta.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

@immutable
class LocalizedTextDto {
  const LocalizedTextDto({
    required this.en,
    required this.fr,
    this.otherTranslations = const <String, String>{},
  });

  factory LocalizedTextDto.fromJson(Map<String, dynamic> json) {
    final Map<String, String> normalized = _readLocalizedMap(json);
    final Map<String, String> others = Map<String, String>.from(normalized)
      ..remove('en')
      ..remove('fr');

    final String resolvedEn = _resolveLocalizedValue(
      normalized['en'],
      normalized['fr'],
      others.values,
    );
    final String resolvedFr = _resolveLocalizedValue(
      normalized['fr'],
      resolvedEn,
      others.values,
    );

    return LocalizedTextDto(
      en: resolvedEn,
      fr: resolvedFr,
      otherTranslations: Map<String, String>.unmodifiable(others),
    );
  }

  static LocalizedTextDto fromAny(dynamic raw) {
    final LocalizedTextDto? maybe = maybeFromAny(raw);
    if (maybe != null) {
      return maybe;
    }
    throw ArgumentError('Unsupported localized value: ${raw.runtimeType}');
  }

  static LocalizedTextDto? maybeFromAny(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is LocalizedTextDto) {
      return raw;
    }
    if (raw is LocalizedText) {
      return LocalizedTextDto(
        en: raw.en,
        fr: raw.fr,
        otherTranslations: raw.otherTranslations,
      );
    }
    if (raw is String) {
      final String trimmed = raw.trim();
      return LocalizedTextDto(en: trimmed, fr: trimmed);
    }
    if (raw is Map<String, dynamic>) {
      return LocalizedTextDto.fromJson(raw);
    }
    if (raw is Map) {
      return LocalizedTextDto.fromJson(
        raw.map(
          (dynamic key, dynamic value) => MapEntry(key.toString(), value),
        ),
      );
    }
    return null;
  }

  final String en;
  final String fr;
  final Map<String, String> otherTranslations;

  LocalizedText toDomain() => LocalizedText(
        en: en,
        fr: fr,
        otherTranslations: otherTranslations,
      );
}

String _resolveLocalizedValue(
  String? primary,
  String? fallback,
  Iterable<String> additionalFallbacks,
) {
  final String? trimmedPrimary = primary?.trim();
  if (trimmedPrimary != null && trimmedPrimary.isNotEmpty) {
    return trimmedPrimary;
  }
  final String? trimmedFallback = fallback?.trim();
  if (trimmedFallback != null && trimmedFallback.isNotEmpty) {
    return trimmedFallback;
  }
  for (final String candidate in additionalFallbacks) {
    final String trimmed = candidate.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return '';
}

Map<String, String> _readLocalizedMap(dynamic raw) {
  if (raw == null) {
    return const <String, String>{};
  }
  if (raw is Map<String, dynamic>) {
    final Map<String, String> result = <String, String>{};
    raw.forEach((String key, dynamic value) {
      final String? resolved = _readLocalizedScalar(value);
      if (resolved != null && resolved.trim().isNotEmpty) {
        result[key.toLowerCase()] = resolved.trim();
      }
    });
    return result;
  }
  if (raw is Map) {
    final Map<String, dynamic> converted = raw.map(
      (dynamic key, dynamic value) => MapEntry(key.toString(), value),
    );
    return _readLocalizedMap(converted);
  }
  final String? scalar = _readLocalizedScalar(raw);
  if (scalar == null || scalar.trim().isEmpty) {
    return const <String, String>{};
  }
  return <String, String>{'und': scalar.trim()};
}

String? _readLocalizedScalar(dynamic raw) {
  if (raw == null) {
    return null;
  }
  if (raw is String) {
    return raw;
  }
  if (raw is LocalizedTextDto) {
    return raw.en.trim().isNotEmpty ? raw.en : raw.fr;
  }
  if (raw is LocalizedText) {
    return raw.en.trim().isNotEmpty ? raw.en : raw.fr;
  }
  if (raw is Map<String, dynamic>) {
    for (final MapEntry<String, dynamic> entry in raw.entries) {
      final String? nested = _readLocalizedScalar(entry.value);
      if (nested != null && nested.trim().isNotEmpty) {
        return nested;
      }
    }
    return null;
  }
  if (raw is Map) {
    return _readLocalizedScalar(
      raw.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      ),
    );
  }
  if (raw is Iterable) {
    for (final dynamic value in raw) {
      final String? nested = _readLocalizedScalar(value);
      if (nested != null && nested.trim().isNotEmpty) {
        return nested;
      }
    }
    return null;
  }
  return raw.toString();
}

@immutable
class CatalogV2AbilityDto {
  const CatalogV2AbilityDto({
    required this.id,
    required this.slug,
    required this.abbr,
    required this.name,
    this.description,
  });

  factory CatalogV2AbilityDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2AbilityDto(
      id: json['id'] as String,
      slug: (json['slug'] as String).toLowerCase(),
      abbr: (json['abbr'] as String).toUpperCase(),
      name: LocalizedTextDto.fromAny(json['name']),
      description: LocalizedTextDto.maybeFromAny(json['description']),
    );
  }

  final String id;
  final String slug;
  final String abbr;
  final LocalizedTextDto name;
  final LocalizedTextDto? description;
}

@immutable
class CatalogV2SkillDto {
  const CatalogV2SkillDto({
    required this.id,
    required this.slug,
    required this.abilityRef,
    required this.name,
  });

  factory CatalogV2SkillDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2SkillDto(
      id: json['id'] as String,
      slug: (json['slug'] as String).toLowerCase(),
      abilityRef: json['ability_ref'] as String,
      name: LocalizedTextDto.fromAny(json['name']),
    );
  }

  final String id;
  final String slug;
  final String abilityRef;
  final LocalizedTextDto name;
}

@immutable
class CatalogV2LanguageDto {
  const CatalogV2LanguageDto({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.script,
    this.typicalSpeakers = const <CatalogV2LanguageSpeakerDto>[],
  });

  factory CatalogV2LanguageDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawSpeakers = json['typical_speakers'] as List?;
    return CatalogV2LanguageDto(
      id: json['id'] as String,
      slug: (json['slug'] as String).toLowerCase(),
      name: LocalizedTextDto.fromAny(json['name']),
      description: LocalizedTextDto.maybeFromAny(json['description']),
      script: LocalizedTextDto.maybeFromAny(json['script']),
      typicalSpeakers: rawSpeakers == null
          ? const <CatalogV2LanguageSpeakerDto>[]
          : rawSpeakers
              .whereType<Map<String, dynamic>>()
              .map(CatalogV2LanguageSpeakerDto.fromJson)
              .toList(growable: false),
    );
  }

  final String id;
  final String slug;
  final LocalizedTextDto name;
  final LocalizedTextDto? description;
  final LocalizedTextDto? script;
  final List<CatalogV2LanguageSpeakerDto> typicalSpeakers;
}

@immutable
class CatalogV2LanguageSpeakerDto {
  const CatalogV2LanguageSpeakerDto({
    required this.type,
    required this.id,
    this.name,
  });

  factory CatalogV2LanguageSpeakerDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2LanguageSpeakerDto(
      type: (json['type'] as String?)?.toLowerCase() ?? 'unknown',
      id: json['id'] as String? ?? '',
      name: LocalizedTextDto.maybeFromAny(json['name']),
    );
  }

  final String type;
  final String id;
  final LocalizedTextDto? name;
}

@immutable
class CatalogV2EquipmentDto {
  const CatalogV2EquipmentDto({
    required this.id,
    required this.slug,
    required this.category,
    required this.name,
    this.costCredits,
    this.weightKg,
    this.rarity,
    this.description,
  });

  factory CatalogV2EquipmentDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? rawCost =
        json['cost'] as Map<String, dynamic>?;
    final Map<String, dynamic>? cost =
        rawCost == null ? null : Map<String, dynamic>.from(rawCost);
    return CatalogV2EquipmentDto(
      id: json['id'] as String,
      slug: (json['slug'] as String).toLowerCase(),
      category: (json['category'] as String).toLowerCase(),
      name: LocalizedTextDto.fromAny(json['name']),
      costCredits: (cost?['credits'] as num?)?.toInt(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      rarity: (json['rarity'] as String?)?.toLowerCase(),
      description: LocalizedTextDto.maybeFromAny(json['description']),
    );
  }

  final String id;
  final String slug;
  final String category;
  final LocalizedTextDto name;
  final int? costCredits;
  final double? weightKg;
  final String? rarity;
  final LocalizedTextDto? description;
}

@immutable
class CatalogV2DamageTypeDto {
  const CatalogV2DamageTypeDto({
    required this.id,
    required this.slug,
    required this.name,
    this.notes,
  });

  factory CatalogV2DamageTypeDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2DamageTypeDto(
      id: json['id'] as String,
      slug: (json['slug'] as String).toLowerCase(),
      name: LocalizedTextDto.fromAny(json['name']),
      notes: LocalizedTextDto.maybeFromAny(json['notes']),
    );
  }

  final String id;
  final String slug;
  final LocalizedTextDto name;
  final LocalizedTextDto? notes;
}

@immutable
class CatalogV2WeaponDamageDto {
  const CatalogV2WeaponDamageDto({
    required this.typeRef,
    this.diceCount,
    this.diceDie,
    this.diceModifier,
  });

  factory CatalogV2WeaponDamageDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? rawDice =
        json['dice'] as Map<String, dynamic>?;
    return CatalogV2WeaponDamageDto(
      typeRef: json['type_ref'] as String,
      diceCount: (rawDice?['count'] as num?)?.toInt(),
      diceDie: (rawDice?['die'] as num?)?.toInt(),
      diceModifier: (rawDice?['modifier'] as num?)?.toInt(),
    );
  }

  final String typeRef;
  final int? diceCount;
  final int? diceDie;
  final int? diceModifier;
}

@immutable
class CatalogV2WeaponDto {
  const CatalogV2WeaponDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    this.costCredits,
    this.weightKg,
    this.rarity,
    this.description,
    this.damage = const <CatalogV2WeaponDamageDto>[],
    this.rangePrimaryMeters,
    this.rangeMaxMeters,
    this.properties = const <String>[],
  });

  factory CatalogV2WeaponDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? rawCost =
        json['cost'] as Map<String, dynamic>?;
    final List<dynamic>? rawDamage = json['damage'] as List?;
    return CatalogV2WeaponDto(
      id: json['id'] as String,
      slug: (json['slug'] as String).toLowerCase(),
      name: LocalizedTextDto.fromAny(json['name']),
      category: (json['category'] as String?)?.toLowerCase() ?? 'weapon',
      costCredits: (rawCost?['credits'] as num?)?.toInt(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      rarity: (json['rarity'] as String?)?.toLowerCase(),
      description: LocalizedTextDto.maybeFromAny(json['description']),
      damage: rawDamage == null
          ? const <CatalogV2WeaponDamageDto>[]
          : rawDamage
              .whereType<Map<String, dynamic>>()
              .map(CatalogV2WeaponDamageDto.fromJson)
              .toList(growable: false),
      rangePrimaryMeters: (json['range_primary_m'] as num?)?.toInt(),
      rangeMaxMeters: (json['range_max_m'] as num?)?.toInt(),
      properties: (json['properties'] as List?)
              ?.whereType<String>()
              .map((String value) => value.toLowerCase())
              .toList(growable: false) ??
          const <String>[],
    );
  }

  final String id;
  final String slug;
  final LocalizedTextDto name;
  final String category;
  final int? costCredits;
  final double? weightKg;
  final String? rarity;
  final LocalizedTextDto? description;
  final List<CatalogV2WeaponDamageDto> damage;
  final int? rangePrimaryMeters;
  final int? rangeMaxMeters;
  final List<String> properties;
}

@immutable
class CatalogV2TraitDto {
  const CatalogV2TraitDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
  });

  factory CatalogV2TraitDto.fromJson(Map<String, dynamic> json) {
    final LocalizedTextDto? description =
        LocalizedTextDto.maybeFromAny(json['description']);
    LocalizedTextDto resolvedDescription;
    if (description != null) {
      resolvedDescription = description;
    } else {
      final List<Map<String, dynamic>> effects =
          List<Map<String, dynamic>>.from(
        json['effects'] as List? ?? const <Map<String, dynamic>>[],
      );
      final LocalizedTextDto aggregated = _aggregateEffectTexts(effects);
      resolvedDescription = aggregated;
    }

    return CatalogV2TraitDto(
      id: json['id'] as String,
      slug: (json['slug'] as String).toLowerCase(),
      name: LocalizedTextDto.fromAny(json['name']),
      description: resolvedDescription,
    );
  }

  final String id;
  final String slug;
  final LocalizedTextDto name;
  final LocalizedTextDto description;
}

LocalizedTextDto _aggregateEffectTexts(
    List<Map<String, dynamic>> effects) {
  final List<String> en = <String>[];
  final List<String> fr = <String>[];
  for (final Map<String, dynamic> effect in effects) {
    final LocalizedTextDto? text =
        LocalizedTextDto.maybeFromAny(effect['text']);
    if (text == null) {
      continue;
    }
    if (text.en.trim().isNotEmpty) {
      en.add(text.en.trim());
    }
    if (text.fr.trim().isNotEmpty) {
      fr.add(text.fr.trim());
    }
  }
  return LocalizedTextDto(
    en: en.join('\n'),
    fr: fr.join('\n'),
    otherTranslations: const <String, String>{},
  );
}

@immutable
class CatalogV2SpeciesDto {
  const CatalogV2SpeciesDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.size,
    required this.speedMeters,
    required this.abilityIncreases,
    required this.languageIds,
    required this.traitIds,
    this.descriptionShort,
    this.description,
  });

  factory CatalogV2SpeciesDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> abilityMap =
        Map<String, dynamic>.from(json['ability_increases'] as Map? ?? const {});
    final Map<String, int> parsedAbilityIncreases = abilityMap.map(
      (String key, dynamic value) => MapEntry(
        key.toUpperCase(),
        (value as num).toInt(),
      ),
    );

    final List<String> languages =
        List<String>.from(json['languages'] as List? ?? const <String>[]);

    final List<String> traitIds = <String>[];
    for (final dynamic entry in json['traits'] as List? ?? const <dynamic>[]) {
      if (entry is Map<String, dynamic>) {
        final String? id = entry['id'] as String?;
        if (id != null && id.isNotEmpty) {
          traitIds.add(id);
        }
      } else if (entry is String) {
        traitIds.add(entry);
      }
    }

    return CatalogV2SpeciesDto(
      id: json['id'] as String,
      slug: (json['slug'] as String).toLowerCase(),
      name: LocalizedTextDto.fromAny(json['name']),
      size: (json['size'] as String).toLowerCase(),
      speedMeters: (json['speed_m'] as num?)?.toDouble(),
      abilityIncreases: parsedAbilityIncreases,
      languageIds: List<String>.unmodifiable(languages),
      traitIds: List<String>.unmodifiable(traitIds),
      descriptionShort: LocalizedTextDto.maybeFromAny(json['description_short']),
      description: LocalizedTextDto.maybeFromAny(json['description']),
    );
  }

  final String id;
  final String slug;
  final LocalizedTextDto name;
  final String size;
  final double? speedMeters;
  final Map<String, int> abilityIncreases;
  final List<String> languageIds;
  final List<String> traitIds;
  final LocalizedTextDto? descriptionShort;
  final LocalizedTextDto? description;
}

@immutable
class CatalogV2ClassDto {
  const CatalogV2ClassDto({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    required this.hitDie,
    required this.primaryAbilities,
    required this.savingThrows,
    required this.proficiencies,
    required this.featuresByLevel,
    this.startingCredits,
    this.startingCreditsRoll,
    required this.startingEquipment,
    required this.startingEquipmentOptions,
    this.powerSource,
    this.powerList,
    this.multiclassing,
  });

  factory CatalogV2ClassDto.fromJson(Map<String, dynamic> json) {
    final List<String> primary = List<String>.from(
      (json['primary_abilities'] as List? ?? const <String>[])
          .map((dynamic value) => (value as String).toUpperCase()),
    );
    final List<String> saves = List<String>.from(
      (json['saving_throws'] as List? ?? const <String>[])
          .map((dynamic value) => (value as String).toUpperCase()),
    );
    final Map<int, List<CatalogV2ClassFeatureDto>> featuresByLevel =
        <int, List<CatalogV2ClassFeatureDto>>{};
    final Map<String, dynamic>? rawFeatures =
        json['features_by_level'] as Map<String, dynamic>?;
    if (rawFeatures != null) {
      for (final MapEntry<String, dynamic> entry in rawFeatures.entries) {
        final int? level = int.tryParse(entry.key);
        if (level == null || level <= 0) {
          continue;
        }
        final dynamic value = entry.value;
        if (value is List) {
          final List<CatalogV2ClassFeatureDto> features = value
              .whereType<Map<String, dynamic>>()
              .map(
                (Map<String, dynamic> item) =>
                    CatalogV2ClassFeatureDto.fromJson(item),
              )
              .toList(growable: false);
          if (features.isNotEmpty) {
            featuresByLevel[level] = List<CatalogV2ClassFeatureDto>.unmodifiable(
              features,
            );
          }
        }
      }
    }
    final Map<String, dynamic>? rawPowerList =
        json['power_list'] as Map<String, dynamic>?;
    final CatalogV2ClassPowerListDto? powerList = rawPowerList == null
        ? null
        : CatalogV2ClassPowerListDto.fromJson(
            Map<String, dynamic>.from(rawPowerList),
          );

    final Map<String, dynamic>? rawMulticlassing =
        json['multiclassing'] as Map<String, dynamic>?;
    final CatalogV2ClassMulticlassingDto? multiclassing = rawMulticlassing ==
            null
        ? null
        : CatalogV2ClassMulticlassingDto.fromJson(
            Map<String, dynamic>.from(rawMulticlassing),
          );

    final List<CatalogV2EquipmentGrantDto> startingEquipment =
        <CatalogV2EquipmentGrantDto>[];
    for (final dynamic entry
        in json['starting_equipment'] as List? ?? const <dynamic>[]) {
      if (entry is Map<String, dynamic>) {
        startingEquipment.add(
          CatalogV2EquipmentGrantDto.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        );
      }
    }

    final List<LocalizedTextDto> startingEquipmentOptions =
        <LocalizedTextDto>[];
    for (final dynamic entry in json['starting_equipment_options'] as List?
            ?? const <dynamic>[]) {
      final LocalizedTextDto? text = LocalizedTextDto.maybeFromAny(entry);
      if (text != null) {
        startingEquipmentOptions.add(text);
      }
    }

    return CatalogV2ClassDto(
      id: json['id'] as String,
      slug: (json['slug'] as String).toLowerCase(),
      name: LocalizedTextDto.fromAny(json['name']),
      description: LocalizedTextDto.maybeFromAny(json['description']),
      hitDie: (json['hit_die'] as num).toInt(),
      primaryAbilities: primary,
      savingThrows: saves,
      proficiencies: CatalogV2ClassProficienciesDto.fromJson(
        Map<String, dynamic>.from(json['proficiencies'] as Map),
      ),
      featuresByLevel:
          Map<int, List<CatalogV2ClassFeatureDto>>.unmodifiable(featuresByLevel),
      startingCredits: (json['starting_credits'] as num?)?.toInt(),
      startingCreditsRoll: json['starting_credits_roll'] as String?,
      startingEquipment:
          List<CatalogV2EquipmentGrantDto>.unmodifiable(startingEquipment),
      startingEquipmentOptions:
          List<LocalizedTextDto>.unmodifiable(startingEquipmentOptions),
      powerSource: (json['power_source'] as String?)?.toLowerCase(),
      powerList: powerList,
      multiclassing: multiclassing,
    );
  }

  final String id;
  final String slug;
  final LocalizedTextDto name;
  final LocalizedTextDto? description;
  final int hitDie;
  final List<String> primaryAbilities;
  final List<String> savingThrows;
  final CatalogV2ClassProficienciesDto proficiencies;
  final Map<int, List<CatalogV2ClassFeatureDto>> featuresByLevel;
  final int? startingCredits;
  final String? startingCreditsRoll;
  final List<CatalogV2EquipmentGrantDto> startingEquipment;
  final List<LocalizedTextDto> startingEquipmentOptions;
  final String? powerSource;
  final CatalogV2ClassPowerListDto? powerList;
  final CatalogV2ClassMulticlassingDto? multiclassing;
}

@immutable
class CatalogV2ClassPowerListDto {
  const CatalogV2ClassPowerListDto({
    required this.forceAllowed,
    required this.techAllowed,
    this.spellcastingProgression,
  });

  factory CatalogV2ClassPowerListDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2ClassPowerListDto(
      forceAllowed: json['force_allowed'] as bool? ?? false,
      techAllowed: json['tech_allowed'] as bool? ?? false,
      spellcastingProgression:
          (json['spellcasting_progression'] as String?)?.toLowerCase(),
    );
  }

  final bool forceAllowed;
  final bool techAllowed;
  final String? spellcastingProgression;
}

@immutable
class CatalogV2ClassProficienciesDto {
  const CatalogV2ClassProficienciesDto({
    required this.skillsPick,
    required this.skillRefs,
    required this.weaponCategories,
    required this.armorCategories,
    required this.toolProficiencies,
  });

  factory CatalogV2ClassProficienciesDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2ClassProficienciesDto(
      skillsPick: (json['skills_pick'] as num?)?.toInt() ?? 0,
      skillRefs: List<String>.from(
        (json['skills_list'] as List? ?? const <String>[])
            .map((dynamic value) => value as String),
      ),
      weaponCategories: List<String>.from(
        (json['weapons'] as List? ?? const <String>[])
            .map((dynamic value) => (value as String).toLowerCase()),
      ),
      armorCategories: List<String>.from(
        (json['armors'] as List? ?? const <String>[])
            .map((dynamic value) => (value as String).toLowerCase()),
      ),
      toolProficiencies: List<String>.from(
        (json['tools'] as List? ?? const <String>[])
            .map((dynamic value) => (value as String).toLowerCase()),
      ),
    );
  }

  final int skillsPick;
  final List<String> skillRefs;
  final List<String> weaponCategories;
  final List<String> armorCategories;
  final List<String> toolProficiencies;
}

@immutable
class CatalogV2ClassMulticlassingDto {
  const CatalogV2ClassMulticlassingDto({
    required this.requirements,
  });

  factory CatalogV2ClassMulticlassingDto.fromJson(Map<String, dynamic> json) {
    final Map<String, int> requirements = <String, int>{};
    final Map<String, dynamic>? rawRequirements =
        json['requirements'] as Map<String, dynamic>?;
    if (rawRequirements != null) {
      rawRequirements.forEach((String key, dynamic value) {
        if (value is num) {
          requirements[key.toUpperCase()] = value.toInt();
        }
      });
    }
    return CatalogV2ClassMulticlassingDto(
      requirements: Map<String, int>.unmodifiable(requirements),
    );
  }

  final Map<String, int> requirements;
}

@immutable
class CatalogV2ClassFeatureDto {
  const CatalogV2ClassFeatureDto({
    required this.name,
    this.text,
    required this.effects,
  });

  factory CatalogV2ClassFeatureDto.fromJson(Map<String, dynamic> json) {
    final List<CatalogV2FeatureEffectDto> effects =
        <CatalogV2FeatureEffectDto>[];
    for (final dynamic entry in json['effects'] as List? ?? const <dynamic>[]) {
      if (entry is Map<String, dynamic>) {
        effects.add(
          CatalogV2FeatureEffectDto.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        );
      }
    }
    return CatalogV2ClassFeatureDto(
      name: LocalizedTextDto.fromAny(json['name']),
      text: LocalizedTextDto.maybeFromAny(json['text']),
      effects: List<CatalogV2FeatureEffectDto>.unmodifiable(effects),
    );
  }

  final LocalizedTextDto name;
  final LocalizedTextDto? text;
  final List<CatalogV2FeatureEffectDto> effects;
}

@immutable
class CatalogV2BackgroundDto {
  const CatalogV2BackgroundDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.skillProficiencies,
    required this.toolProficiencies,
    required this.languagesPick,
    required this.equipment,
    this.feature,
    this.personality,
  });

  factory CatalogV2BackgroundDto.fromJson(Map<String, dynamic> json) {
    final List<String> skillProficiencies = List<String>.from(
      json['skill_proficiencies'] as List? ?? const <String>[],
    );
    final List<String> toolProficiencies = List<String>.from(
      json['tool_proficiencies'] as List? ?? const <String>[],
    );
    final List<CatalogV2EquipmentGrantDto> equipment =
        <CatalogV2EquipmentGrantDto>[];
    for (final dynamic entry in json['equipment'] as List? ?? const <dynamic>[]) {
      if (entry is Map<String, dynamic>) {
        equipment.add(
          CatalogV2EquipmentGrantDto.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        );
      }
    }
    final Map<String, dynamic>? rawFeature =
        json['feature'] as Map<String, dynamic>?;
    final Map<String, dynamic>? rawPersonality =
        json['personality'] as Map<String, dynamic>?;

    return CatalogV2BackgroundDto(
      id: json['id'] as String,
      slug: (json['slug'] as String).toLowerCase(),
      name: LocalizedTextDto.fromAny(json['name']),
      skillProficiencies: List<String>.unmodifiable(skillProficiencies),
      toolProficiencies: List<String>.unmodifiable(toolProficiencies),
      languagesPick: (json['languages_pick'] as num?)?.toInt() ?? 0,
      equipment: List<CatalogV2EquipmentGrantDto>.unmodifiable(equipment),
      feature: rawFeature == null
          ? null
          : CatalogV2BackgroundFeatureDto.fromJson(
              Map<String, dynamic>.from(rawFeature),
            ),
      personality: rawPersonality == null
          ? null
          : CatalogV2BackgroundPersonalityDto.fromJson(
              Map<String, dynamic>.from(rawPersonality),
            ),
    );
  }

  final String id;
  final String slug;
  final LocalizedTextDto name;
  final List<String> skillProficiencies;
  final List<String> toolProficiencies;
  final int languagesPick;
  final List<CatalogV2EquipmentGrantDto> equipment;
  final CatalogV2BackgroundFeatureDto? feature;
  final CatalogV2BackgroundPersonalityDto? personality;
}

@immutable
class CatalogV2BackgroundFeatureDto {
  const CatalogV2BackgroundFeatureDto({
    required this.name,
    required this.effects,
  });

  factory CatalogV2BackgroundFeatureDto.fromJson(Map<String, dynamic> json) {
    final List<CatalogV2FeatureEffectDto> effects =
        <CatalogV2FeatureEffectDto>[];
    for (final dynamic entry in json['effects'] as List? ?? const <dynamic>[]) {
      if (entry is Map<String, dynamic>) {
        effects.add(
          CatalogV2FeatureEffectDto.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        );
      }
    }
    return CatalogV2BackgroundFeatureDto(
      name: LocalizedTextDto.fromAny(json['name']),
      effects: List<CatalogV2FeatureEffectDto>.unmodifiable(effects),
    );
  }

  final LocalizedTextDto name;
  final List<CatalogV2FeatureEffectDto> effects;
}

@immutable
class CatalogV2FeatureEffectDto {
  const CatalogV2FeatureEffectDto({
    required this.id,
    required this.kind,
    this.target,
    this.text,
  });

  factory CatalogV2FeatureEffectDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2FeatureEffectDto(
      id: json['id'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      target: json['target'] as String?,
      text: LocalizedTextDto.maybeFromAny(json['text']),
    );
  }

  final String id;
  final String kind;
  final String? target;
  final LocalizedTextDto? text;
}

@immutable
class CatalogV2CustomizationOptionDto {
  const CatalogV2CustomizationOptionDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    this.effects = const <CatalogV2FeatureEffectDto>[],
    this.prerequisite,
  });

  factory CatalogV2CustomizationOptionDto.fromJson(
      Map<String, dynamic> json) {
    final List<CatalogV2FeatureEffectDto> effects =
        <CatalogV2FeatureEffectDto>[];
    for (final dynamic entry in json['effects'] as List? ?? const <dynamic>[]) {
      if (entry is Map<String, dynamic>) {
        effects.add(CatalogV2FeatureEffectDto.fromJson(entry));
      } else if (entry is Map) {
        effects.add(
          CatalogV2FeatureEffectDto.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        );
      }
    }

    final Map<String, dynamic>? prerequisite =
        json['prerequisite'] as Map<String, dynamic>?;

    return CatalogV2CustomizationOptionDto(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: LocalizedTextDto.fromJson(
        Map<String, dynamic>.from(json['name'] as Map? ?? const {}),
      ),
      category: json['category'] as String? ?? '',
      effects: List<CatalogV2FeatureEffectDto>.unmodifiable(effects),
      prerequisite: prerequisite == null
          ? null
          : CatalogV2CustomizationPrerequisiteDto.fromJson(prerequisite),
    );
  }

  final String id;
  final String slug;
  final LocalizedTextDto name;
  final String category;
  final List<CatalogV2FeatureEffectDto> effects;
  final CatalogV2CustomizationPrerequisiteDto? prerequisite;
}

@immutable
class CatalogV2CustomizationPrerequisiteDto {
  const CatalogV2CustomizationPrerequisiteDto({
    this.all = const <CatalogV2CustomizationPrerequisiteDto>[],
    this.any = const <CatalogV2CustomizationPrerequisiteDto>[],
    this.condition,
  });

  factory CatalogV2CustomizationPrerequisiteDto.fromJson(
      Map<String, dynamic> json) {
    final List<CatalogV2CustomizationPrerequisiteDto> all =
        <CatalogV2CustomizationPrerequisiteDto>[];
    final List<CatalogV2CustomizationPrerequisiteDto> any =
        <CatalogV2CustomizationPrerequisiteDto>[];

    for (final dynamic entry in json['and'] as List? ?? const <dynamic>[]) {
      if (entry is Map<String, dynamic>) {
        all.add(CatalogV2CustomizationPrerequisiteDto.fromJson(entry));
      } else if (entry is Map) {
        all.add(
          CatalogV2CustomizationPrerequisiteDto.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        );
      }
    }

    for (final dynamic entry in json['or'] as List? ?? const <dynamic>[]) {
      if (entry is Map<String, dynamic>) {
        any.add(CatalogV2CustomizationPrerequisiteDto.fromJson(entry));
      } else if (entry is Map) {
        any.add(
          CatalogV2CustomizationPrerequisiteDto.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        );
      }
    }

    final Map<String, dynamic> remaining = Map<String, dynamic>.from(json);
    remaining.remove('and');
    remaining.remove('or');

    return CatalogV2CustomizationPrerequisiteDto(
      all: List<CatalogV2CustomizationPrerequisiteDto>.unmodifiable(all),
      any: List<CatalogV2CustomizationPrerequisiteDto>.unmodifiable(any),
      condition: remaining.isEmpty
          ? null
          : CatalogV2CustomizationPrerequisiteConditionDto.fromJson(remaining),
    );
  }

  final List<CatalogV2CustomizationPrerequisiteDto> all;
  final List<CatalogV2CustomizationPrerequisiteDto> any;
  final CatalogV2CustomizationPrerequisiteConditionDto? condition;
}

@immutable
class CatalogV2CustomizationPrerequisiteConditionDto {
  const CatalogV2CustomizationPrerequisiteConditionDto({
    this.classId,
    this.minLevel,
    this.optionId,
    this.traitId,
    this.speciesId,
    this.backgroundId,
    this.raw = const <String, dynamic>{},
  });

  factory CatalogV2CustomizationPrerequisiteConditionDto.fromJson(
      Map<String, dynamic> json) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(json);
    return CatalogV2CustomizationPrerequisiteConditionDto(
      classId: normalized['class_id'] as String?,
      minLevel: (normalized['min_level'] as num?)?.toInt(),
      optionId: (normalized['option_id'] as String?) ??
          (normalized['option_slug'] as String?),
      traitId: (normalized['trait_id'] as String?) ??
          (normalized['trait_slug'] as String?),
      speciesId: (normalized['species_id'] as String?) ??
          (normalized['species_slug'] as String?),
      backgroundId: (normalized['background_id'] as String?) ??
          (normalized['background_slug'] as String?),
      raw: Map<String, dynamic>.unmodifiable(normalized),
    );
  }

  final String? classId;
  final int? minLevel;
  final String? optionId;
  final String? traitId;
  final String? speciesId;
  final String? backgroundId;
  final Map<String, dynamic> raw;
}

@immutable
class CatalogV2PowerDto {
  const CatalogV2PowerDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.level,
    required this.castingTime,
    required this.description,
    this.range,
    this.duration,
    this.components = const <String>[],
    this.effects = const <CatalogV2FeatureEffectDto>[],
    this.classes = const <CatalogV2PowerClassRefDto>[],
    this.alignment,
    this.school,
  });

  factory CatalogV2PowerDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? rawRange =
        json['range'] as Map<String, dynamic>?;
    final Map<String, dynamic>? rawDuration =
        json['duration'] as Map<String, dynamic>?;

    final List<String> components = List<String>.from(
      (json['components'] as List?)?.whereType<String>() ??
          const <String>[],
    ).map((String component) => component.toLowerCase()).toList();

    final List<CatalogV2FeatureEffectDto> effects =
        <CatalogV2FeatureEffectDto>[];
    for (final dynamic entry in json['effects'] as List? ?? const <dynamic>[]) {
      if (entry is Map<String, dynamic>) {
        effects.add(
          CatalogV2FeatureEffectDto.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        );
      }
    }

    final List<CatalogV2PowerClassRefDto> classes =
        <CatalogV2PowerClassRefDto>[];
    for (final dynamic entry in json['classes'] as List? ?? const <dynamic>[]) {
      if (entry is Map<String, dynamic>) {
        classes.add(
          CatalogV2PowerClassRefDto.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        );
      }
    }

    return CatalogV2PowerDto(
      id: json['id'] as String? ?? '',
      slug: (json['slug'] as String? ?? '').toLowerCase(),
      name: LocalizedTextDto.fromAny(json['name']),
      level: (json['level'] as num?)?.toInt() ?? 0,
      castingTime: json['casting_time'] as String? ?? '',
      description: LocalizedTextDto.fromAny(json['description']),
      range: rawRange == null
          ? null
          : CatalogV2PowerRangeDto.fromJson(rawRange),
      duration: rawDuration == null
          ? null
          : CatalogV2PowerDurationDto.fromJson(rawDuration),
      components: List<String>.unmodifiable(components),
      effects: List<CatalogV2FeatureEffectDto>.unmodifiable(effects),
      classes: List<CatalogV2PowerClassRefDto>.unmodifiable(classes),
      alignment: (json['alignment'] as String?)?.toLowerCase(),
      school: (json['school'] as String?)?.toLowerCase(),
    );
  }

  final String id;
  final String slug;
  final LocalizedTextDto name;
  final int level;
  final String castingTime;
  final CatalogV2PowerRangeDto? range;
  final CatalogV2PowerDurationDto? duration;
  final List<String> components;
  final LocalizedTextDto description;
  final List<CatalogV2FeatureEffectDto> effects;
  final List<CatalogV2PowerClassRefDto> classes;
  final String? alignment;
  final String? school;
}

@immutable
class CatalogV2PowerRangeDto {
  const CatalogV2PowerRangeDto({
    required this.type,
    this.distanceMeters,
  });

  factory CatalogV2PowerRangeDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2PowerRangeDto(
      type: (json['type'] as String?)?.toLowerCase() ?? '',
      distanceMeters: (json['distance_m'] as num?)?.toDouble(),
    );
  }

  final String type;
  final double? distanceMeters;
}

@immutable
class CatalogV2PowerDurationDto {
  const CatalogV2PowerDurationDto({
    required this.unit,
    this.value,
    this.concentration = false,
  });

  factory CatalogV2PowerDurationDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2PowerDurationDto(
      unit: (json['unit'] as String?)?.toLowerCase() ?? '',
      value: (json['value'] as num?)?.toInt(),
      concentration: json['concentration'] as bool? ?? false,
    );
  }

  final String unit;
  final int? value;
  final bool concentration;
}

@immutable
class CatalogV2PowerClassRefDto {
  const CatalogV2PowerClassRefDto({
    required this.type,
    required this.id,
  });

  factory CatalogV2PowerClassRefDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2PowerClassRefDto(
      type: (json['type'] as String?)?.toLowerCase() ?? 'class',
      id: json['id'] as String? ?? '',
    );
  }

  final String type;
  final String id;
}

@immutable
class CatalogV2EquipmentGrantDto {
  const CatalogV2EquipmentGrantDto({
    required this.ref,
    this.quantity = 1,
  });

  factory CatalogV2EquipmentGrantDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> ref =
        Map<String, dynamic>.from(json['ref'] as Map? ?? const {});
    return CatalogV2EquipmentGrantDto(
      ref: CatalogV2EquipmentRefDto.fromJson(ref),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  final CatalogV2EquipmentRefDto ref;
  final int quantity;
}

@immutable
class CatalogV2EquipmentRefDto {
  const CatalogV2EquipmentRefDto({
    required this.type,
    required this.id,
  });

  factory CatalogV2EquipmentRefDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2EquipmentRefDto(
      type: (json['type'] as String?)?.toLowerCase() ?? '',
      id: json['id'] as String? ?? '',
    );
  }

  final String type;
  final String id;
}

@immutable
class CatalogV2BackgroundPersonalityDto {
  const CatalogV2BackgroundPersonalityDto({
    required this.traits,
    required this.ideals,
    required this.bonds,
    required this.flaws,
  });

  factory CatalogV2BackgroundPersonalityDto.fromJson(
      Map<String, dynamic> json) {
    return CatalogV2BackgroundPersonalityDto(
      traits: _parseLocalizedList(json['traits']),
      ideals: _parseLocalizedList(json['ideals']),
      bonds: _parseLocalizedList(json['bonds']),
      flaws: _parseLocalizedList(json['flaws']),
    );
  }

  final List<LocalizedTextDto> traits;
  final List<LocalizedTextDto> ideals;
  final List<LocalizedTextDto> bonds;
  final List<LocalizedTextDto> flaws;
}

@immutable
class CatalogV2FormulasDto {
  const CatalogV2FormulasDto({
    required this.rulesVersion,
    required this.hpLevel1,
    required this.defenseBase,
    required this.initiative,
    required this.superiorityDiceByClass,
    this.attackBonus,
    this.powerSaveDc,
  });

  factory CatalogV2FormulasDto.fromJson(Map<String, dynamic> json) {
    final Object? rawDiceJson = json['superiority_dice'];
    final Map<String, dynamic> rawDice = rawDiceJson is Map
        ? Map<String, dynamic>.from(rawDiceJson)
        : <String, dynamic>{};
    return CatalogV2FormulasDto(
      rulesVersion: json['rules_version'] as String,
      hpLevel1: json['hp_level1'] as String,
      defenseBase: json['defense_base'] as String,
      initiative: json['initiative'] as String,
      superiorityDiceByClass: rawDice.map(
        (String key, dynamic value) => MapEntry(
          key,
          CatalogV2SuperiorityDiceRuleDto.fromJson(
            value is Map
                ? Map<String, dynamic>.from(value)
                : <String, dynamic>{},
          ),
        ),
      ),
      attackBonus: json['attack_bonus'] as String?,
      powerSaveDc: json['power_save_dc'] as String?,
    );
  }

  final String rulesVersion;
  final String hpLevel1;
  final String defenseBase;
  final String initiative;
  final Map<String, CatalogV2SuperiorityDiceRuleDto> superiorityDiceByClass;
  final String? attackBonus;
  final String? powerSaveDc;
}

class CatalogV2SuperiorityDiceRuleDto {
  const CatalogV2SuperiorityDiceRuleDto({required this.count, this.die});

  factory CatalogV2SuperiorityDiceRuleDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2SuperiorityDiceRuleDto(
      count: (json['count'] as num?)?.toInt() ?? 0,
      die: (json['die'] as num?)?.toInt(),
    );
  }

  final int count;
  final int? die;
}

List<LocalizedTextDto> _parseLocalizedList(dynamic value) {
  if (value is! List) {
    return const <LocalizedTextDto>[];
  }
  return List<LocalizedTextDto>.unmodifiable(value.map((dynamic entry) {
    if (entry is Map<String, dynamic>) {
      return LocalizedTextDto.fromJson(Map<String, dynamic>.from(entry));
    }
    return LocalizedTextDto.fromAny(entry);
  }));
}
