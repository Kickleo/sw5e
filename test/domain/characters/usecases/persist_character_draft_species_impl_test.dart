/// ---------------------------------------------------------------------------
/// Fichier test : persist_character_draft_species_impl_test.dart
/// Rôle : Vérifier l'enregistrement des informations d'espèce dans un brouillon.
/// ---------------------------------------------------------------------------
library;

import 'package:test/test.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/data/characters/repositories/in_memory_character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_species_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';

void main() {
  test('enregistre les effets d\'une espèce Bith dans le brouillon', () async {
    const SpeciesDef species = SpeciesDef(
      id: 'bith',
      name: LocalizedText(en: 'Bith', fr: 'Bith'),
      speed: 30,
      size: 'medium',
      traitIds: <String>['detail-oriented', 'sonic-sensitivity'],
      abilityBonuses: <SpeciesAbilityBonus>[
        SpeciesAbilityBonus(ability: 'int', amount: 2),
        SpeciesAbilityBonus(ability: 'dex', amount: 1),
      ],
      age: 'Bith reach adulthood in their late teens and live less than a century.',
      alignment:
          'Biths\' benevolent nature causes them to tend toward the light side, though there are exceptions.',
      sizeText:
          'Bith typically stand 5 to 6 feet tall and generally weigh about 120 lbs. Regardless of your position in that range, your size is Medium.',
      speedText: 'Your base walking speed is 30 feet.',
      languages:
          'You can speak, read, and write Galactic Basic, Bith, and one more language of your choice.',
    );

    const QuickCreateSpeciesDetails details = QuickCreateSpeciesDetails(
      species: species,
      traits: <TraitDef>[
        TraitDef(
          id: 'detail-oriented',
          name: LocalizedText(en: 'Detail Oriented', fr: 'Detail Oriented'),
          description:
              'You are practiced at scouring for details. You have advantage on Intelligence (Investigation) checks within 5 feet.',
        ),
        TraitDef(
          id: 'sonic-sensitivity',
          name: LocalizedText(en: 'Sonic Sensitivity', fr: 'Sonic Sensitivity'),
          description:
              'You have disadvantage on saving throws against effects that would deal sonic damage (explained in chapter 9).',
        ),
      ],
    );

    final InMemoryCharacterDraftRepository repository =
        InMemoryCharacterDraftRepository();
    final PersistCharacterDraftSpeciesImpl useCase =
        PersistCharacterDraftSpeciesImpl(repository);

    final AppResult<CharacterDraft> result = await useCase(details);
    expect(result.isOk, isTrue);

    final CharacterDraft? saved = await repository.load();
    expect(saved, isNotNull);
    expect(saved!.species, isNotNull);
    expect(saved.species!.speciesId.value, 'bith');

    final List<CharacterEffect> effects = saved.species!.effects;
    expect(effects, isNotEmpty);

    final CharacterEffect abilityEffect =
        effects.firstWhere((effect) => effect.source == 'species:bith:ability_bonuses');
    expect(abilityEffect.description, contains('+2 Intelligence'));
    expect(abilityEffect.description, contains('+1 Dexterity'));
    expect(abilityEffect.category, CharacterEffectCategory.passive);

    final CharacterEffect sonicSensitivity =
        effects.firstWhere((effect) => effect.source == 'trait:sonic-sensitivity');
    expect(sonicSensitivity.category, CharacterEffectCategory.passive);
    expect(sonicSensitivity.description, contains('sonic damage'));
  });
}
