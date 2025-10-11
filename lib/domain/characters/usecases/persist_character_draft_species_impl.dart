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
      final CharacterDraft existing = await _drafts.load() ?? const CharacterDraft();
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
          .map((SpeciesAbilityBonus bonus) =>
              '${bonus.amount >= 0 ? '+' : ''}${bonus.amount} ${_abilityName(bonus.ability)}')
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
      default:
        return ability.toUpperCase();
    }
  }
}
