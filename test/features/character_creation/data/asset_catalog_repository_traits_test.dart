import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/features/character_creation/data/repositories/asset_catalog_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('lit traits.json et expose getTrait/listTraits', () async {
    final repo = AssetCatalogRepository();

    final ids = await repo.listTraits();
    expect(ids, containsAll(<String>['shrewd', 'nimble-escape']));

    final shrewd = await repo.getTrait('shrewd');
    expect(shrewd, isA<TraitDef>());
    expect(shrewd!.name.fr, 'Perspicace');
    expect(shrewd.description, contains('Insight'));

    final nimble = await repo.getTrait('nimble-escape');
    expect(nimble, isNotNull);
    expect(nimble!.description.toLowerCase(), contains('bonus action'));
  });
}
