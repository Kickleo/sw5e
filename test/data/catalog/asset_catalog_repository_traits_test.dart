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
    expect(ids, containsAll(<String>['shrewd', 'nimble-escape']));

    final shrewd = await repo.getTrait('shrewd');
    expect(shrewd, isA<TraitDef>());
    expect(shrewd!.name.fr, 'Perspicace');
    expect(shrewd.description.en, contains('Insight'));

    final nimble = await repo.getTrait('nimble-escape');
    expect(nimble, isNotNull);
    expect(nimble!.description.en.toLowerCase(), contains('bonus action'));
    expect(nimble.description.fr, contains("action Se désengager"));

    final darkvision = await repo.getTrait('darkvision');
    expect(darkvision, isNotNull);
    expect(darkvision!.description.fr, startsWith('Votre vision perce'));
  });
}
