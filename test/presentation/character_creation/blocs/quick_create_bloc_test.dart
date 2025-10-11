/// ---------------------------------------------------------------------------
/// Fichier test : quick_create_bloc_test.dart
/// Rôle : Vérifier les transitions principales du QuickCreateBloc (chargement
///        du catalogue et finalisation d'un personnage).
/// ---------------------------------------------------------------------------
library;
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_character_draft.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_class_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_quick_create_catalog.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_ability_scores.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_background.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_class.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_equipment.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_name.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_species.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_step.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_skills.dart';
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
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';
import 'package:sw5e_manager/domain/characters/usecases/clear_character_draft.dart';
import 'package:sw5e_manager/presentation/character_creation/blocs/quick_create_bloc.dart';
import 'package:sw5e_manager/presentation/character_creation/states/quick_create_state.dart';

class _MockLoadQuickCreateCatalog extends Mock
    implements LoadQuickCreateCatalog {}

class _MockLoadSpeciesDetails extends Mock implements LoadSpeciesDetails {}

class _MockLoadClassDetails extends Mock implements LoadClassDetails {}

class _MockLoadCharacterDraft extends Mock implements LoadCharacterDraft {}

class _MockFinalizeLevel1Character extends Mock
    implements FinalizeLevel1Character {}

class _MockAppLogger extends Mock implements AppLogger {}

class _MockPersistCharacterDraftSpecies extends Mock
    implements PersistCharacterDraftSpecies {}

class _MockPersistCharacterDraftName extends Mock
    implements PersistCharacterDraftName {}

class _MockPersistCharacterDraftClass extends Mock
    implements PersistCharacterDraftClass {}

class _MockPersistCharacterDraftBackground extends Mock
    implements PersistCharacterDraftBackground {}

class _MockPersistCharacterDraftAbilityScores extends Mock
    implements PersistCharacterDraftAbilityScores {}

class _MockPersistCharacterDraftSkills extends Mock
    implements PersistCharacterDraftSkills {}

class _MockPersistCharacterDraftEquipment extends Mock
    implements PersistCharacterDraftEquipment {}

class _MockPersistCharacterDraftStep extends Mock
    implements PersistCharacterDraftStep {}

class _MockClearCharacterDraft extends Mock implements ClearCharacterDraft {}

