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

    if (species.age != null && species.age!.trim().isNotEmpty) {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:age',
          title: l10n.ageTitle,
          description: species.age!.trim(),
          category: CharacterEffectCategory.passive,
        ),
      );
    }

    if (species.alignment != null && species.alignment!.trim().isNotEmpty) {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:alignment',
          title: l10n.alignmentTitle,
          description: species.alignment!.trim(),
          category: CharacterEffectCategory.passive,
        ),
      );
    }

    if (species.sizeText != null && species.sizeText!.trim().isNotEmpty) {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:size',
          title: l10n.sizeTitle,
          description: species.sizeText!.trim(),
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

    final String speedDescription = (species.speedText != null &&
            species.speedText!.trim().isNotEmpty)
        ? species.speedText!.trim()
        : l10n.speedFallback(species.speed);
    effects.add(
      CharacterEffect(
        source: 'species:${species.id}:speed',
        title: l10n.speedTitle,
        description: speedDescription,
        category: CharacterEffectCategory.passive,
      ),
    );

    if (species.languages != null && species.languages!.trim().isNotEmpty) {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:languages',
          title: l10n.languagesTitle,
          description: species.languages!.trim(),
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
  const _SpeciesEffectLocalizer({required this.languageCode});

  final String languageCode;

  bool get _isFrench => languageCode.toLowerCase() == 'fr';

  String get listSeparator => ', ';

  String get abilityScoreIncreaseTitle =>
      _isFrench ? 'Augmentation de caractéristiques' : 'Ability Score Increase';

  String get ageTitle => _isFrench ? 'Âge' : 'Age';

  String get alignmentTitle => _isFrench ? 'Alignement' : 'Alignment';

  String get sizeTitle => _isFrench ? 'Taille' : 'Size';

  String get speedTitle => _isFrench ? 'Vitesse' : 'Speed';

  String get languagesTitle => _isFrench ? 'Langues' : 'Languages';

  String localizedLabel(LocalizedText text) {
    if (_isFrench) {
      return text.fr.isNotEmpty ? text.fr : text.en;
    }
    return text.en.isNotEmpty ? text.en : text.fr;
  }

  String formatAbilityBonus(SpeciesAbilityBonus bonus) {
    final String sign = bonus.amount >= 0 ? '+' : '';
    final String amount = '$sign${bonus.amount}';
    final String alternativePrefix =
        bonus.isAlternative ? (_isFrench ? '[Variante] ' : '[Alternative] ') : '';

    if (bonus.isChoice) {
      final int choose = bonus.choose ?? 1;
      final String options = _formatAbilityOptions(bonus.options);
      final String chooseSuffix =
          _isFrench ? '($choose au choix)' : '(choose $choose)';
      final String preposition =
          _isFrench ? 'pour' : 'to';
      return '$alternativePrefix$amount $preposition $options $chooseSuffix';
    }

    final String ability = _abilityName(bonus.ability ?? 'any');
    return '$alternativePrefix$amount $ability';
  }

  String speedFallback(int speed) => _isFrench
      ? 'Votre vitesse de déplacement de base est de $speed pieds.'
      : 'Your base walking speed is $speed feet.';

  String sizeFallback(String size) {
    final String localized = _isFrench ? _localizedSizeFr(size) : _localizedSizeEn(size);
    return _isFrench
        ? 'Votre taille est $localized.'
        : 'Your size is $localized.';
  }

  String _formatAbilityOptions(List<String> options) {
    if (options.isEmpty) {
      return _isFrench ? 'caractéristiques de votre choix' : 'abilities of your choice';
    }

    final List<String> labels =
        options.map((String option) => _abilityName(option)).toList();

    if (labels.length == 1) {
      return labels.first;
    }

    if (labels.length == 2) {
      final String separator = _isFrench ? ' ou ' : ' or ';
      return '${labels[0]}$separator${labels[1]}';
    }

    final String penultimate =
        labels.sublist(0, labels.length - 1).join(', ');
    final String conjunction = _isFrench ? ', ou ' : ', or ';
    return '$penultimate$conjunction${labels.last}';
  }

  String _abilityName(String ability) {
    switch (ability.toLowerCase()) {
      case 'str':
        return _isFrench ? 'Force' : 'Strength';
      case 'dex':
        return _isFrench ? 'Dextérité' : 'Dexterity';
      case 'con':
        return _isFrench ? 'Constitution' : 'Constitution';
      case 'int':
        return _isFrench ? 'Intelligence' : 'Intelligence';
      case 'wis':
        return _isFrench ? 'Sagesse' : 'Wisdom';
      case 'cha':
        return _isFrench ? 'Charisme' : 'Charisma';
      case 'any':
        return _isFrench
            ? "n'importe quelle caractéristique"
            : 'any ability';
      default:
        return ability.toUpperCase();
    }
  }

  String _localizedSizeFr(String size) {
    switch (size.toLowerCase()) {
      case 'tiny':
        return 'minuscule';
      case 'small':
        return 'petite';
      case 'medium':
        return 'moyenne';
      case 'large':
        return 'grande';
      case 'huge':
        return 'très grande';
      case 'gargantuan':
        return 'gargantuesque';
      default:
        return size;
    }
  }

  String _localizedSizeEn(String size) {
    switch (size.toLowerCase()) {
      case 'tiny':
        return 'Tiny';
      case 'small':
        return 'Small';
      case 'medium':
        return 'Medium';
      case 'large':
        return 'Large';
      case 'huge':
        return 'Huge';
      case 'gargantuan':
        return 'Gargantuan';
      default:
        return size;
    }
  }
}
