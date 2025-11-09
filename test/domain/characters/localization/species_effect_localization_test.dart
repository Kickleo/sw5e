/// ---------------------------------------------------------------------------
/// Fichier test : species_effect_localization_test.dart
/// Rôle : Vérifier la mise à jour dynamique des noms de caractéristiques dans
///        le catalogue de localisation des effets d'espèce.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/domain/characters/localization/species_effect_localization.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:test/test.dart';

void main() {
  setUp(SpeciesEffectLocalizationCatalog.resetToDefaults);

  test('met à jour les noms de caractéristiques pour chaque langue disponible',
      () {
    SpeciesEffectLocalizationCatalog.updateAbilityNames(<String, LocalizedText>{
      'str': const LocalizedText(en: 'Power', fr: 'Puissance'),
      'wis': const LocalizedText(en: 'Insight', fr: 'Perspicacité'),
    });

    final Map<String, SpeciesEffectLanguageBundle> bundles =
        SpeciesEffectLocalizationCatalog.snapshot();

    expect(bundles['en']!.abilityNames['str'], 'Power');
    expect(bundles['fr']!.abilityNames['str'], 'Puissance');
    expect(bundles['en']!.abilityNames['wis'], 'Insight');
    expect(bundles['fr']!.abilityNames['wis'], 'Perspicacité');
    // Préserve les entrées existantes comme le fallback "any".
    expect(bundles['en']!.abilityNames['any'], isNotEmpty);
  });
}
