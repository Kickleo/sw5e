/// ---------------------------------------------------------------------------
/// Fichier : lib/data/catalog_v2/dtos/catalog_v2_dtos.dart
/// Rôle : Définir les DTOs propres au catalogue v2 (assets/catalog_v2).
/// Dépendances : LocalizedTextDto pour convertir les champs localisés.
/// Exemple :
///   final dto = CatalogV2SpeciesDto.fromJson(jsonMap);
/// ---------------------------------------------------------------------------
library;

import 'package:meta/meta.dart';
import 'package:sw5e_manager/data/catalog/dtos/catalog_dtos.dart';

@immutable
class CatalogV2AbilityDto {
  const CatalogV2AbilityDto({
    required this.id,
    required this.slug,
    required this.abbr,
  });

  factory CatalogV2AbilityDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2AbilityDto(
      id: json['id'] as String,
      slug: (json['slug'] as String).toLowerCase(),
      abbr: (json['abbr'] as String).toUpperCase(),
    );
  }

  final String id;
  final String slug;
  final String abbr;
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
  });

  factory CatalogV2LanguageDto.fromJson(Map<String, dynamic> json) {
    return CatalogV2LanguageDto(
      id: json['id'] as String,
      slug: (json['slug'] as String).toLowerCase(),
      name: LocalizedTextDto.fromAny(json['name']),
      description: LocalizedTextDto.maybeFromAny(json['description']),
    );
  }

  final String id;
  final String slug;
  final LocalizedTextDto name;
  final LocalizedTextDto? description;
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
