/// ---------------------------------------------------------------------------
/// Fichier test : load_class_details_impl_test.dart
/// Rôle : Vérifier que LoadClassDetailsImpl trie les compétences et gère les
///        erreurs de catalogue.
/// ---------------------------------------------------------------------------
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_class_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_class_details_impl.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late _MockCatalogRepository catalog;
  late LoadClassDetailsImpl useCase;

  setUp(() {
    catalog = _MockCatalogRepository();
    useCase = LoadClassDetailsImpl(catalog);
  });

  test('retourne les compétences triées et les définitions disponibles', () async {
    when(() => catalog.getClass('guardian')).thenAnswer(
      (_) async => const ClassDef(
        id: 'guardian',
        name: LocalizedText(en: 'Guardian', fr: 'Gardien'),
        hitDie: 10,
        level1: ClassLevel1Data(
          proficiencies: ClassLevel1Proficiencies(
            skillsChoose: 2,
            skillsFrom: <String>['athletics', 'acrobatics'],
          ),
          startingEquipment: <StartingEquipmentLine>[],
        ),
      ),
    );
    when(() => catalog.getSkill('athletics')).thenAnswer(
      (_) async => const SkillDef(
        id: 'athletics',
        ability: 'str',
        name: LocalizedText(en: 'Athletics', fr: 'Athlétisme'),
      ),
    );
    when(() => catalog.getSkill('acrobatics')).thenAnswer((_) async => null);

    final AppResult<QuickCreateClassDetails> result = await useCase('guardian');

    expect(result.isOk, isTrue);
    result.match(
      ok: (QuickCreateClassDetails details) {
        expect(details.availableSkillIds, equals(const <String>['acrobatics', 'athletics']));
        expect(details.skillDefinitions.containsKey('athletics'), isTrue);
        expect(details.missingSkillIds, equals(const <String>['acrobatics']));
        expect(details.skillChoicesRequired, 2);
      },
      err: (_) => fail('Devrait retourner un succès'),
    );
  });

  test('retourne UnknownClass si la classe est absente', () async {
    when(() => catalog.getClass('unknown')).thenAnswer((_) async => null);

    final AppResult<QuickCreateClassDetails> result = await useCase('unknown');

    expect(result.isErr, isTrue);
    result.match(
      ok: (_) => fail('Devrait être une erreur'),
      err: (DomainError error) {
        expect(error.code, 'UnknownClass');
      },
    );
  });
}
