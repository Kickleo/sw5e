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
    when(() => catalog.listSpecies())
        .thenAnswer((_) async => <String>['twilek', 'human']);
    when(() => catalog.getSpecies('twilek')).thenAnswer(
      (_) async => const SpeciesDef(
        id: 'twilek',
        name: LocalizedText(en: 'Twi\'lek', fr: 'Twi\'lek'),
        speed: 30,
        size: 'medium',
      ),
    );
    when(() => catalog.getSpecies('human')).thenAnswer(
      (_) async => const SpeciesDef(
        id: 'human',
        name: LocalizedText(en: 'Human', fr: 'Humain'),
        speed: 30,
        size: 'medium',
      ),
    );

    when(() => catalog.listClasses()).thenAnswer((_) async => <String>['sentinel']);
    when(() => catalog.getClass('sentinel')).thenAnswer(
      (_) async => const ClassDef(
        id: 'sentinel',
        name: LocalizedText(en: 'Sentinel', fr: 'Sentinelle'),
        hitDie: 10,
        level1: ClassLevel1Data(
          proficiencies: ClassLevel1Proficiencies(skillsChoose: 2, skillsFrom: <String>['acrobatics']),
          startingEquipment: <StartingEquipmentLine>[],
        ),
      ),
    );

    when(() => catalog.listBackgrounds()).thenAnswer((_) async => <String>['scoundrel']);
    when(() => catalog.getBackground('scoundrel')).thenAnswer(
      (_) async => const BackgroundDef(
        id: 'scoundrel',
        name: LocalizedText(en: 'Scoundrel', fr: 'Canaille'),
        grantedSkills: <String>[],
      ),
    );
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
    when(() => catalog.listAbilities())
        .thenAnswer((_) async => const <String>['str', 'dex', 'wis']);
    when(() => catalog.getAbility('str')).thenAnswer(
      (_) async => const AbilityDef(
        id: 'str',
        abbreviation: 'STR',
        name: LocalizedText(en: 'Strength', fr: 'Force'),
      ),
    );
    when(() => catalog.getAbility('dex')).thenAnswer(
      (_) async => const AbilityDef(
        id: 'dex',
        abbreviation: 'DEX',
        name: LocalizedText(en: 'Dexterity', fr: 'Dextérité'),
      ),
    );
    when(() => catalog.getAbility('wis')).thenAnswer(
      (_) async => const AbilityDef(
        id: 'wis',
        abbreviation: 'WIS',
        name: LocalizedText(en: 'Wisdom', fr: 'Sagesse'),
      ),
    );
    when(() => catalog.listLanguages())
        .thenAnswer((_) async => const <String>['basic']);
    when(() => catalog.getLanguage('basic')).thenAnswer(
      (_) async => const LanguageDef(
        id: 'basic',
        name: LocalizedText(en: 'Galactic Basic', fr: 'Basic galactique'),
      ),
    );

    final AppResult<QuickCreateCatalogSnapshot> result = await useCase();

    expect(result.isOk, isTrue);
    result.match(
      ok: (QuickCreateCatalogSnapshot snapshot) {
        expect(snapshot.speciesIds, equals(const <String>['human', 'twilek']));
        expect(snapshot.classIds, equals(const <String>['sentinel']));
        expect(snapshot.backgroundIds, equals(const <String>['scoundrel']));
        expect(snapshot.defaultSpeciesId, 'human');
        expect(snapshot.sortedEquipmentIds, equals(const <String>['armor', 'blaster']));
        expect(snapshot.equipmentById['armor']?.name.fr, 'Armure');
        expect(snapshot.speciesNames['human']?.fr, 'Humain');
        expect(snapshot.classNames['sentinel']?.en, 'Sentinel');
        expect(snapshot.backgroundNames['scoundrel']?.en, 'Scoundrel');
        expect(
          snapshot.abilityDefinitions.keys,
          containsAll(<String>['dex', 'str', 'wis']),
        );
        expect(snapshot.abilityDefinitions['str']?.name.fr, 'Force');
        expect(snapshot.languageDefinitions.keys, contains('basic'));
      },
      err: (_) => fail('Le snapshot aurait dû être un succès'),
    );
  });

  test('trie les espèces par libellé puis par slug lorsque les traductions manquent',
      () async {
    when(() => catalog.listSpecies())
        .thenAnswer((_) async => <String>['zabrak', 'aqualish']);
    when(() => catalog.getSpecies('zabrak')).thenAnswer(
      (_) async => const SpeciesDef(
        id: 'zabrak',
        name: LocalizedText(),
        speed: 30,
        size: 'medium',
      ),
    );
    when(() => catalog.getSpecies('aqualish')).thenAnswer(
      (_) async => const SpeciesDef(
        id: 'aqualish',
        name: LocalizedText(),
        speed: 30,
        size: 'medium',
      ),
    );
    when(() => catalog.listClasses())
        .thenAnswer((_) async => const <String>[]);
    when(() => catalog.listBackgrounds())
        .thenAnswer((_) async => const <String>[]);
    when(() => catalog.listEquipment())
        .thenAnswer((_) async => const <String>[]);
    when(() => catalog.listAbilities())
        .thenAnswer((_) async => const <String>[]);
    when(() => catalog.listLanguages())
        .thenAnswer((_) async => const <String>[]);

    final AppResult<QuickCreateCatalogSnapshot> result = await useCase();

    expect(result.isOk, isTrue);
    result.match(
      ok: (QuickCreateCatalogSnapshot snapshot) {
        expect(snapshot.speciesIds, equals(const <String>['aqualish', 'zabrak']));
        expect(snapshot.defaultSpeciesId, 'aqualish');
        expect(snapshot.classIds, isEmpty);
        expect(snapshot.backgroundIds, isEmpty);
        expect(snapshot.sortedEquipmentIds, isEmpty);
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
