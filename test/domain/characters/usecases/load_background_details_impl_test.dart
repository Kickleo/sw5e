import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_background_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_background_details_impl.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late CatalogRepository catalog;
  late LoadBackgroundDetails useCase;

  setUp(() {
    catalog = _MockCatalogRepository();
    useCase = LoadBackgroundDetailsImpl(catalog);
  });

  test('returns background details with resolved skills and equipment', () async {
    when(() => catalog.getBackground('outlaw')).thenAnswer(
      (_) async => const BackgroundDef(
        id: 'outlaw',
        name: LocalizedText(en: 'Outlaw'),
        grantedSkills: <String>['stealth'],
        toolProficiencies: <String>['disguise-kit'],
        equipment: <BackgroundEquipmentGrant>[
          BackgroundEquipmentGrant(itemId: 'comlink', refType: 'gear', quantity: 1),
        ],
      ),
    );

    when(() => catalog.getSkill('stealth')).thenAnswer(
      (_) async => const SkillDef(
        id: 'stealth',
        ability: 'dex',
        name: LocalizedText(en: 'Stealth'),
      ),
    );

    when(() => catalog.getEquipment('comlink')).thenAnswer(
      (_) async => const EquipmentDef(
        id: 'comlink',
        name: LocalizedText(en: 'Comlink'),
        type: 'gear',
        weightG: 100,
        cost: 25,
      ),
    );

    when(() => catalog.getEquipment('disguise-kit')).thenAnswer(
      (_) async => const EquipmentDef(
        id: 'disguise-kit',
        name: LocalizedText(en: 'Disguise Kit'),
        type: 'tool',
        weightG: 500,
        cost: 20,
      ),
    );

    final AppResult<QuickCreateBackgroundDetails> result = await useCase('outlaw');

    expect(result.isOk, isTrue);
    final QuickCreateBackgroundDetails details = result.okOrThrow();
    expect(details.background.id, 'outlaw');
    expect(details.skillDefinitions.containsKey('stealth'), isTrue);
    expect(details.equipmentDefinitions.containsKey('comlink'), isTrue);
    expect(details.equipmentDefinitions.containsKey('disguise-kit'), isTrue);
    expect(details.missingToolIds, isEmpty);
  });

  test('returns error when background is unknown', () async {
    when(() => catalog.getBackground('unknown')).thenAnswer((_) async => null);

    final AppResult<QuickCreateBackgroundDetails> result = await useCase('unknown');

    expect(result.isErr, isTrue);
    final DomainError error = result.errOrThrow();
    expect(error.code, 'UnknownBackground');
  });
}
