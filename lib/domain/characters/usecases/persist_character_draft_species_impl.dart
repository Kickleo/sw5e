/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_species_impl.dart
/// Rôle : Implémenter l'enregistrement des informations d'espèce dans un
///        brouillon de personnage.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_species.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';

class PersistCharacterDraftSpeciesImpl implements PersistCharacterDraftSpecies {
  const PersistCharacterDraftSpeciesImpl(this._drafts);

  final CharacterDraftRepository _drafts;

  @override
  Future<AppResult<CharacterDraft>> call(
    QuickCreateSpeciesDetails details, {
    required String languageCode,
  }) async {
    try {
      // On repart du brouillon sauvegardé pour conserver les autres champs.
      final CharacterDraft existing = await _drafts.load() ?? CharacterDraft();
      // Les détails du catalogue sont transformés en une structure persistable.
      final DraftSpeciesSelection selection =
          _buildSpeciesSelection(details, languageCode);
      final CharacterDraft updated = existing.copyWith(species: selection);
      await _drafts.save(updated);
      return appOk(updated);
    } catch (error) {
      return appErr(
        DomainError(
          'DraftPersistenceFailed',
          message: error.toString(),
          details: {'speciesId': details.species.id},
        ),
      );
    }
  }

  DraftSpeciesSelection _buildSpeciesSelection(
    QuickCreateSpeciesDetails details,
    String languageCode,
  ) {
    final SpeciesDef species = details.species;
    final List<CharacterEffect> effects = <CharacterEffect>[];
    final _SpeciesEffectLocalizer l10n =
        _SpeciesEffectLocalizer(languageCode: languageCode);

    if (species.abilityBonuses.isNotEmpty) {
      final String bonuses = species.abilityBonuses
          .map(l10n.formatAbilityBonus)
          .join(l10n.listSeparator);
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:ability_bonuses',
          title: l10n.abilityScoreIncreaseTitle,
          description: bonuses,
          category: CharacterEffectCategory.passive,
        ),
      );
    }

    final String? ageDescription = l10n.maybeLocalized(species.age);
    if (ageDescription != null) {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:age',
          title: l10n.ageTitle,
          description: ageDescription,
          category: CharacterEffectCategory.passive,
        ),
      );
    }

    final String? alignmentDescription = l10n.maybeLocalized(species.alignment);
    if (alignmentDescription != null) {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:alignment',
          title: l10n.alignmentTitle,
          description: alignmentDescription,
          category: CharacterEffectCategory.passive,
        ),
      );
    }

    final String? sizeDescription = l10n.maybeLocalized(species.sizeText);
    if (sizeDescription != null) {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:size',
          title: l10n.sizeTitle,
          description: sizeDescription,
          category: CharacterEffectCategory.passive,
        ),
      );
    } else {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:size',
          title: l10n.sizeTitle,
          description: l10n.sizeFallback(species.size),
          category: CharacterEffectCategory.passive,
        ),
      );
    }

    final String speedDescription =
        l10n.maybeLocalized(species.speedText) ?? l10n.speedFallback(species.speed);
    effects.add(
      CharacterEffect(
        source: 'species:${species.id}:speed',
        title: l10n.speedTitle,
        description: speedDescription,
        category: CharacterEffectCategory.passive,
      ),
    );

    final String? languagesDescription = l10n.maybeLocalized(species.languages);
    if (languagesDescription != null) {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:languages',
          title: l10n.languagesTitle,
          description: languagesDescription,
          category: CharacterEffectCategory.passive,
        ),
      );
    }

    for (final TraitDef trait in details.traits) {
      final CharacterEffectCategory category = _inferCategory(trait.description);
      effects.add(
        CharacterEffect(
          source: 'trait:${trait.id}',
          title: l10n.localizedLabel(trait.name),
          description: trait.description,
          category: category,
        ),
      );
    }

    return DraftSpeciesSelection(
      speciesId: SpeciesId(species.id),
      displayName: l10n.localizedLabel(species.name),
      effects: List<CharacterEffect>.unmodifiable(effects),
    );
  }

  CharacterEffectCategory _inferCategory(String description) {
    final String normalized = description.toLowerCase();
    if (normalized.contains('bonus action')) {
      return CharacterEffectCategory.bonusAction;
    }
    if (normalized.contains('as an action') ||
        normalized.contains('use your action')) {
      return CharacterEffectCategory.action;
    }
    return CharacterEffectCategory.passive;
  }

}

