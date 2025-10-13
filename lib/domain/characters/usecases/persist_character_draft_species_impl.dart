/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_species_impl.dart
/// Rôle : Implémenter l'enregistrement des informations d'espèce dans un
///        brouillon de personnage.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/localization/species_effect_localization.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_species.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';
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
