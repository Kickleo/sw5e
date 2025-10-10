/// ---------------------------------------------------------------------------
/// Fichier test : quick_create_bloc_test.dart
/// Rôle : Vérifier les transitions principales du QuickCreateBloc (chargement
///        du catalogue et finalisation d'un personnage).
/// ---------------------------------------------------------------------------
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_class_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_quick_create_catalog.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';
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
import 'package:sw5e_manager/presentation/character_creation/blocs/quick_create_bloc.dart';
import 'package:sw5e_manager/presentation/character_creation/states/quick_create_state.dart';

class _MockLoadQuickCreateCatalog extends Mock
    implements LoadQuickCreateCatalog {}

class _MockLoadSpeciesDetails extends Mock implements LoadSpeciesDetails {}

class _MockLoadClassDetails extends Mock implements LoadClassDetails {}

class _MockFinalizeLevel1Character extends Mock
    implements FinalizeLevel1Character {}

class _MockAppLogger extends Mock implements AppLogger {}

Character _dummyCharacter() {
  return Character(
    id: CharacterId('char-1'),
    name: CharacterName('Test Hero'),
    speciesId: SpeciesId('human'),
    classId: ClassId('guardian'),
    backgroundId: BackgroundId('outlaw'),
    level: Level.one,
    abilities: const <String, AbilityScore>{
      'str': AbilityScore(15),
      'dex': AbilityScore(14),
      'con': AbilityScore(13),
      'int': AbilityScore(12),
      'wis': AbilityScore(10),
      'cha': AbilityScore(8),
    },
    skills: const <SkillProficiency>{},
    proficiencyBonus: ProficiencyBonus.fromLevel(Level.one),
    hitPoints: HitPoints(10),
    defense: Defense(12),
    initiative: Initiative(2),
    credits: Credits(100),
    inventory: const <InventoryLine>[],
    encumbrance: Encumbrance(0),
    maneuversKnown: ManeuversKnown(0),
    superiorityDice: const SuperiorityDice(count: 0, die: null),
  );
}

