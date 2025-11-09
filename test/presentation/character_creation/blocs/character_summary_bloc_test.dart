/// ---------------------------------------------------------------------------
/// Fichier test : character_summary_bloc_test.dart
/// Rôle : Vérifier le comportement du CharacterSummaryBloc (chargement,
///        sélection, partage).
/// ---------------------------------------------------------------------------
library;
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/domain/characters/value_objects/background_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_name.dart';
import 'package:sw5e_manager/domain/characters/value_objects/class_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/credits.dart';
import 'package:sw5e_manager/domain/characters/value_objects/defense.dart';
import 'package:sw5e_manager/domain/characters/value_objects/encumbrance.dart';
import 'package:sw5e_manager/domain/characters/value_objects/hit_points.dart';
import 'package:sw5e_manager/domain/characters/value_objects/initiative.dart';
import 'package:sw5e_manager/domain/characters/value_objects/level.dart';
import 'package:sw5e_manager/domain/characters/value_objects/maneuvers_known.dart';
import 'package:sw5e_manager/domain/characters/value_objects/proficiency_bonus.dart';
import 'package:sw5e_manager/domain/characters/value_objects/skill_proficiency.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/superiority_dice.dart';
import 'package:sw5e_manager/presentation/character_creation/blocs/character_summary_bloc.dart';

class _MockListSavedCharacters extends Mock implements ListSavedCharacters {}

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _FakeLogger implements AppLogger {
  @override
  void error(String message, {Object? payload, Object? error, StackTrace? stackTrace}) {}

  @override
  void info(String message, {Object? payload}) {}

  @override
  void warn(String message, {Object? payload, Object? error, StackTrace? stackTrace}) {}
}

Character _dummyCharacter(String id) {
  return Character(
    id: CharacterId(id),
    name: CharacterName('Dummy $id'),
    speciesId: SpeciesId('human'),
    classId: ClassId('guardian'),
    backgroundId: BackgroundId('outlaw'),
    level: Level.one,
    abilities: <String, AbilityScore>{
      'str': AbilityScore(10),
      'dex': AbilityScore(10),
      'con': AbilityScore(10),
      'int': AbilityScore(10),
      'wis': AbilityScore(10),
      'cha': AbilityScore(10),
    },
    skills: const <SkillProficiency>{},
    proficiencyBonus: ProficiencyBonus.fromLevel(Level.one),
    hitPoints: HitPoints(10),
    defense: Defense(10),
    initiative: Initiative(0),
    credits: Credits(0),
    inventory: const <InventoryLine>[],
    encumbrance: Encumbrance(0),
    maneuversKnown: ManeuversKnown(0),
    superiorityDice: SuperiorityDice(count: 0, die: null),
  );
}

