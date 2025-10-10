/// ---------------------------------------------------------------------------
/// Fichier test : load_quick_create_catalog_impl_test.dart
/// Rôle : Vérifier que LoadQuickCreateCatalogImpl agrège et trie les données
///        issues du CatalogRepository et gère les erreurs.
/// ---------------------------------------------------------------------------
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_quick_create_catalog.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_quick_create_catalog_impl.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late _MockCatalogRepository catalog;
  late LoadQuickCreateCatalogImpl useCase;

  setUp(() {
    catalog = _MockCatalogRepository();
    useCase = LoadQuickCreateCatalogImpl(catalog);
  });

  test('retourne un snapshot trié avec valeurs par défaut', () async {
    when(() => catalog.listSpecies()).thenAnswer((_) async => <String>['twilek', 'human']);
    when(() => catalog.listClasses()).thenAnswer((_) async => <String>['sentinel']);
    when(() => catalog.listBackgrounds()).thenAnswer((_) async => <String>['scoundrel']);
    when(() => catalog.listEquipment()).thenAnswer((_) async => <String>['blaster', 'armor']);
    when(() => catalog.getEquipment('blaster')).thenAnswer(
      (_) async => const EquipmentDef(
        id: 'blaster',
        name: LocalizedText(en: 'Blaster', fr: 'Blaster'),
        type: 'weapon',
        weightG: 900,
        cost: 400,
      ),
    );
    when(() => catalog.getEquipment('armor')).thenAnswer(
      (_) async => const EquipmentDef(
        id: 'armor',
        name: LocalizedText(en: 'Armor', fr: 'Armure'),
        type: 'armor',
        weightG: 8000,
        cost: 500,
      ),
    );

    final AppResult<QuickCreateCatalogSnapshot> result = await useCase();

    expect(result.isOk, isTrue);
    result.match(
      ok: (QuickCreateCatalogSnapshot snapshot) {
        expect(snapshot.speciesIds.first, 'twilek');
        expect(snapshot.classIds, equals(const <String>['sentinel']));
        expect(snapshot.backgroundIds, equals(const <String>['scoundrel']));
        expect(snapshot.defaultSpeciesId, 'twilek');
        expect(snapshot.sortedEquipmentIds, equals(const <String>['armor', 'blaster']));
        expect(snapshot.equipmentById['armor']?.name.fr, 'Armure');
      },
      err: (_) => fail('Le snapshot aurait dû être un succès'),
    );
  });

  test('retourne DomainError CatalogLoadFailed sur exception', () async {
    when(() => catalog.listSpecies()).thenThrow(Exception('boom'));

    final AppResult<QuickCreateCatalogSnapshot> result = await useCase();

    expect(result.isErr, isTrue);
    result.match(
      ok: (_) => fail('Devrait être en erreur'),
      err: (DomainError error) {
        expect(error.code, 'CatalogLoadFailed');
      },
    );
  });
}