void main() {
  late _MockLoadQuickCreateCatalog loadCatalog;
  late _MockLoadSpeciesDetails loadSpeciesDetails;
  late _MockLoadClassDetails loadClassDetails;
  late _MockFinalizeLevel1Character finalize;
  late _MockAppLogger logger;

  setUpAll(() {
    registerFallbackValue(
      FinalizeLevel1Input(
        name: CharacterName('fallback'),
        speciesId: SpeciesId('human'),
        classId: ClassId('guardian'),
        backgroundId: BackgroundId('outlaw'),
        baseAbilities: const <String, AbilityScore>{
          'str': AbilityScore(10),
          'dex': AbilityScore(10),
          'con': AbilityScore(10),
          'int': AbilityScore(10),
          'wis': AbilityScore(10),
          'cha': AbilityScore(10),
        },
        chosenSkills: const <String>{},
        chosenEquipment: const <ChosenEquipmentLine>[],
      ),
    );
  });

  setUp(() {
    loadCatalog = _MockLoadQuickCreateCatalog();
    loadSpeciesDetails = _MockLoadSpeciesDetails();
    loadClassDetails = _MockLoadClassDetails();
    finalize = _MockFinalizeLevel1Character();
    logger = _MockAppLogger();

    when(() => logger.info(any(), payload: any(named: 'payload')))
        .thenAnswer((_) {});
    when(() => logger.warn(any(),
            payload: any(named: 'payload'),
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace')))
        .thenAnswer((_) {});
    when(() => logger.error(any(),
            payload: any(named: 'payload'),
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace')))
        .thenAnswer((_) {});
  });

  QuickCreateBloc _buildBloc() {
    return QuickCreateBloc(
      loadQuickCreateCatalog: loadCatalog,
      loadSpeciesDetails: loadSpeciesDetails,
      loadClassDetails: loadClassDetails,
      finalizeLevel1Character: finalize,
      logger: logger,
    );
  }

  void _arrangeCatalogSuccess() {
    final EquipmentDef equipment = EquipmentDef(
      id: 'comlink',
      name: const LocalizedText(en: 'Comlink', fr: 'Comlink'),
      type: 'gear',
      weightG: 100,
      cost: 25,
    );
    when(() => loadCatalog()).thenAnswer(
      (_) async => appOk(
        QuickCreateCatalogSnapshot(
          speciesIds: const <String>['human'],
          classIds: const <String>['guardian'],
          backgroundIds: const <String>['outlaw'],
          equipmentById: <String, EquipmentDef>{'comlink': equipment},
          sortedEquipmentIds: const <String>['comlink'],
          defaultSpeciesId: 'human',
          defaultClassId: 'guardian',
          defaultBackgroundId: 'outlaw',
        ),
      ),
    );

    when(() => loadSpeciesDetails('human')).thenAnswer(
      (_) async => appOk(
        const QuickCreateSpeciesDetails(
          species: SpeciesDef(
            id: 'human',
            name: LocalizedText(en: 'Human', fr: 'Humain'),
            speed: 30,
            size: 'medium',
            traitIds: <String>['adaptive'],
          ),
          traits: <TraitDef>[
            TraitDef(
              id: 'adaptive',
              name: LocalizedText(en: 'Adaptive', fr: 'Adaptable'),
              description: 'Polyvalent.',
            ),
          ],
        ),
      ),
    );

    when(() => loadClassDetails('guardian')).thenAnswer(
      (_) async => appOk(
        QuickCreateClassDetails(
          classDef: ClassDef(
            id: 'guardian',
            name: const LocalizedText(en: 'Guardian', fr: 'Gardien'),
            hitDie: 10,
            level1: ClassLevel1Data(
              proficiencies: const ClassLevel1Proficiencies(
                skillsChoose: 0,
                skillsFrom: <String>[],
              ),
              startingCredits: 100,
              startingEquipment: const <StartingEquipmentLine>[],
            ),
          ),
          availableSkillIds: const <String>[],
          skillDefinitions: const <String, SkillDef>{},
          skillChoicesRequired: 0,
        ),
      ),
    );
  }

  test('l’état initial est QuickCreateState.initial()', () {
    final bloc = _buildBloc();
    expect(bloc.state.stepIndex, QuickCreateState.initial().stepIndex);
    expect(bloc.state.selectedSpecies, QuickCreateState.initial().selectedSpecies);
    bloc.close();
  });

  blocTest<QuickCreateBloc, QuickCreateState>(
    'charge le catalogue et sélectionne les premières entrées',
    build: () {
      _arrangeCatalogSuccess();
      return _buildBloc();
    },
    act: (bloc) => bloc.add(const QuickCreateStarted()),
    wait: const Duration(milliseconds: 20),
    expect: () => <Matcher>[],
    verify: (bloc) {
      final state = bloc.state;
      expect(state.isLoadingCatalog, isFalse);
      expect(state.species, contains('human'));
      expect(state.selectedSpecies, 'human');
      expect(state.selectedClass, 'guardian');
      expect(state.selectedBackground, 'outlaw');
      expect(state.equipmentList, contains('comlink'));
      expect(state.selectedSpeciesTraits, isNotEmpty);
    },
  );

  blocTest<QuickCreateBloc, QuickCreateState>(
    'finalise un personnage avec succès',
    build: () {
      _arrangeCatalogSuccess();
      when(() => finalize.call(any())).thenAnswer(
        (_) async => appOk(_dummyCharacter()),
      );
      return _buildBloc();
    },
    act: (bloc) async {
      bloc.add(const QuickCreateStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const QuickCreateSubmitted());
    },
    wait: const Duration(milliseconds: 80),
    expect: () => <Matcher>[],
    verify: (bloc) {
      final state = bloc.state;
      expect(state.completion, isA<QuickCreateSuccess>());
      expect(state.isCreating, isFalse);
      verify(() => finalize.call(any())).called(1);
    },
  );
}
