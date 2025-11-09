/// ---------------------------------------------------------------------------
/// Fichier test : load_species_details_impl_test.dart
/// Rôle : Vérifier la résolution des traits et la gestion des erreurs pour
///        LoadSpeciesDetailsImpl.
/// ---------------------------------------------------------------------------
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details_impl.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late _MockCatalogRepository catalog;
  late LoadSpeciesDetailsImpl useCase;

  setUp(() {
    catalog = _MockCatalogRepository();
    useCase = LoadSpeciesDetailsImpl(catalog);
  });

  test('retourne les traits disponibles et liste les manquants', () async {
    when(() => catalog.getSpecies('bothan')).thenAnswer(
      (_) async => const SpeciesDef(
        id: 'bothan',
        name: LocalizedText(en: 'Bothan', fr: 'Bothan'),
        speed: 30,
        size: 'medium',
        traitIds: <String>['keen-smell', 'missing'],
        languageIds: <String>['basic', 'shyriiwook'],
      ),
    );
    when(() => catalog.getTrait('keen-smell')).thenAnswer(
      (_) async => const TraitDef(
        id: 'keen-smell',
        name: LocalizedText(en: 'Keen Smell', fr: 'Odorat affûté'),
        description: LocalizedText(
          en: 'Advantage on Perception checks that rely on smell.',
          fr: 'Avantage sur les tests de Perception faisant appel à l\'odorat.',
        ),
      ),
    );
    when(() => catalog.getTrait('missing')).thenAnswer((_) async => null);
    when(() => catalog.getLanguage('basic')).thenAnswer(
      (_) async => const LanguageDef(
        id: 'basic',
        name: LocalizedText(en: 'Galactic Basic', fr: 'Basic galactique'),
        description: LocalizedText(
          en: 'Spoken across the galaxy.',
          fr: 'Parlé à travers la galaxie.',
        ),
      ),
    );
    when(() => catalog.getLanguage('shyriiwook'))
        .thenAnswer((_) async => null);

    final AppResult<QuickCreateSpeciesDetails> result = await useCase('bothan');

    expect(result.isOk, isTrue);
    result.match(
      ok: (QuickCreateSpeciesDetails details) {
        expect(details.traits, hasLength(1));
        expect(details.traits.first.id, 'keen-smell');
        expect(details.missingTraitIds, equals(const <String>['missing']));
        expect(details.languages, hasLength(1));
        expect(details.languages.first.id, 'basic');
      },
      err: (_) => fail('Devrait retourner un succès'),
    );
  });

  test('retourne UnknownSpecies si l’identifiant est invalide', () async {
    when(() => catalog.getSpecies('unknown')).thenAnswer((_) async => null);

    final AppResult<QuickCreateSpeciesDetails> result = await useCase('unknown');

    expect(result.isErr, isTrue);
    result.match(
      ok: (_) => fail('Devrait être une erreur'),
      err: (DomainError error) {
        expect(error.code, 'UnknownSpecies');
      },
    );
  });
}
