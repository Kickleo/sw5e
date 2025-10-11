/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_species_impl.dart
/// Rôle : Implémenter l'enregistrement des informations d'espèce dans un
///        brouillon de personnage.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_species.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';

class PersistCharacterDraftSpeciesImpl implements PersistCharacterDraftSpecies {
  const PersistCharacterDraftSpeciesImpl(this._drafts);

  final CharacterDraftRepository _drafts;

  @override
  Future<AppResult<CharacterDraft>> call(QuickCreateSpeciesDetails details) async {
    try {
      // On repart du brouillon sauvegardé pour conserver les autres champs.
      final CharacterDraft existing = await _drafts.load() ?? const CharacterDraft();
      // Les détails du catalogue sont transformés en une structure persistable.
      final DraftSpeciesSelection selection = _buildSpeciesSelection(details);
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

  DraftSpeciesSelection _buildSpeciesSelection(QuickCreateSpeciesDetails details) {
    final SpeciesDef species = details.species;
    final List<CharacterEffect> effects = <CharacterEffect>[];

    if (species.abilityBonuses.isNotEmpty) {
      final String bonuses = species.abilityBonuses
          .map(_formatAbilityBonus)
          .join(', ');
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:ability_bonuses',
          title: 'Ability Score Increase',
          description: bonuses,
          category: CharacterEffectCategory.passive,
        ),
      );
    }

    if (species.age != null && species.age!.trim().isNotEmpty) {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:age',
          title: 'Age',
          description: species.age!.trim(),
          category: CharacterEffectCategory.passive,
        ),
      );
    }

    if (species.alignment != null && species.alignment!.trim().isNotEmpty) {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:alignment',
          title: 'Alignment',
          description: species.alignment!.trim(),
          category: CharacterEffectCategory.passive,
        ),
      );
    }

    if (species.sizeText != null && species.sizeText!.trim().isNotEmpty) {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:size',
          title: 'Size',
          description: species.sizeText!.trim(),
          category: CharacterEffectCategory.passive,
        ),
      );
    } else {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:size',
          title: 'Size',
          description: 'Your size is ${species.size}.',
          category: CharacterEffectCategory.passive,
        ),
      );
    }

    final String speedDescription = (species.speedText != null &&
            species.speedText!.trim().isNotEmpty)
        ? species.speedText!.trim()
        : 'Your base walking speed is ${species.speed} feet.';
    effects.add(
      CharacterEffect(
        source: 'species:${species.id}:speed',
        title: 'Speed',
        description: speedDescription,
        category: CharacterEffectCategory.passive,
      ),
    );

    if (species.languages != null && species.languages!.trim().isNotEmpty) {
      effects.add(
        CharacterEffect(
          source: 'species:${species.id}:languages',
          title: 'Languages',
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
          title: trait.name.en.isNotEmpty ? trait.name.en : trait.name.fr,
          description: trait.description,
          category: category,
        ),
      );
    }

    return DraftSpeciesSelection(
      speciesId: SpeciesId(species.id),
      displayName: species.name.en.isNotEmpty ? species.name.en : species.name.fr,
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

  String _formatAbilityBonus(SpeciesAbilityBonus bonus) {
    final String sign = bonus.amount >= 0 ? '+' : '';
    final String amount = '$sign${bonus.amount}';
    final String alternativePrefix = bonus.isAlternative ? '[Alternative] ' : '';

    if (bonus.isChoice) {
      final int choose = bonus.choose ?? 1;
      final String options = _formatAbilityOptions(bonus.options);
      return '$alternativePrefix$amount to $options (choose $choose)';
    }

    final String ability = _abilityName(bonus.ability ?? 'any');
    return '$alternativePrefix$amount $ability';
  }

  String _formatAbilityOptions(List<String> options) {
    if (options.isEmpty) {
      return 'abilities of your choice';
    }

    final List<String> labels =
        options.map((String option) => _abilityName(option)).toList();

    if (labels.length == 1) {
      return labels.first;
    }

    if (labels.length == 2) {
      return '${labels[0]} or ${labels[1]}';
    }

    return '${labels.sublist(0, labels.length - 1).join(', ')}, or ${labels.last}';
  }

  String _abilityName(String ability) {
    switch (ability.toLowerCase()) {
      case 'str':
        return 'Strength';
      case 'dex':
        return 'Dexterity';
      case 'con':
        return 'Constitution';
      case 'int':
        return 'Intelligence';
      case 'wis':
        return 'Wisdom';
      case 'cha':
        return 'Charisma';
      case 'any':
        return 'any ability';
      default:
        return ability.toUpperCase();
    }
  }
}
