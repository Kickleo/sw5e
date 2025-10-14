/// ---------------------------------------------------------------------------
/// Fichier test : species_picker_bloc_test.dart
/// Rôle : Vérifier le comportement du SpeciesPickerBloc (chargement initial,
///        changement de sélection, gestion des erreurs).
/// ---------------------------------------------------------------------------
library;
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/presentation/character_creation/blocs/species_picker_bloc.dart';

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

  SpeciesDef buildSpecies({required String id, List<String> traitIds = const <String>[]}) {
    return SpeciesDef(
      id: id,
      name: const LocalizedText(en: 'Human', fr: 'Humain'),
      speed: 30,
      size: 'medium',
      traitIds: traitIds,
    );
  }

  TraitDef buildTrait(String id) {
    return TraitDef(
      id: id,
      name: const LocalizedText(en: 'Trait', fr: 'Trait'),
      description:
          const LocalizedText(en: 'Description', fr: 'Description'),
    );
  }

  test('état initial = SpeciesPickerState.initial()', () {
    final SpeciesPickerBloc bloc = SpeciesPickerBloc(catalog: catalog, logger: logger);
    expect(bloc.state, SpeciesPickerState.initial());
    bloc.close();
  });

  blocTest<SpeciesPickerBloc, SpeciesPickerState>(
    'charge la liste initiale et sélectionne la première espèce',
    build: () {
      when(() => catalog.listSpecies()).thenAnswer((_) async => <String>['human']);
      when(() => catalog.getSpecies('human')).thenAnswer(
        (_) async => buildSpecies(id: 'human', traitIds: <String>['trait-1']),
      );
      when(() => catalog.getTrait('trait-1')).thenAnswer(
        (_) async => buildTrait('trait-1'),
      );
      return SpeciesPickerBloc(catalog: catalog, logger: logger);
    },
    act: (SpeciesPickerBloc bloc) => bloc.add(const SpeciesPickerStarted()),
    expect: () => <Matcher>[
      isA<SpeciesPickerState>()
          .having((SpeciesPickerState state) => state.isLoadingList, 'isLoadingList', true)
          .having((SpeciesPickerState state) => state.isLoadingDetails, 'isLoadingDetails', true),
      isA<SpeciesPickerState>()
          .having((SpeciesPickerState state) => state.isLoadingList, 'isLoadingList', false)
          .having((SpeciesPickerState state) => state.isLoadingDetails, 'isLoadingDetails', false)
          .having((SpeciesPickerState state) => state.speciesIds, 'speciesIds', <String>['human'])
          .having((SpeciesPickerState state) => state.selectedSpeciesId, 'selectedSpeciesId', 'human')
          .having((SpeciesPickerState state) => state.selectedSpecies?.id, 'selectedSpecies.id', 'human')
          .having((SpeciesPickerState state) => state.selectedTraits.length, 'traits count', 1)
          .having((SpeciesPickerState state) => state.failure, 'failure', isNull),
    ],
    verify: (_) {
      verify(() => catalog.listSpecies()).called(1);
      verify(() => catalog.getSpecies('human')).called(1);
      verify(() => catalog.getTrait('trait-1')).called(1);
      verifyNever(() => logger.error(any(), error: any(named: 'error'), stackTrace: any(named: 'stackTrace')));
    },
  );

  blocTest<SpeciesPickerBloc, SpeciesPickerState>(
    'met à jour la sélection en réutilisant le cache quand disponible',
    build: () {
      when(() => catalog.listSpecies()).thenAnswer(
        (_) async => <String>['human', 'bothan'],
      );
      when(() => catalog.getSpecies('human')).thenAnswer(
        (_) async => buildSpecies(id: 'human'),
      );
      when(() => catalog.getSpecies('bothan')).thenAnswer(
        (_) async => buildSpecies(id: 'bothan', traitIds: <String>['trait-1']),
      );
      when(() => catalog.getTrait('trait-1')).thenAnswer(
        (_) async => buildTrait('trait-1'),
      );
      return SpeciesPickerBloc(catalog: catalog, logger: logger);
    },
    act: (SpeciesPickerBloc bloc) async {
      bloc.add(const SpeciesPickerStarted(initialSpeciesId: 'human'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const SpeciesPickerSpeciesRequested('bothan'));
    },
    expect: () => <Matcher>[
      isA<SpeciesPickerState>().having((SpeciesPickerState state) => state.isLoadingList, 'isLoadingList', true),
      isA<SpeciesPickerState>()
          .having((SpeciesPickerState state) => state.selectedSpeciesId, 'selectedSpeciesId', 'human')
          .having((SpeciesPickerState state) => state.isLoadingDetails, 'isLoadingDetails', false),
      isA<SpeciesPickerState>()
          .having((SpeciesPickerState state) => state.selectedSpeciesId, 'selectedSpeciesId', 'bothan')
          .having((SpeciesPickerState state) => state.isLoadingDetails, 'isLoadingDetails', true),
      isA<SpeciesPickerState>()
          .having((SpeciesPickerState state) => state.selectedSpeciesId, 'selectedSpeciesId', 'bothan')
          .having((SpeciesPickerState state) => state.isLoadingDetails, 'isLoadingDetails', false)
          .having((SpeciesPickerState state) => state.selectedTraits.length, 'traits count', 1),
    ],
    verify: (_) {
      verify(() => catalog.getSpecies('bothan')).called(1);
      verify(() => catalog.getTrait('trait-1')).called(1);
    },
  );

  blocTest<SpeciesPickerBloc, SpeciesPickerState>(
    'publie une erreur et journalise lorsque la liste échoue',
    build: () {
      when(() => catalog.listSpecies()).thenThrow(Exception('boom'));
      return SpeciesPickerBloc(catalog: catalog, logger: logger);
    },
    act: (SpeciesPickerBloc bloc) => bloc.add(const SpeciesPickerStarted()),
    expect: () => <Matcher>[
      isA<SpeciesPickerState>()
          .having((SpeciesPickerState state) => state.isLoadingList, 'isLoadingList', true)
          .having((SpeciesPickerState state) => state.isLoadingDetails, 'isLoadingDetails', true),
      isA<SpeciesPickerState>()
          .having((SpeciesPickerState state) => state.isLoadingList, 'isLoadingList', false)
          .having((SpeciesPickerState state) => state.isLoadingDetails, 'isLoadingDetails', false)
          .having((SpeciesPickerState state) => state.failure?.code, 'failureCode',
              'SpeciesListLoadFailed')
          .having(
            (SpeciesPickerState state) => state.errorMessage,
            'errorMessage',
            'SpeciesListLoadFailed — Échec du chargement des espèces : Exception: boom',
          ),
    ],
    verify: (_) {
      verify(
        () => logger.error(
          any(),
          error: any(named: 'error'),
          stackTrace: any(named: 'stackTrace'),
          payload: any(named: 'payload'),
        ),
      ).called(1);
    },
  );
}