void main() {
  late _MockListSavedCharacters mockUseCase;
  late _MockCatalogRepository mockCatalog;
  late AppLogger logger;

  setUp(() {
    mockUseCase = _MockListSavedCharacters();
    mockCatalog = _MockCatalogRepository();
    logger = _FakeLogger();

    when(() => mockCatalog.getSpecies(any())).thenAnswer((invocation) async {
      final String id = invocation.positionalArguments.first as String;
      return SpeciesDef(
        id: id,
        name: LocalizedText(en: id, fr: id),
        speed: 30,
        size: 'medium',
        languageIds: const <String>['galactic-basic'],
        languages: const LocalizedText(en: 'Basic', fr: 'Basique'),
      );
    });

    when(() => mockCatalog.getLanguage('galactic-basic')).thenAnswer(
      (_) async => const LanguageDef(
        id: 'galactic-basic',
        name: LocalizedText(en: 'Galactic Basic', fr: 'Basic galactique'),
        description: null,
      ),
    );

    when(() => mockCatalog.getClass(any())).thenAnswer((invocation) async {
      final String id = invocation.positionalArguments.first as String;
      return ClassDef(
        id: id,
        name: LocalizedText(en: id, fr: id),
        hitDie: 8,
        level1: ClassLevel1Data(
          proficiencies: ClassLevel1Proficiencies(
            skillsChoose: 0,
            skillsFrom: <String>[],
          ),
          startingEquipment: const <StartingEquipmentLine>[],
        ),
      );
    });

    when(() => mockCatalog.getBackground(any())).thenAnswer((invocation) async {
      final String id = invocation.positionalArguments.first as String;
      return BackgroundDef(
        id: id,
        name: LocalizedText(en: id, fr: id),
        grantedSkills: const <String>[],
      );
    });

    when(() => mockCatalog.getAbility(any())).thenAnswer((invocation) async {
      final String id = invocation.positionalArguments.first as String;
      return AbilityDef(
        id: id,
        abbreviation: id.toUpperCase(),
        name: LocalizedText(en: id, fr: id),
      );
    });
  });

  test('état initial = CharacterSummaryState.initial()', () {
    final bloc = CharacterSummaryBloc(
      listSavedCharacters: mockUseCase,
      catalog: mockCatalog,
      logger: logger,
    );
    expect(bloc.state, CharacterSummaryState.initial());
    bloc.close();
  });

  blocTest<CharacterSummaryBloc, CharacterSummaryState>(
    'charge les personnages et sélectionne le dernier',
    build: () {
      when(() => mockUseCase()).thenAnswer(
        (_) async => appOk(<Character>[
          _dummyCharacter('c1'),
          _dummyCharacter('c2'),
        ]),
      );
      return CharacterSummaryBloc(
        listSavedCharacters: mockUseCase,
        catalog: mockCatalog,
        logger: logger,
      );
    },
    act: (bloc) => bloc.add(const CharacterSummaryStarted()),
    expect: () => <Matcher>[
      isA<CharacterSummaryState>()
          .having((state) => state.isLoading, 'isLoading', true),
      isA<CharacterSummaryState>()
          .having((state) => state.isLoading, 'isLoading', false)
          .having((state) => state.characters, 'characters', hasLength(2))
          .having((state) => state.selectedId?.value, 'selectedId', 'c2')
          .having((state) => state.hasLoadedOnce, 'hasLoadedOnce', true)
          .having((state) => state.failure, 'failure', isNull)
          .having(
            (state) => state.speciesDefinitions.containsKey('human'),
            'species definition resolved',
            true,
          )
          .having(
            (state) => state.speciesNames.containsKey('human'),
            'species label resolved',
            true,
          )
          .having(
            (state) => state.classNames.containsKey('guardian'),
            'class label resolved',
            true,
          )
          .having(
            (state) => state.backgroundNames.containsKey('outlaw'),
            'background label resolved',
            true,
          )
          .having(
            (state) => state.languageDefinitions.containsKey('galactic-basic'),
            'language definition resolved',
            true,
          )
          .having(
            (state) => state.abilityDefinitions.containsKey('str'),
            'ability definition resolved',
            true,
          ),
    ],
    verify: (_) => verify(() => mockUseCase()).called(1),
  );

  blocTest<CharacterSummaryBloc, CharacterSummaryState>(
    'publie une erreur formatée lorsque le use case échoue',
    build: () {
      when(() => mockUseCase()).thenAnswer(
        (_) async => appErr<List<Character>>(
          const DomainError('Unexpected', message: 'boom'),
        ),
      );
      return CharacterSummaryBloc(
        listSavedCharacters: mockUseCase,
        catalog: mockCatalog,
        logger: logger,
      );
    },
    act: (bloc) => bloc.add(const CharacterSummaryStarted()),
    expect: () => <Matcher>[
      isA<CharacterSummaryState>()
          .having((state) => state.isLoading, 'isLoading', true),
      isA<CharacterSummaryState>()
          .having((state) => state.isLoading, 'isLoading', false)
          .having((state) => state.failure?.code, 'failureCode', 'Unexpected')
          .having((state) => state.errorMessage, 'errorMessage', 'Unexpected — boom')
          .having((state) => state.hasLoadedOnce, 'hasLoadedOnce', true),
    ],
    verify: (_) => verify(() => mockUseCase()).called(1),
  );

  blocTest<CharacterSummaryBloc, CharacterSummaryState>(
    'met à jour la sélection sur CharacterSummaryCharacterSelected',
    build: () => CharacterSummaryBloc(
      listSavedCharacters: mockUseCase,
      catalog: mockCatalog,
      logger: logger,
    ),
    seed: () {
      final Character c1 = _dummyCharacter('c1');
      final Character c2 = _dummyCharacter('c2');
      return CharacterSummaryState.initial().copyWith(
        characters: <Character>[c1, c2],
        selectedId: c2.id,
        hasLoadedOnce: true,
      );
    },
    act: (bloc) => bloc.add(CharacterSummaryCharacterSelected(CharacterId('c1'))),
    expect: () => <Matcher>[
      isA<CharacterSummaryState>()
          .having((state) => state.selectedId?.value, 'selectedId', 'c1')
          .having((state) => state.isSharing, 'isSharing', false)
          .having((state) => state.shareIntent, 'shareIntent', isNull),
    ],
  );

  blocTest<CharacterSummaryBloc, CharacterSummaryState>(
    'génère une intention de partage et active isSharing',
    build: () => CharacterSummaryBloc(
      listSavedCharacters: mockUseCase,
      catalog: mockCatalog,
      logger: logger,
    ),
    seed: () {
      final Character c1 = _dummyCharacter('c1');
      const LocalizedText humanLabel = LocalizedText(en: 'Human', fr: 'Humain');
      const LocalizedText guardianLabel =
          LocalizedText(en: 'Guardian', fr: 'Gardien');
      const LocalizedText outlawLabel =
          LocalizedText(en: 'Outlaw', fr: 'Hors-la-loi');
      const Map<String, LocalizedText> speciesNames =
          <String, LocalizedText>{'human': humanLabel};
      const Map<String, LocalizedText> classNames =
          <String, LocalizedText>{'guardian': guardianLabel};
      const Map<String, LocalizedText> backgroundNames =
          <String, LocalizedText>{'outlaw': outlawLabel};
      const BackgroundDef outlawDef = BackgroundDef(
        id: 'outlaw',
        name: outlawLabel,
        grantedSkills: <String>[],
      );
      const LanguageDef basicLanguage = LanguageDef(
        id: 'galactic-basic',
        name: LocalizedText(en: 'Galactic Basic', fr: 'Basic galactique'),
        description: null,
      );
      const SpeciesDef humanDef = SpeciesDef(
        id: 'human',
        name: humanLabel,
        speed: 30,
        size: 'medium',
        languageIds: <String>['galactic-basic'],
        languages: LocalizedText(en: 'Basic', fr: 'Basique'),
      );
      return CharacterSummaryState.initial().copyWith(
        characters: <Character>[c1],
        selectedId: c1.id,
        hasLoadedOnce: true,
        speciesDefinitions: const <String, SpeciesDef>{'human': humanDef},
        speciesNames: speciesNames,
        classNames: classNames,
        backgroundNames: backgroundNames,
        backgroundDefinitions: const <String, BackgroundDef>{'outlaw': outlawDef},
        languageDefinitions:
            const <String, LanguageDef>{'galactic-basic': basicLanguage},
      );
    },
    act: (bloc) {
      final AppLocalizations l10n = AppLocalizations(const Locale('fr'));
      bloc.add(CharacterSummaryShareRequested(l10n));
    },
    expect: () {
      final Character c1 = _dummyCharacter('c1');
      const Map<String, LocalizedText> speciesNames =
          <String, LocalizedText>{'human': LocalizedText(en: 'Human', fr: 'Humain')};
      const Map<String, LocalizedText> classNames =
          <String, LocalizedText>{'guardian': LocalizedText(en: 'Guardian', fr: 'Gardien')};
      const Map<String, LocalizedText> backgroundNames =
          <String, LocalizedText>{'outlaw': LocalizedText(en: 'Outlaw', fr: 'Hors-la-loi')};
      const ClassDef guardianClass = ClassDef(
        id: 'guardian',
        name: LocalizedText(en: 'Guardian', fr: 'Gardien'),
        hitDie: 10,
        level1: ClassLevel1Data(
          proficiencies: ClassLevel1Proficiencies(
            skillsChoose: 2,
            skillsFrom: <String>['perception'],
          ),
          startingEquipment: <StartingEquipmentLine>[],
          classFeatures: <ClassFeature>[
            ClassFeature(
              name: LocalizedText(en: 'Defensive Stance', fr: 'Posture défensive'),
              description: LocalizedText(
                en: 'Adopt a stance to guard allies.',
                fr: 'Adoptez une posture pour protéger vos alliés.',
              ),
              effects: <CatalogFeatureEffect>[
                CatalogFeatureEffect(
                  id: 'effect-1',
                  kind: 'bonus',
                  text: LocalizedText(
                    en: 'Gain advantage on opportunity attacks.',
                    fr: 'Gagnez l’avantage sur les attaques d’opportunité.',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      const BackgroundDef outlawDef = BackgroundDef(
        id: 'outlaw',
        name: LocalizedText(en: 'Outlaw', fr: 'Hors-la-loi'),
        grantedSkills: <String>[],
      );
      const SpeciesDef humanDef = SpeciesDef(
        id: 'human',
        name: LocalizedText(en: 'Human', fr: 'Humain'),
        speed: 30,
        size: 'medium',
        languageIds: <String>['galactic-basic'],
        languages: LocalizedText(en: 'Basic', fr: 'Basique'),
      );
      const LanguageDef basicLanguage = LanguageDef(
        id: 'galactic-basic',
        name: LocalizedText(en: 'Galactic Basic', fr: 'Basic galactique'),
        description: null,
      );
      final AppLocalizations frL10n = AppLocalizations(const Locale('fr'));
      final String expectedSubject =
          frL10n.savedCharacterShareSubject(c1.name.value);
      final String expectedMessage = frL10n.quickCreateCharacterSummary(
        c1,
        speciesNames: speciesNames,
        classNames: classNames,
        classDefinitions: const <String, ClassDef>{'guardian': guardianClass},
        backgroundNames: backgroundNames,
        backgroundDefinitions: const <String, BackgroundDef>{
          'outlaw': outlawDef,
        },
        speciesDefinition: humanDef,
        speciesLanguages: const <LanguageDef>[basicLanguage],
      );
      return <dynamic>[
        isA<CharacterSummaryState>()
            .having((state) => state.isSharing, 'isSharing', true)
            .having(
              (state) => state.shareIntent,
              'shareIntent',
              isA<CharacterSummaryShareIntent>()
                  .having((intent) => intent.subject, 'subject', expectedSubject)
                  .having((intent) => intent.message, 'message', expectedMessage),
            ),
        isA<CharacterSummaryState>()
            .having(
              (state) => state.backgroundDefinitions['outlaw'],
              'background definition',
              outlawDef,
            ),
        isA<CharacterSummaryState>()
            .having(
              (state) => state.classDefinitions['guardian'],
              'class definition',
              guardianClass,
            ),
      ];
    },
  );

  blocTest<CharacterSummaryBloc, CharacterSummaryState>(
    'réinitialise le partage sur CharacterSummaryShareAcknowledged',
    build: () => CharacterSummaryBloc(
      listSavedCharacters: mockUseCase,
      catalog: mockCatalog,
      logger: logger,
    ),
    seed: () {
      final Character c1 = _dummyCharacter('c1');
      return CharacterSummaryState.initial().copyWith(
        characters: <Character>[c1],
        selectedId: c1.id,
        hasLoadedOnce: true,
        isSharing: true,
        shareIntent: const CharacterSummaryShareIntent(
          subject: 'Sujet',
          message: 'Message',
        ),
      );
    },
    act: (bloc) => bloc.add(const CharacterSummaryShareAcknowledged()),
    expect: () => <Matcher>[
      isA<CharacterSummaryState>()
          .having((state) => state.isSharing, 'isSharing', false)
          .having((state) => state.shareIntent, 'shareIntent', isNull),
    ],
  );
}
