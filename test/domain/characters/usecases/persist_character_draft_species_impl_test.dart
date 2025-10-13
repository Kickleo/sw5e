/// ---------------------------------------------------------------------------
/// Fichier test : persist_character_draft_species_impl_test.dart
/// Rôle : Vérifier l'enregistrement des informations d'espèce dans un brouillon.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/data/characters/repositories/in_memory_character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/localization/species_effect_localization.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_species_impl.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';
import 'package:test/test.dart';

void main() {
  setUp(SpeciesEffectLocalizationCatalog.resetToDefaults);

  test('enregistre les effets d\'une espèce Bith dans le brouillon', () async {
    final SpeciesDef species = _buildBithSpecies();
    final QuickCreateSpeciesDetails details = QuickCreateSpeciesDetails(
      species: species,
      traits: _buildBithTraits(),
    );

    final InMemoryCharacterDraftRepository repository =
        InMemoryCharacterDraftRepository();
    final PersistCharacterDraftSpeciesImpl useCase =
        PersistCharacterDraftSpeciesImpl(repository);

    final AppResult<CharacterDraft> result =
        await useCase(details, languageCode: 'en');
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

  test('formate les bonus de caractéristique avec choix multiples', () async {
    final SpeciesDef species = _buildHumanSpecies();

    final QuickCreateSpeciesDetails details = QuickCreateSpeciesDetails(
      species: species,
      traits: const <TraitDef>[],
    );

    final InMemoryCharacterDraftRepository repository =
        InMemoryCharacterDraftRepository();
    final PersistCharacterDraftSpeciesImpl useCase =
        PersistCharacterDraftSpeciesImpl(repository);

    final AppResult<CharacterDraft> result =
        await useCase(details, languageCode: 'en');
    expect(result.isOk, isTrue);

    final CharacterDraft? saved = await repository.load();
    final CharacterEffect abilityEffect = saved!.species!.effects.firstWhere(
      (CharacterEffect effect) => effect.source == 'species:human:ability_bonuses',
    );

    expect(
      abilityEffect.description,
      contains('+2 to Wisdom or Charisma (choose 1)'),
    );
    expect(
      abilityEffect.description,
      contains('+1 to any ability (choose 2)'),
    );
    expect(
      abilityEffect.description,
      contains('[Alternative] +1 to any ability (choose 4)'),
    );
  });

  test('localise les effets en français selon la langue fournie', () async {
    final SpeciesDef species = _buildTwilekSpecies();

    final QuickCreateSpeciesDetails details = QuickCreateSpeciesDetails(
      species: species,
      traits: _buildTwilekTraits(),
    );

    final InMemoryCharacterDraftRepository repository =
        InMemoryCharacterDraftRepository();
    final PersistCharacterDraftSpeciesImpl useCase =
        PersistCharacterDraftSpeciesImpl(repository);

    final AppResult<CharacterDraft> result =
        await useCase(details, languageCode: 'fr');
    expect(result.isOk, isTrue);

    final CharacterDraft saved = (await repository.load())!;

    expect(saved.species!.displayName, 'Twi\'lek');

    final CharacterEffect abilityEffect = saved.species!.effects.firstWhere(
      (CharacterEffect effect) =>
          effect.source == 'species:twilek:ability_bonuses',
    );
    expect(abilityEffect.title, 'Augmentation de caractéristiques');
    expect(abilityEffect.description, contains('+2 Force'));

    final CharacterEffect sizeEffect = saved.species!.effects.firstWhere(
      (CharacterEffect effect) => effect.source == 'species:twilek:size',
    );
    expect(sizeEffect.title, 'Taille');
    expect(sizeEffect.description, 'Votre taille est moyenne.');

    final CharacterEffect speedEffect = saved.species!.effects.firstWhere(
      (CharacterEffect effect) => effect.source == 'species:twilek:speed',
    );
    expect(speedEffect.title, 'Vitesse');
    expect(
      speedEffect.description,
      'Votre vitesse de déplacement de base est de 35 pieds.',
    );

    final CharacterEffect traitEffect = saved.species!.effects.firstWhere(
      (CharacterEffect effect) => effect.source == 'trait:agility',
    );
    expect(traitEffect.title, 'Agilité');
  });

  test('supporte l\'enregistrement d\'une nouvelle langue', () async {
    SpeciesEffectLocalizationCatalog.register(
      'es',
      const SpeciesEffectLanguageBundle(
        listSeparator: ', ',
        abilityScoreIncreaseTitle: 'Aumento de característica',
        ageTitle: 'Edad',
        alignmentTitle: 'Alineamiento',
        sizeTitle: 'Tamaño',
        speedTitle: 'Velocidad',
        languagesTitle: 'Idiomas',
        abilityChoiceDefaultOptions: 'características a tu elección',
        abilityChoicePreposition: 'a',
        abilityChoiceSuffixTemplate: '(elige {count})',
        alternativePrefix: '[Alternativa] ',
        abilityNames: <String, String>{
          'str': 'Fuerza',
          'dex': 'Destreza',
          'con': 'Constitución',
          'int': 'Inteligencia',
          'wis': 'Sabiduría',
          'cha': 'Carisma',
          'any': 'cualquier característica',
        },
        twoOptionSeparator: ' o ',
        finalOptionSeparator: ', o ',
        sizeLabels: <String, String>{
          'tiny': 'diminuto',
          'small': 'pequeño',
          'medium': 'mediano',
          'large': 'grande',
          'huge': 'enorme',
          'gargantuan': 'colosal',
        },
        sizeFallbackTemplate: 'Tu tamaño es {size}.',
        speedFallbackTemplate:
            'Tu velocidad base al caminar es de {speed} pies.',
        fallbackLanguageCode: 'en',
      ),
    );
    addTearDown(SpeciesEffectLocalizationCatalog.resetToDefaults);

    final SpeciesDef species = _buildBothanSpecies();

    final QuickCreateSpeciesDetails details = QuickCreateSpeciesDetails(
      species: species,
      traits: const <TraitDef>[],
    );

    final InMemoryCharacterDraftRepository repository =
        InMemoryCharacterDraftRepository();
    final PersistCharacterDraftSpeciesImpl useCase =
        PersistCharacterDraftSpeciesImpl(repository);

    final AppResult<CharacterDraft> result =
        await useCase(details, languageCode: 'es');
    expect(result.isOk, isTrue);

    final CharacterDraft saved = (await repository.load())!;
    expect(saved.species!.displayName, 'Bothaniano');

    final CharacterEffect abilityEffect = saved.species!.effects.firstWhere(
      (CharacterEffect effect) =>
          effect.source == 'species:bothan:ability_bonuses',
    );
    expect(abilityEffect.title, 'Aumento de característica');
    expect(abilityEffect.description, contains('+2 Carisma'));

    final CharacterEffect sizeEffect = saved.species!.effects.firstWhere(
      (CharacterEffect effect) => effect.source == 'species:bothan:size',
    );
    expect(sizeEffect.description, 'Tu tamaño es mediano.');

    final CharacterEffect speedEffect = saved.species!.effects.firstWhere(
      (CharacterEffect effect) => effect.source == 'species:bothan:speed',
    );
    expect(
      speedEffect.description,
      'Tu velocidad base al caminar es de 35 pies.',
    );

    final CharacterEffect languagesEffect = saved.species!.effects.firstWhere(
      (CharacterEffect effect) => effect.source == 'species:bothan:languages',
    );
    expect(languagesEffect.description, 'Puedes hablar Básico Galáctico.');
  });
}

SpeciesDef _buildBithSpecies() {
  return const SpeciesDef(
    id: 'bith',
    name: LocalizedText(en: 'Bith', fr: 'Bith'),
    speed: 30,
    size: 'medium',
    traitIds: const <String>['detail-oriented', 'sonic-sensitivity'],
    abilityBonuses: const <SpeciesAbilityBonus>[
      SpeciesAbilityBonus(ability: 'int', amount: 2),
      SpeciesAbilityBonus(ability: 'dex', amount: 1),
    ],
    age: LocalizedText(
      en: 'Bith reach adulthood in their late teens and live less than a century.',
      fr:
          "Les Bith atteignent l'âge adulte vers la fin de l'adolescence et vivent moins d'un siècle.",
    ),
    alignment: LocalizedText(
      en:
          "Biths' benevolent nature causes them to tend toward the light side, though there are exceptions.",
      fr:
          'La nature bienveillante des Bith les pousse vers le côté lumineux, bien qu\'il existe des exceptions.',
    ),
    sizeText: LocalizedText(
      en:
          'Bith typically stand 5 to 6 feet tall and generally weigh about 120 lbs. Regardless of your position in that range, your size is Medium.',
      fr:
          'Les Bith mesurent généralement entre 1,5 et 1,8 mètre et pèsent autour de 55 kilos. Quelle que soit votre position dans cette fourchette, votre taille est Moyenne.',
    ),
    speedText: LocalizedText(
      en: 'Your base walking speed is 30 feet.',
      fr: 'Votre vitesse de déplacement au sol de base est de 9 mètres.',
    ),
    languages: LocalizedText(
      en:
          'You can speak, read, and write Galactic Basic, Bith, and one more language of your choice.',
      fr:
          'Vous pouvez parler, lire et écrire le basique galactique, le bith et une autre langue de votre choix.',
    ),
  );
}

List<TraitDef> _buildBithTraits() {
  return const <TraitDef>[
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
  ];
}

SpeciesDef _buildHumanSpecies() {
  return const SpeciesDef(
    id: 'human',
    name: LocalizedText(en: 'Human', fr: 'Humain'),
    speed: 30,
    size: 'medium',
    abilityBonuses: const <SpeciesAbilityBonus>[
      SpeciesAbilityBonus(
        amount: 2,
        choose: 1,
        options: const <String>['wis', 'cha'],
      ),
      SpeciesAbilityBonus(
        amount: 1,
        choose: 2,
        options: const <String>['any'],
      ),
      SpeciesAbilityBonus(
        amount: 1,
        choose: 4,
        options: const <String>['any'],
        isAlternative: true,
      ),
    ],
  );
}

SpeciesDef _buildTwilekSpecies() {
  return const SpeciesDef(
    id: 'twilek',
    name: LocalizedText(en: 'Twi\'lek', fr: 'Twi\'lek'),
    speed: 35,
    size: 'medium',
    abilityBonuses: const <SpeciesAbilityBonus>[
      SpeciesAbilityBonus(ability: 'str', amount: 2),
    ],
    traitIds: const <String>['agility'],
  );
}

List<TraitDef> _buildTwilekTraits() {
  return const <TraitDef>[
    TraitDef(
      id: 'agility',
      name: LocalizedText(en: 'Agility', fr: 'Agilité'),
      description: 'Agile et vive.',
    ),
  ];
}

SpeciesDef _buildBothanSpecies() {
  return const SpeciesDef(
    id: 'bothan',
    name: LocalizedText(
      en: 'Bothan',
      fr: 'Bothan',
      otherTranslations: const <String, String>{'es': 'Bothaniano'},
    ),
    speed: 35,
    size: 'medium',
    abilityBonuses: const <SpeciesAbilityBonus>[
      SpeciesAbilityBonus(ability: 'cha', amount: 2),
    ],
    languages: LocalizedText(
      en: 'You can speak Galactic Basic.',
      fr: 'Vous pouvez parler le basique galactique.',
      otherTranslations: const <String, String>{
        'es': 'Puedes hablar Básico Galáctico.',
      },
    ),
  );
}
