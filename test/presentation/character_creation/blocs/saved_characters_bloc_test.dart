/// ---------------------------------------------------------------------------
/// Fichier test : saved_characters_bloc_test.dart
/// Rôle : Garantir le comportement du SavedCharactersBloc (charge/erreur).
/// ---------------------------------------------------------------------------
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
import 'package:sw5e_manager/presentation/character_creation/blocs/saved_characters_bloc.dart';

class _MockListSavedCharacters extends Mock implements ListSavedCharacters {}

Character _dummyCharacter(String id) {
  return Character(
    id: CharacterId(id),
    name: CharacterName('Dummy $id'),
    speciesId: SpeciesId('human'),
    classId: ClassId('guardian'),
    backgroundId: BackgroundId('outlaw'),
    level: Level.one,
    abilities: const <String, AbilityScore>{
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
    superiorityDice: const SuperiorityDice(count: 0, die: null),
  );
}

void main() {
  late _MockListSavedCharacters mockUseCase;

  setUp(() {
    mockUseCase = _MockListSavedCharacters();
  });

  test('état initial = SavedCharactersState.initial()', () {
    final bloc = SavedCharactersBloc(listSavedCharacters: mockUseCase);
    expect(bloc.state, SavedCharactersState.initial());
    bloc.close();
  });

  blocTest<SavedCharactersBloc, SavedCharactersState>(
    'charge les personnages puis publie le succès',
    build: () {
      when(() => mockUseCase()).thenAnswer(
        (_) async => appOk(<Character>[_dummyCharacter('c1')]),
      );
      return SavedCharactersBloc(listSavedCharacters: mockUseCase);
    },
    act: (bloc) => bloc.add(const SavedCharactersRequested()),
    expect: () => <Matcher>[
      isA<SavedCharactersState>()
          .having((state) => state.isLoading, 'isLoading', true)
          .having((state) => state.hasLoadedOnce, 'hasLoadedOnce', false)
          .having((state) => state.errorMessage, 'error', isNull),
      isA<SavedCharactersState>()
          .having((state) => state.isLoading, 'isLoading', false)
          .having((state) => state.hasLoadedOnce, 'hasLoadedOnce', true)
          .having((state) => state.characters, 'characters', hasLength(1))
          .having((state) => state.failure, 'failure', isNull),
    ],
    verify: (_) => verify(() => mockUseCase()).called(1),
  );

  blocTest<SavedCharactersBloc, SavedCharactersState>(
    'publie une erreur formatée lorsque le use case échoue',
    build: () {
      when(() => mockUseCase()).thenAnswer(
        (_) async => appErr<List<Character>>(
          const DomainError('Unexpected', message: 'boom'),
        ),
      );
      return SavedCharactersBloc(listSavedCharacters: mockUseCase);
    },
    act: (bloc) => bloc.add(const SavedCharactersRequested()),
    expect: () => <Matcher>[
      isA<SavedCharactersState>()
          .having((state) => state.isLoading, 'isLoading', true)
          .having((state) => state.hasLoadedOnce, 'hasLoadedOnce', false),
      isA<SavedCharactersState>()
          .having((state) => state.isLoading, 'isLoading', false)
          .having((state) => state.hasLoadedOnce, 'hasLoadedOnce', true)
          .having((state) => state.failure?.code, 'failureCode', 'Unexpected')
          .having((state) => state.errorMessage, 'errorMessage', 'Unexpected — boom'),
    ],
    verify: (_) => verify(() => mockUseCase()).called(1),
  );
}