class SpeciesEffectLanguageBundle {
  const SpeciesEffectLanguageBundle({
    required this.listSeparator,
    required this.abilityScoreIncreaseTitle,
    required this.ageTitle,
    required this.alignmentTitle,
    required this.sizeTitle,
    required this.speedTitle,
    required this.languagesTitle,
    required this.abilityChoiceDefaultOptions,
    required this.abilityChoicePreposition,
    required this.abilityChoiceSuffixTemplate,
    required this.alternativePrefix,
    required this.abilityNames,
    required this.twoOptionSeparator,
    required this.finalOptionSeparator,
    required this.sizeLabels,
    required this.sizeFallbackTemplate,
    required this.speedFallbackTemplate,
    this.fallbackLanguageCode = 'en',
  });

  final String listSeparator;
  final String abilityScoreIncreaseTitle;
  final String ageTitle;
  final String alignmentTitle;
  final String sizeTitle;
  final String speedTitle;
  final String languagesTitle;
  final String abilityChoiceDefaultOptions;
  final String abilityChoicePreposition;
  final String abilityChoiceSuffixTemplate;
  final String alternativePrefix;
  final Map<String, String> abilityNames;
  final String twoOptionSeparator;
  final String finalOptionSeparator;
  final Map<String, String> sizeLabels;
  final String sizeFallbackTemplate;
  final String speedFallbackTemplate;
  final String fallbackLanguageCode;

  String abilityName(String ability) {
    final String normalized = ability.toLowerCase();
    final String? direct = abilityNames[normalized];
    if (direct != null && direct.trim().isNotEmpty) {
      return direct;
    }
    if (normalized != 'any') {
      final String? fallbackAny = abilityNames['any'];
      if (fallbackAny != null && fallbackAny.trim().isNotEmpty) {
        return fallbackAny;
      }
    } else {
      final String? fallbackAny = abilityNames['any'];
      if (fallbackAny != null && fallbackAny.trim().isNotEmpty) {
        return fallbackAny;
      }
    }
    return ability.toUpperCase();
  }

  String abilityChoiceSuffix(int choose) =>
      abilityChoiceSuffixTemplate.replaceAll('{count}', '$choose');

  String sizeLabel(String size) {
    final String normalized = size.toLowerCase();
    return sizeLabels[normalized] ?? size;
  }

  String sizeFallback(String size) =>
      sizeFallbackTemplate.replaceAll('{size}', sizeLabel(size));

  String speedFallback(int speed) =>
      speedFallbackTemplate.replaceAll('{speed}', '$speed');
}

class SpeciesEffectLocalizationCatalog {
  SpeciesEffectLocalizationCatalog._();

  static const Map<String, SpeciesEffectLanguageBundle> _defaults =
      <String, SpeciesEffectLanguageBundle>{
    'en': _englishSpeciesBundle,
    'fr': _frenchSpeciesBundle,
  };

  static final Map<String, SpeciesEffectLanguageBundle> _bundles =
      Map<String, SpeciesEffectLanguageBundle>.from(_defaults);

  static SpeciesEffectLanguageBundle forLanguage(String languageCode) {
    final String normalized = languageCode.toLowerCase();
    return _bundles[normalized] ?? _bundles['en']!;
  }

  static void register(String languageCode, SpeciesEffectLanguageBundle bundle) {
    _bundles[languageCode.toLowerCase()] = bundle;
  }

  static void unregister(String languageCode) {
    final String normalized = languageCode.toLowerCase();
    if (_defaults.containsKey(normalized)) {
      _bundles[normalized] = _defaults[normalized]!;
    } else {
      _bundles.remove(normalized);
    }
  }

  static void resetToDefaults() {
    _bundles
      ..clear()
      ..addAll(_defaults);
  }
}

const SpeciesEffectLanguageBundle _englishSpeciesBundle =
    SpeciesEffectLanguageBundle(
  listSeparator: ', ',
  abilityScoreIncreaseTitle: 'Ability Score Increase',
  ageTitle: 'Age',
  alignmentTitle: 'Alignment',
  sizeTitle: 'Size',
  speedTitle: 'Speed',
  languagesTitle: 'Languages',
  abilityChoiceDefaultOptions: 'abilities of your choice',
  abilityChoicePreposition: 'to',
  abilityChoiceSuffixTemplate: '(choose {count})',
  alternativePrefix: '[Alternative] ',
  abilityNames: <String, String>{
    'str': 'Strength',
    'dex': 'Dexterity',
    'con': 'Constitution',
    'int': 'Intelligence',
    'wis': 'Wisdom',
    'cha': 'Charisma',
    'any': 'any ability',
  },
  twoOptionSeparator: ' or ',
  finalOptionSeparator: ', or ',
  sizeLabels: <String, String>{
    'tiny': 'Tiny',
    'small': 'Small',
    'medium': 'Medium',
    'large': 'Large',
    'huge': 'Huge',
    'gargantuan': 'Gargantuan',
  },
  sizeFallbackTemplate: 'Your size is {size}.',
  speedFallbackTemplate: 'Your base walking speed is {speed} feet.',
  fallbackLanguageCode: 'en',
);

