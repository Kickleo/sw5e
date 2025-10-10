/// ---------------------------------------------------------------------------
/// Fichier : test/data/catalog/asset_catalog_repository_test.dart
/// Rôle : Vérifier que l'adapter AssetCatalogRepository lit correctement les assets
///        JSON et hydrate les entités domaine attendues.
/// Dépendances : `flutter_test` pour l'environnement widget/AssetBundle.
/// Exemple d'usage : lancer `flutter test` pour garantir le comportement.
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/data/catalog/repositories/asset_catalog_repository.dart';

void main() {
  // Nécessaire pour accéder à rootBundle dans les tests
  TestWidgetsFlutterBinding.ensureInitialized();

  test('charge le catalogue depuis assets/catalog/*', () async {
    final repo = AssetCatalogRepository();

    // Skills
    final skills = await repo.listSkills();
    expect(skills, containsAll(<String>['perception', 'athletics', 'stealth', 'deception']));

    // Species
    final human = await repo.getSpecies('human');
    expect(human, isNotNull);
    expect(human!.speed, 30);
    expect(human.size, 'medium');

    // Class
    final guardian = await repo.getClass('guardian');
    expect(guardian, isNotNull);
    expect(guardian!.hitDie, 10);
    expect(guardian.level1.startingEquipment.first.id, 'blaster-pistol');

    // Equipment
    final blaster = await repo.getEquipment('blaster-pistol');
    expect(blaster, isNotNull);
    expect(blaster!.weightG, 1134);

    // Background
    final outlaw = await repo.getBackground('outlaw');
    expect(outlaw, isNotNull);
    expect(outlaw!.grantedSkills, containsAll(['stealth', 'deception']));

    // Formulas
    final formulas = await repo.getFormulas();
    expect(formulas.rulesVersion, '2025-10-06');
    expect(formulas.superiorityDiceByClass['guardian']!.count, 0);
  });
}