Character _dummyCharacter() {
  return Character(
    id: CharacterId('char-1'),
    name: CharacterName('Test Hero'),
    speciesId: SpeciesId('human'),
    classId: ClassId('guardian'),
    backgroundId: BackgroundId('outlaw'),
    level: Level.one,
    abilities: <String, AbilityScore>{
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
    superiorityDice: SuperiorityDice(count: 0, die: null),
  );
}

void main() {
  late _MockLoadQuickCreateCatalog loadCatalog;
  late _MockLoadSpeciesDetails loadSpeciesDetails;
  late _MockLoadClassDetails loadClassDetails;
  late _MockLoadCharacterDraft loadCharacterDraft;
  late _MockFinalizeLevel1Character finalize;
  late _MockAppLogger logger;
  late _MockPersistCharacterDraftSpecies persistDraftSpecies;
  late _MockPersistCharacterDraftName persistDraftName;
  late _MockPersistCharacterDraftClass persistDraftClass;
  late _MockPersistCharacterDraftBackground persistDraftBackground;
  late _MockPersistCharacterDraftAbilityScores persistDraftAbilityScores;
  late _MockPersistCharacterDraftSkills persistDraftSkills;
  late _MockPersistCharacterDraftEquipment persistDraftEquipment;
  late _MockPersistCharacterDraftStep persistDraftStep;
  late _MockClearCharacterDraft clearDraft;

  setUpAll(() {
    registerFallbackValue(
      FinalizeLevel1Input(
        name: CharacterName('fallback'),
        speciesId: SpeciesId('human'),
        classId: ClassId('guardian'),
        backgroundId: BackgroundId('outlaw'),
        baseAbilities: <String, AbilityScore>{
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
    registerFallbackValue(
      DraftAbilityScores(
        mode: DraftAbilityGenerationMode.standardArray,
        assignments: const <String, int?>{},
        pool: const <int>[],
      ),
    );
    registerFallbackValue(
      DraftEquipmentSelection(
        useStartingEquipment: true,
        quantities: const <String, int>{},
      ),
    );
    registerFallbackValue(<String>{});
  });

  setUp(() {
    loadCatalog = _MockLoadQuickCreateCatalog();
    loadSpeciesDetails = _MockLoadSpeciesDetails();
    loadClassDetails = _MockLoadClassDetails();
    loadCharacterDraft = _MockLoadCharacterDraft();
    finalize = _MockFinalizeLevel1Character();
    logger = _MockAppLogger();
    persistDraftSpecies = _MockPersistCharacterDraftSpecies();
    persistDraftName = _MockPersistCharacterDraftName();
    persistDraftClass = _MockPersistCharacterDraftClass();
    persistDraftBackground = _MockPersistCharacterDraftBackground();
    persistDraftAbilityScores = _MockPersistCharacterDraftAbilityScores();
    persistDraftSkills = _MockPersistCharacterDraftSkills();
    persistDraftEquipment = _MockPersistCharacterDraftEquipment();
    persistDraftStep = _MockPersistCharacterDraftStep();
    clearDraft = _MockClearCharacterDraft();

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
    when(() => persistDraftSpecies.call(any()))
        .thenAnswer((_) async => appOk(const CharacterDraft()));
    when(() => persistDraftName.call(any()))
        .thenAnswer((_) async => appOk(const CharacterDraft()));
    when(() => persistDraftClass.call(any()))
        .thenAnswer((_) async => appOk(const CharacterDraft()));
    when(() => persistDraftBackground.call(any()))
        .thenAnswer((_) async => appOk(const CharacterDraft()));
    when(() => persistDraftAbilityScores.call(any()))
        .thenAnswer((_) async => appOk(const CharacterDraft()));
    when(() => persistDraftSkills.call(any()))
        .thenAnswer((_) async => appOk(const CharacterDraft()));
    when(() => persistDraftEquipment.call(any()))
        .thenAnswer((_) async => appOk(const CharacterDraft()));
    when(() => persistDraftStep.call(any()))
        .thenAnswer((_) async => appOk(const CharacterDraft()));
    when(() => clearDraft())
        .thenAnswer((_) async => appOk<void>(null));
    when(() => loadCharacterDraft()).thenAnswer((_) async => appOk(null));
  });

  QuickCreateBloc buildBloc() {
    return QuickCreateBloc(
      loadQuickCreateCatalog: loadCatalog,
      loadSpeciesDetails: loadSpeciesDetails,
      loadClassDetails: loadClassDetails,
      loadCharacterDraft: loadCharacterDraft,
      finalizeLevel1Character: finalize,
      logger: logger,
      persistCharacterDraftName: persistDraftName,
      persistCharacterDraftSpecies: persistDraftSpecies,
      persistCharacterDraftClass: persistDraftClass,
      persistCharacterDraftBackground: persistDraftBackground,
      persistCharacterDraftAbilityScores: persistDraftAbilityScores,
      persistCharacterDraftSkills: persistDraftSkills,
      persistCharacterDraftEquipment: persistDraftEquipment,
      persistCharacterDraftStep: persistDraftStep,
      clearCharacterDraft: clearDraft,
    );
  }

  void arrangeCatalogSuccess() {
    final EquipmentDef equipment = const EquipmentDef(
      id: 'comlink',
      name: LocalizedText(en: 'Comlink', fr: 'Comlink'),
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

    when(() => persistDraftSpecies.call(any())).thenAnswer(
      (_) async => appOk(
        CharacterDraft(
          species: DraftSpeciesSelection(
            speciesId: SpeciesId('human'),
            displayName: 'Human',
            effects: const <CharacterEffect>[
              CharacterEffect(
                source: 'test:adaptive',
                title: 'Adaptive',
                description: 'Versatile ability boost.',
                category: CharacterEffectCategory.passive,
              ),
            ],
          ),
        ),
      ),
    );

    when(() => loadClassDetails('guardian')).thenAnswer(
      (_) async => appOk(
        const QuickCreateClassDetails(
          classDef: ClassDef(
            id: 'guardian',
            name: LocalizedText(en: 'Guardian', fr: 'Gardien'),
            hitDie: 10,
            level1: ClassLevel1Data(
              proficiencies: ClassLevel1Proficiencies(
                skillsChoose: 0,
                skillsFrom: <String>[],
              ),
              startingCredits: 100,
              startingEquipment: <StartingEquipmentLine>[],
            ),
          ),
          availableSkillIds: <String>[],
          skillDefinitions: <String, SkillDef>{},
          skillChoicesRequired: 0,
        ),
      ),
    );
  }

  test('l’état initial est QuickCreateState.initial()', () {
    final bloc = buildBloc();
    expect(bloc.state.stepIndex, QuickCreateState.initial().stepIndex);
    expect(bloc.state.selectedSpecies, QuickCreateState.initial().selectedSpecies);
    bloc.close();
  });

  blocTest<QuickCreateBloc, QuickCreateState>(
    'charge le catalogue et sélectionne les premières entrées',
    build: () {
      arrangeCatalogSuccess();
      return buildBloc();
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
      expect(state.selectedSpeciesEffects, isNotEmpty);
    },
  );

  blocTest<QuickCreateBloc, QuickCreateState>(
    'réutilise l\'espèce sauvegardée si elle est disponible',
    build: () {
      final EquipmentDef equipment = const EquipmentDef(
        id: 'comlink',
        name: LocalizedText(en: 'Comlink', fr: 'Comlink'),
        type: 'gear',
        weightG: 100,
        cost: 25,
      );

      when(() => loadCatalog()).thenAnswer(
        (_) async => appOk(
          QuickCreateCatalogSnapshot(
            speciesIds: const <String>['human', 'bith'],
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

      when(() => loadSpeciesDetails('bith')).thenAnswer(
        (_) async => appOk(
          const QuickCreateSpeciesDetails(
            species: SpeciesDef(
              id: 'bith',
              name: LocalizedText(en: 'Bith', fr: 'Bith'),
              speed: 30,
              size: 'medium',
              traitIds: <String>['detail-oriented'],
            ),
            traits: <TraitDef>[
              TraitDef(
                id: 'detail-oriented',
                name: LocalizedText(en: 'Detail Oriented', fr: 'Detail Oriented'),
                description: 'You have advantage on Investigation checks within 5 feet.',
              ),
            ],
          ),
        ),
      );

      when(() => loadClassDetails('guardian')).thenAnswer(
        (_) async => appOk(
          const QuickCreateClassDetails(
            classDef: ClassDef(
              id: 'guardian',
              name: LocalizedText(en: 'Guardian', fr: 'Gardien'),
              hitDie: 10,
              level1: ClassLevel1Data(
                proficiencies: ClassLevel1Proficiencies(
                  skillsChoose: 0,
                  skillsFrom: <String>[],
                ),
                startingCredits: 100,
                startingEquipment: <StartingEquipmentLine>[],
              ),
            ),
            availableSkillIds: <String>[],
            skillDefinitions: <String, SkillDef>{},
            skillChoicesRequired: 0,
          ),
        ),
      );

      when(() => persistDraftSpecies.call(any())).thenAnswer(
        (_) async => appOk(
          CharacterDraft(
            species: DraftSpeciesSelection(
              speciesId: SpeciesId('bith'),
              displayName: 'Bith',
              effects: const <CharacterEffect>[
                CharacterEffect(
                  source: 'trait:detail-oriented',
                  title: 'Detail Oriented',
                  description: 'Focus on minutiae.',
                  category: CharacterEffectCategory.passive,
                ),
              ],
            ),
          ),
        ),
      );

      when(() => loadCharacterDraft()).thenAnswer(
        (_) async => appOk(
          CharacterDraft(
            species: DraftSpeciesSelection(
              speciesId: SpeciesId('bith'),
              displayName: 'Bith',
              effects: const <CharacterEffect>[
                CharacterEffect(
                  source: 'persisted:memory',
                  title: 'Stored Effect',
                  description: 'Loaded from draft.',
                  category: CharacterEffectCategory.action,
                ),
              ],
            ),
          ),
        ),
      );

      return buildBloc();
    },
    act: (bloc) => bloc.add(const QuickCreateStarted()),
    wait: const Duration(milliseconds: 20),
    expect: () => <Matcher>[],
    verify: (bloc) {
      expect(bloc.state.selectedSpecies, 'bith');
      expect(bloc.state.selectedSpeciesTraits, isNotEmpty);
      expect(bloc.state.selectedSpeciesEffects, isNotEmpty);
      expect(
        bloc.state.selectedSpeciesEffects.first.title,
        anyOf('Detail Oriented', 'Stored Effect'),
      );
    },
  );

  blocTest<QuickCreateBloc, QuickCreateState>(
    'ré-ouvre l\'assistant à l\'étape sauvegardée',
    build: () {
      arrangeCatalogSuccess();
      when(() => loadCharacterDraft()).thenAnswer(
        (_) async => appOk(
          CharacterDraft(
            species: DraftSpeciesSelection(
              speciesId: SpeciesId('human'),
              displayName: 'Human',
              effects: const <CharacterEffect>[],
            ),
            stepIndex: 3,
          ),
        ),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const QuickCreateStarted()),
    wait: const Duration(milliseconds: 20),
    expect: () => <Matcher>[],
    verify: (bloc) {
      expect(bloc.state.stepIndex, 3);
    },
  );

  blocTest<QuickCreateBloc, QuickCreateState>(
    'persiste l\'étape lors de la navigation',
    build: () {
      arrangeCatalogSuccess();
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(const QuickCreateStarted());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      bloc.add(const QuickCreateNextStepRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
    },
    wait: const Duration(milliseconds: 40),
    expect: () => <Matcher>[],
    verify: (_) {
      verify(() => persistDraftStep.call(1)).called(1);
    },
  );

  blocTest<QuickCreateBloc, QuickCreateState>(
    'réhydrate la classe, le background, les aptitudes et l\'équipement depuis le brouillon',
    build: () {
      final EquipmentDef equipment = const EquipmentDef(
        id: 'comlink',
        name: LocalizedText(en: 'Comlink', fr: 'Comlink'),
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
            traits: <TraitDef>[],
          ),
        ),
      );

      when(() => loadClassDetails('guardian')).thenAnswer(
        (_) async => appOk(
          QuickCreateClassDetails(
            classDef: const ClassDef(
              id: 'guardian',
              name: LocalizedText(en: 'Guardian', fr: 'Gardien'),
              hitDie: 10,
              level1: ClassLevel1Data(
                proficiencies: ClassLevel1Proficiencies(
                  skillsChoose: 2,
                  skillsFrom: <String>['acrobatics', 'athletics'],
                ),
                startingCredits: 100,
                startingEquipment: <StartingEquipmentLine>[],
              ),
            ),
            availableSkillIds: const <String>['acrobatics', 'athletics'],
            skillDefinitions: const <String, SkillDef>{
              'acrobatics': SkillDef(
                id: 'acrobatics',
                name: LocalizedText(en: 'Acrobatics', fr: 'Acrobaties'),
              ),
              'athletics': SkillDef(
                id: 'athletics',
                name: LocalizedText(en: 'Athletics', fr: 'Athlétisme'),
              ),
            },
            skillChoicesRequired: 2,
          ),
        ),
      );

      when(() => loadCharacterDraft()).thenAnswer(
        (_) async => appOk(
          CharacterDraft(
            name: 'Drafty',
            species: DraftSpeciesSelection(
              speciesId: SpeciesId('human'),
              displayName: 'Human',
              effects: const <CharacterEffect>[],
            ),
            classId: ClassId('guardian'),
            backgroundId: BackgroundId('outlaw'),
            abilityScores: DraftAbilityScores(
              mode: DraftAbilityGenerationMode.manual,
              assignments: const <String, int?>{
                'str': 13,
                'dex': 12,
                'con': 11,
                'int': 10,
                'wis': 9,
                'cha': 8,
              },
              pool: const <int>[],
            ),
            chosenSkills: const <String>{'acrobatics'},
            equipment: DraftEquipmentSelection(
              useStartingEquipment: false,
              quantities: const <String, int>{'comlink': 2},
            ),
          ),
        ),
      );

      return buildBloc();
    },
    act: (bloc) => bloc.add(const QuickCreateStarted()),
    wait: const Duration(milliseconds: 20),
    expect: () => <Matcher>[],
    verify: (bloc) {
      final state = bloc.state;
      expect(state.characterName, 'Drafty');
      expect(state.selectedSpecies, 'human');
      expect(state.selectedClass, 'guardian');
      expect(state.selectedBackground, 'outlaw');
      expect(state.abilityMode, AbilityGenerationMode.manual);
      expect(state.abilityAssignments['str'], 13);
      expect(state.abilityPool, isEmpty);
      expect(state.chosenSkills, contains('acrobatics'));
      expect(state.useStartingEquipment, isFalse);
      expect(state.chosenEquipment['comlink'], 2);
    },
  );

  blocTest<QuickCreateBloc, QuickCreateState>(
    'finalise un personnage avec succès',
    build: () {
      arrangeCatalogSuccess();
      when(() => finalize.call(any())).thenAnswer(
        (_) async => appOk(_dummyCharacter()),
      );
      return buildBloc();
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
      verify(() => clearDraft()).called(1);
    },
  );
}
