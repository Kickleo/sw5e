/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/prepare_level1_character_context_impl.dart
/// Rôle : Implémenter la récupération séquentielle des ressources catalogue
///        nécessaires à la création d'un personnage niveau 1.
/// Dépendances : CatalogRepository, AppResult.
/// Exemple d'usage :
///   final ctxResult = await PrepareLevel1CharacterContextImpl(catalog)(input);
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/domain/characters/usecases/prepare_level1_character_context.dart';

/// Implémentation concrète qui charge espèce, classe, background et formules.
///
/// L'objectif est double :
/// 1. Vérifier l'existence de chaque ressource mentionnée dans l'input.
/// 2. Constituer un [Level1CharacterContext] auto-suffisant que l'étape
///    d'assemblage pourra consommer sans dépendre du repository.
///
/// Toute absence de ressource est remontée sous la forme d'un `DomainError`
/// spécialisé (`UnknownCatalogId`) afin de fournir un retour précis à l'UI.
class PrepareLevel1CharacterContextImpl
    implements PrepareLevel1CharacterContext {
  final CatalogRepository catalog; // Source unique de vérité pour le catalogue.

  const PrepareLevel1CharacterContextImpl({required this.catalog});

  @override
  Future<AppResult<Level1CharacterContext>> call(
      FinalizeLevel1Input input) async {
    try {
      // 1) Vérifier et récupérer la définition d'espèce demandée.
      final species = await catalog.getSpecies(input.speciesId.value);
      if (species == null) {
        return appErr(DomainError(
          'UnknownCatalogId',
          message: 'speciesId inconnu',
          details: {'id': input.speciesId.value},
        ));
      }

      // 2) Charger la classe choisie par l'utilisateur.
      final clazz = await catalog.getClass(input.classId.value);
      if (clazz == null) {
        return appErr(DomainError(
          'UnknownCatalogId',
          message: 'classId inconnu',
          details: {'id': input.classId.value},
        ));
      }

      // 3) Récupérer le background (historique) associé pour les compétences.
      final background = await catalog.getBackground(input.backgroundId.value);
      if (background == null) {
        return appErr(DomainError(
          'UnknownCatalogId',
          message: 'backgroundId inconnu',
          details: {'id': input.backgroundId.value},
        ));
      }

      // 4) Charger les formules globales (dés de supériorité, etc.).
      final formulas = await catalog.getFormulas();

      // 5) Agréger toutes les ressources validées dans un contexte immuable.
      return appOk(Level1CharacterContext(
        species: species,
        clazz: clazz,
        background: background,
        formulas: formulas,
      ));
    } catch (e) {
      return appErr(DomainError('Unexpected', message: e.toString()));
    }
  }
}
