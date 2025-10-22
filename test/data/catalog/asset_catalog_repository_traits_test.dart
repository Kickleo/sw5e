/// ---------------------------------------------------------------------------
/// Fichier : test/data/catalog/asset_catalog_repository_traits_test.dart
/// Rôle : Garantir que les traits sont exposés par l'adapter AssetCatalogRepository.
/// Dépendances : `flutter_test` + definitions domaine pour valider les types.
/// Exemple d'usage : `flutter test test/data/catalog/asset_catalog_repository_traits_test.dart`.
/// ---------------------------------------------------------------------------
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/data/catalog/repositories/asset_catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('lit traits.json et expose getTrait/listTraits', () async {
    final repo = AssetCatalogRepository();

    final ids = await repo.listTraits();
    expect(
      ids,
      containsAll(<String>[
        'lekku-communication',
        'charismatic-presence',
        'twilek-darkvision',
      ]),
    );

    final lekku = await repo.getTrait('lekku-communication');
    expect(lekku, isA<TraitDef>());
    expect(lekku!.description.en, contains('Lekku convey complex ideas'));
    expect(lekku.description.fr, contains('mouvements rythmiques'));

    final presence = await repo.getTrait('charismatic-presence');
    expect(presence, isNotNull);
    expect(presence!.name.fr, 'Présence charismatique');
    expect(presence.description.en, contains('bend conversations'));

    final darkvision = await repo.getTrait('twilek-darkvision');
    expect(darkvision, isNotNull);
    expect(darkvision!.description.fr,
        startsWith('Des générations passées sous les soleils'));
  });
}
