/// ---------------------------------------------------------------------------
/// Fichier test : character_summary_bloc_test.dart
/// Rôle : Vérifier le comportement du CharacterSummaryBloc (chargement,
///        sélection, partage).
/// ---------------------------------------------------------------------------
library;
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
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
  late AppLogger logger;

  setUp(() {
    mockUseCase = _MockListSavedCharacters();
    logger = _FakeLogger();
  });

  test('état initial = CharacterSummaryState.initial()', () {
    final bloc = CharacterSummaryBloc(
      listSavedCharacters: mockUseCase,
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
          .having((state) => state.failure, 'failure', isNull),
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
      logger: logger,
    ),
    seed: () {
      final Character c1 = _dummyCharacter('c1');
      return CharacterSummaryState.initial().copyWith(
        characters: <Character>[c1],
        selectedId: c1.id,
        hasLoadedOnce: true,
      );
    },
    act: (bloc) => bloc.add(const CharacterSummaryShareRequested()),
    expect: () => <Matcher>[
      isA<CharacterSummaryState>()
          .having((state) => state.isSharing, 'isSharing', true)
          .having((state) => state.shareIntent, 'shareIntent', isNotNull),
    ],
  );

  blocTest<CharacterSummaryBloc, CharacterSummaryState>(
    'réinitialise le partage sur CharacterSummaryShareAcknowledged',
    build: () => CharacterSummaryBloc(
      listSavedCharacters: mockUseCase,
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
