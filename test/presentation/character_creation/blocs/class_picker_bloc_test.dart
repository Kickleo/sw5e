/// ---------------------------------------------------------------------------
/// Fichier test : class_picker_bloc_test.dart
/// Rôle : Vérifier le comportement du ClassPickerBloc (chargement initial,
///        changement de sélection, erreurs).
/// ---------------------------------------------------------------------------
library;
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/presentation/character_creation/blocs/class_picker_bloc.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _MockAppLogger extends Mock implements AppLogger {}

class _FakeStackTrace extends Fake implements StackTrace {}

void main() {
  setUpAll(() {
    registerFallbackValue(Exception('fallback'));
    registerFallbackValue(_FakeStackTrace());
  });

  late _MockCatalogRepository catalog;
  late _MockAppLogger logger;

  setUp(() {
    catalog = _MockCatalogRepository();
    logger = _MockAppLogger();
    when(() => logger.info(any(), payload: any(named: 'payload'))).thenReturn(null);
    when(
      () => logger.warn(
        any(),
        payload: any(named: 'payload'),
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'),
      ),
    ).thenReturn(null);
    when(
      () => logger.error(
        any(),
        payload: any(named: 'payload'),
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'),
      ),
    ).thenReturn(null);
  });

  ClassDef buildClass({required String id}) {
    return ClassDef(
      id: id,
      name: const LocalizedText(en: 'Guardian', fr: 'Gardien'),
      hitDie: 10,
      level1: const ClassLevel1Data(
        proficiencies: ClassLevel1Proficiencies(
          skillsChoose: 2,
          skillsFrom: <String>['athletics', 'any'],
        ),
        startingEquipment: <StartingEquipmentLine>[
          StartingEquipmentLine(id: 'blaster-pistol', qty: 1),
        ],
      ),
      primaryAbilities: const <String>['dex'],
      savingThrows: const <String>['wis', 'con'],
      weaponProficiencies: const <String>['simple', 'martial'],
      armorProficiencies: const <String>['light', 'medium'],
      toolProficiencies: const <String>['artisan-tools'],
    );
  }

  const SkillDef skillAthletics = SkillDef(
    id: 'athletics',
    ability: 'str',
    name: LocalizedText(en: 'Athletics', fr: 'Athlétisme'),
  );
  const AbilityDef abilityStrength = AbilityDef(
    id: 'str',
    abbreviation: 'STR',
    name: LocalizedText(en: 'Strength', fr: 'Force'),
  );
  const AbilityDef abilityDexterity = AbilityDef(
    id: 'dex',
    abbreviation: 'DEX',
    name: LocalizedText(en: 'Dexterity', fr: 'Dextérité'),
  );
  const AbilityDef abilityWisdom = AbilityDef(
    id: 'wis',
    abbreviation: 'WIS',
    name: LocalizedText(en: 'Wisdom', fr: 'Sagesse'),
  );
  const AbilityDef abilityConstitution = AbilityDef(
    id: 'con',
    abbreviation: 'CON',
    name: LocalizedText(en: 'Constitution', fr: 'Constitution'),
  );
  final EquipmentDef equipmentBlaster = const EquipmentDef(
    id: 'blaster-pistol',
    name: LocalizedText(en: 'Blaster pistol', fr: 'Pistolet blaster'),
    type: 'weapon',
    weightG: 1000,
    cost: 500,
  );

  test('état initial = ClassPickerState.initial()', () {
    final ClassPickerBloc bloc = ClassPickerBloc(catalog: catalog, logger: logger);
    expect(bloc.state, ClassPickerState.initial());
    bloc.close();
  });

  blocTest<ClassPickerBloc, ClassPickerState>(
    'charge la liste initiale et sélectionne la première classe',
    build: () {
      when(() => catalog.listClasses()).thenAnswer(
        (_) async => <String>['guardian'],
      );
      when(() => catalog.getClass('guardian')).thenAnswer(
        (_) async => buildClass(id: 'guardian'),
      );
      when(() => catalog.getSkill('athletics')).thenAnswer(
        (_) async => skillAthletics,
      );
      when(() => catalog.getAbility('str')).thenAnswer((_) async => abilityStrength);
      when(() => catalog.getAbility('dex')).thenAnswer((_) async => abilityDexterity);
      when(() => catalog.getAbility('wis')).thenAnswer((_) async => abilityWisdom);
      when(() => catalog.getAbility('con')).thenAnswer((_) async => abilityConstitution);
      when(() => catalog.getEquipment('blaster-pistol')).thenAnswer(
        (_) async => equipmentBlaster,
      );
      return ClassPickerBloc(catalog: catalog, logger: logger);
    },
    act: (ClassPickerBloc bloc) => bloc.add(const ClassPickerStarted()),
    expect: () => <Matcher>[
      isA<ClassPickerState>()
          .having((ClassPickerState state) => state.isLoadingList, 'isLoadingList', true)
          .having(
            (ClassPickerState state) => state.isLoadingDetails,
            'isLoadingDetails',
            true,
          ),
      isA<ClassPickerState>()
          .having((ClassPickerState state) => state.isLoadingList, 'isLoadingList', false)
          .having((ClassPickerState state) => state.isLoadingDetails, 'isLoadingDetails', false)
          .having((ClassPickerState state) => state.classIds, 'classIds', <String>['guardian'])
          .having(
            (ClassPickerState state) =>
                state.classDefinitions.containsKey('guardian'),
            'class cached',
            true,
          )
          .having((ClassPickerState state) => state.selectedClassId, 'selectedClassId', 'guardian')
          .having((ClassPickerState state) => state.selectedClass?.id, 'selectedClass.id', 'guardian')
          .having(
            (ClassPickerState state) => state.skillDefinitions.containsKey('athletics'),
            'skill cached',
            true,
          )
          .having(
            (ClassPickerState state) => state.abilityDefinitions.containsKey('str'),
            'ability cached',
            true,
          )
          .having(
            (ClassPickerState state) => state.abilityDefinitions.containsKey('dex'),
            'dex cached',
            true,
          )
          .having(
            (ClassPickerState state) => state.abilityDefinitions.containsKey('wis'),
            'wis cached',
            true,
          )
          .having(
            (ClassPickerState state) => state.abilityDefinitions.containsKey('con'),
            'con cached',
            true,
          )
          .having(
            (ClassPickerState state) =>
                state.equipmentDefinitions.containsKey('blaster-pistol'),
            'equipment cached',
            true,
          )
          .having((ClassPickerState state) => state.failure, 'failure', isNull),
    ],
    verify: (_) {
      verify(() => catalog.listClasses()).called(1);
      verify(() => catalog.getClass('guardian')).called(1);
      verify(() => catalog.getSkill('athletics')).called(1);
      verify(() => catalog.getAbility('str')).called(1);
      verify(() => catalog.getAbility('dex')).called(1);
      verify(() => catalog.getAbility('wis')).called(1);
      verify(() => catalog.getAbility('con')).called(1);
      verify(() => catalog.getEquipment('blaster-pistol')).called(1);
      verifyNever(() => logger.error(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace')));
    },
  );

  blocTest<ClassPickerBloc, ClassPickerState>(
    'met à jour la sélection lorsque l’utilisateur change de classe',
    build: () {
      when(() => catalog.listClasses()).thenAnswer(
        (_) async => <String>['guardian', 'scoundrel'],
      );
      when(() => catalog.getClass('guardian')).thenAnswer(
        (_) async => buildClass(id: 'guardian'),
      );
      when(() => catalog.getClass('scoundrel')).thenAnswer(
        (_) async => buildClass(id: 'scoundrel'),
      );
      when(() => catalog.getSkill('athletics')).thenAnswer(
        (_) async => skillAthletics,
      );
      when(() => catalog.getAbility('str')).thenAnswer((_) async => abilityStrength);
      when(() => catalog.getAbility('dex')).thenAnswer((_) async => abilityDexterity);
      when(() => catalog.getAbility('wis')).thenAnswer((_) async => abilityWisdom);
      when(() => catalog.getAbility('con')).thenAnswer((_) async => abilityConstitution);
      when(() => catalog.getEquipment('blaster-pistol')).thenAnswer(
        (_) async => equipmentBlaster,
      );
      return ClassPickerBloc(catalog: catalog, logger: logger);
    },
    act: (ClassPickerBloc bloc) async {
      bloc.add(const ClassPickerStarted(initialClassId: 'guardian'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ClassPickerClassRequested('scoundrel'));
    },
    expect: () => <Matcher>[
      isA<ClassPickerState>().having(
        (ClassPickerState state) => state.isLoadingList,
        'isLoadingList',
        true,
      ),
      isA<ClassPickerState>()
          .having((ClassPickerState state) => state.selectedClassId, 'selectedClassId', 'guardian')
          .having((ClassPickerState state) => state.isLoadingDetails, 'isLoadingDetails', false),
      isA<ClassPickerState>()
          .having((ClassPickerState state) => state.isLoadingDetails, 'isLoadingDetails', true)
          .having((ClassPickerState state) => state.selectedClassId, 'selectedClassId', 'scoundrel'),
      isA<ClassPickerState>()
          .having((ClassPickerState state) => state.isLoadingDetails, 'isLoadingDetails', false)
          .having((ClassPickerState state) => state.selectedClassId, 'selectedClassId', 'scoundrel')
          .having(
            (ClassPickerState state) =>
                state.classDefinitions.containsKey('scoundrel'),
            'scoundrel cached',
            true,
          )
          .having((ClassPickerState state) => state.selectedClass?.id, 'selectedClass.id', 'scoundrel')
          .having(
            (ClassPickerState state) => state.abilityDefinitions.containsKey('str'),
            'ability cached',
            true,
          ),
    ],
    verify: (_) {
      verify(() => catalog.getClass('scoundrel')).called(1);
    },
  );

  blocTest<ClassPickerBloc, ClassPickerState>(
    'publie une erreur et journalise lorsque la liste échoue',
    build: () {
      when(() => catalog.listClasses()).thenThrow(Exception('boom'));
      return ClassPickerBloc(catalog: catalog, logger: logger);
    },
    act: (ClassPickerBloc bloc) => bloc.add(const ClassPickerStarted()),
    expect: () => <Matcher>[
      isA<ClassPickerState>()
          .having((ClassPickerState state) => state.isLoadingList, 'isLoadingList', true)
          .having((ClassPickerState state) => state.isLoadingDetails, 'isLoadingDetails', true),
      isA<ClassPickerState>()
          .having((ClassPickerState state) => state.isLoadingList, 'isLoadingList', false)
          .having((ClassPickerState state) => state.isLoadingDetails, 'isLoadingDetails', false)
          .having((ClassPickerState state) => state.failure?.code, 'failureCode',
              'ClassListLoadFailed')
          .having(
            (ClassPickerState state) => state.errorMessage,
            'errorMessage',
            'ClassListLoadFailed — Échec du chargement des classes : Exception: boom',
          )
          .having((ClassPickerState state) => state.hasLoadedOnce, 'hasLoadedOnce', true),
    ],
    verify: (_) {
      verify(() => logger.error(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace'))).called(1);
    },
  );
}