const SpeciesEffectLanguageBundle _frenchSpeciesBundle =
    SpeciesEffectLanguageBundle(
  listSeparator: ', ',
  abilityScoreIncreaseTitle: 'Augmentation de caractéristiques',
  ageTitle: 'Âge',
  alignmentTitle: 'Alignement',
  sizeTitle: 'Taille',
  speedTitle: 'Vitesse',
  languagesTitle: 'Langues',
  abilityChoiceDefaultOptions: 'caractéristiques de votre choix',
  abilityChoicePreposition: 'pour',
  abilityChoiceSuffixTemplate: '({count} au choix)',
  alternativePrefix: '[Variante] ',
  abilityNames: <String, String>{
    'str': 'Force',
    'dex': 'Dextérité',
    'con': 'Constitution',
    'int': 'Intelligence',
    'wis': 'Sagesse',
    'cha': 'Charisme',
    'any': "n'importe quelle caractéristique",
  },
  twoOptionSeparator: ' ou ',
  finalOptionSeparator: ', ou ',
  sizeLabels: <String, String>{
    'tiny': 'minuscule',
    'small': 'petite',
    'medium': 'moyenne',
    'large': 'grande',
    'huge': 'très grande',
    'gargantuan': 'gargantuesque',
  },
  sizeFallbackTemplate: 'Votre taille est {size}.',
  speedFallbackTemplate: 'Votre vitesse de déplacement de base est de {speed} pieds.',
  fallbackLanguageCode: 'en',
);

class _SpeciesEffectLocalizer {
  _SpeciesEffectLocalizer({required this.languageCode})
      : bundle =
            SpeciesEffectLocalizationCatalog.forLanguage(languageCode);

  final String languageCode;
  final SpeciesEffectLanguageBundle bundle;

  String get listSeparator => bundle.listSeparator;
  String get abilityScoreIncreaseTitle => bundle.abilityScoreIncreaseTitle;
  String get ageTitle => bundle.ageTitle;
  String get alignmentTitle => bundle.alignmentTitle;
  String get sizeTitle => bundle.sizeTitle;
  String get speedTitle => bundle.speedTitle;
  String get languagesTitle => bundle.languagesTitle;

  String localizedLabel(LocalizedText text) => text.resolve(
        languageCode,
        fallbackLanguageCode: bundle.fallbackLanguageCode,
      );

  String? maybeLocalized(LocalizedText? text) {
    if (text == null) {
      return null;
    }
    final String? resolved = text.maybeResolve(
      languageCode,
      fallbackLanguageCode: bundle.fallbackLanguageCode,
    );
    if (resolved == null) {
      return null;
    }
    final String trimmed = resolved.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String formatAbilityBonus(SpeciesAbilityBonus bonus) {
    final String sign = bonus.amount >= 0 ? '+' : '';
    final String amount = '$sign${bonus.amount}';
    final String alternativePrefix =
        bonus.isAlternative ? bundle.alternativePrefix : '';

    if (bonus.isChoice) {
      final int choose = bonus.choose ?? 1;
      final String options = _formatAbilityOptions(bonus.options);
      final String chooseSuffix = bundle.abilityChoiceSuffix(choose);
      final String preposition = bundle.abilityChoicePreposition;
      final String formatted =
          '$alternativePrefix$amount $preposition $options $chooseSuffix';
      return formatted.trim();
    }

    final String ability = bundle.abilityName(bonus.ability ?? 'any');
    return ('$alternativePrefix$amount $ability').trim();
  }

  String speedFallback(int speed) => bundle.speedFallback(speed);

  String sizeFallback(String size) => bundle.sizeFallback(size);

  String _formatAbilityOptions(List<String> options) {
    if (options.isEmpty) {
      return bundle.abilityChoiceDefaultOptions;
    }

    final List<String> labels =
        options.map((String option) => bundle.abilityName(option)).toList();
    if (labels.length == 1) {
      return labels.first;
    }
    if (labels.length == 2) {
      return '${labels[0]}${bundle.twoOptionSeparator}${labels[1]}';
    }

    final String penultimate =
        labels.sublist(0, labels.length - 1).join(bundle.listSeparator);
    return '$penultimate${bundle.finalOptionSeparator}${labels.last}';
  }
}
