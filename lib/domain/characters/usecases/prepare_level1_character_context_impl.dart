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
class PrepareLevel1CharacterContextImpl
    implements PrepareLevel1CharacterContext {
  final CatalogRepository catalog; // Source unique de vérité pour le catalogue.

  const PrepareLevel1CharacterContextImpl({required this.catalog});

  @override
  Future<AppResult<Level1CharacterContext>> call(
      FinalizeLevel1Input input) async {
    try {
      final species = await catalog.getSpecies(input.speciesId.value);
      if (species == null) {
        return appErr(DomainError(
          'UnknownCatalogId',
          message: 'speciesId inconnu',
          details: {'id': input.speciesId.value},
        ));
      }

      final clazz = await catalog.getClass(input.classId.value);
      if (clazz == null) {
        return appErr(DomainError(
          'UnknownCatalogId',
          message: 'classId inconnu',
          details: {'id': input.classId.value},
        ));
      }

      final background = await catalog.getBackground(input.backgroundId.value);
      if (background == null) {
        return appErr(DomainError(
          'UnknownCatalogId',
          message: 'backgroundId inconnu',
          details: {'id': input.backgroundId.value},
        ));
      }

      final formulas = await catalog.getFormulas();

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
