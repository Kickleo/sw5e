/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/localization/species_effect_localization.dart
/// Rôle : Décrire les bundles de localisation utilisés pour formater les effets
///        d'espèce et fournir un registre configurable accessible par le domaine.
/// ---------------------------------------------------------------------------
library;

import 'package:meta/meta.dart';

@immutable
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

  static const Map<String, SpeciesEffectLanguageBundle> _builtInDefaults =
      <String, SpeciesEffectLanguageBundle>{
    'en': SpeciesEffectLanguageBundle(
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
    ),
    'fr': SpeciesEffectLanguageBundle(
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
      speedFallbackTemplate:
          'Votre vitesse de déplacement de base est de {speed} pieds.',
      fallbackLanguageCode: 'en',
    ),
  };

  static final Map<String, SpeciesEffectLanguageBundle> _bundles =
      Map<String, SpeciesEffectLanguageBundle>.from(_builtInDefaults);

  static Map<String, SpeciesEffectLanguageBundle> _configuredDefaults =
      Map<String, SpeciesEffectLanguageBundle>.from(_builtInDefaults);

  static String _fallbackLanguageCode = 'en';

  static void configure({
    required Map<String, SpeciesEffectLanguageBundle> bundles,
    String fallbackLanguageCode = 'en',
  }) {
    if (bundles.isEmpty) {
      throw ArgumentError('bundles must not be empty');
    }
    final Map<String, SpeciesEffectLanguageBundle> normalized =
        <String, SpeciesEffectLanguageBundle>{};
    bundles.forEach((String key, SpeciesEffectLanguageBundle value) {
      normalized[key.toLowerCase()] = value;
    });
    _bundles
      ..clear()
      ..addAll(normalized);
    _configuredDefaults =
        Map<String, SpeciesEffectLanguageBundle>.from(normalized);
    final String normalizedFallback = fallbackLanguageCode.toLowerCase();
    if (_bundles.containsKey(normalizedFallback)) {
      _fallbackLanguageCode = normalizedFallback;
    } else {
      _fallbackLanguageCode = _bundles.keys.first;
    }
  }

  static SpeciesEffectLanguageBundle forLanguage(String languageCode) {
    final String normalized = languageCode.toLowerCase();
    final SpeciesEffectLanguageBundle? direct = _bundles[normalized];
    if (direct != null) {
      return direct;
    }
    final SpeciesEffectLanguageBundle? fallback =
        _bundles[_fallbackLanguageCode];
    if (fallback != null) {
      return fallback;
    }
    return _bundles.values.first;
  }

  static void register(
    String languageCode,
    SpeciesEffectLanguageBundle bundle,
  ) {
    final String normalized = languageCode.toLowerCase();
    _bundles[normalized] = bundle;
  }

  static void unregister(String languageCode) {
    final String normalized = languageCode.toLowerCase();
    if (_bundles.length == 1 && _bundles.containsKey(normalized)) {
      // Toujours conserver au moins un bundle disponible.
      return;
    }
    _bundles.remove(normalized);
    if (_fallbackLanguageCode == normalized) {
      _fallbackLanguageCode = _bundles.keys.first;
    }
    final SpeciesEffectLanguageBundle? defaultBundle =
        _configuredDefaults[normalized] ?? _builtInDefaults[normalized];
    if (defaultBundle != null) {
      _bundles.putIfAbsent(normalized, () => defaultBundle);
    }
  }

  static void resetToDefaults() {
    configure(bundles: _builtInDefaults, fallbackLanguageCode: 'en');
  }

  static Map<String, SpeciesEffectLanguageBundle> snapshot() =>
      Map<String, SpeciesEffectLanguageBundle>.unmodifiable(_bundles);

  static String get fallbackLanguageCode => _fallbackLanguageCode;
}
