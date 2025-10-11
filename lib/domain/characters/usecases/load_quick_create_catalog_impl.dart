/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/load_quick_create_catalog_impl.dart
/// Rôle : Implémenter [LoadQuickCreateCatalog] à partir du [CatalogRepository].
/// Dépendances : CatalogRepository (port), Result/DomainError pour la gestion
///        d'erreur, entités de catalogue.
/// Exemple d'usage :
///   final useCase = LoadQuickCreateCatalogImpl(repository);
// ignore: unintended_html_in_doc_comment
///   final AppResult<QuickCreateCatalogSnapshot> result = await useCase();
/// ---------------------------------------------------------------------------
library;
import 'package:collection/collection.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

import 'package:sw5e_manager/domain/characters/usecases/load_quick_create_catalog.dart';

/// Implémentation par défaut utilisant le catalogue hors-ligne.
class LoadQuickCreateCatalogImpl implements LoadQuickCreateCatalog {
  /// Crée l'implémentation.
  LoadQuickCreateCatalogImpl(this._catalog);

  final CatalogRepository _catalog;

  @override
  Future<AppResult<QuickCreateCatalogSnapshot>> call() async {
    try {
      final List<String> species = await _catalog.listSpecies();
      final List<String> classes = await _catalog.listClasses();
      final List<String> backgrounds = await _catalog.listBackgrounds();

      final List<String> equipmentIds = await _catalog.listEquipment();
      final Map<String, EquipmentDef> equipmentById = <String, EquipmentDef>{};
      for (final String id in equipmentIds) {
        final EquipmentDef? def = await _catalog.getEquipment(id);
        if (def != null) {
          equipmentById[id] = def;
        }
      }

      final List<EquipmentDef> sortedEquipment = equipmentById.values.toList()
        ..sort(_compareEquipmentByLocalizedName);
      final List<String> sortedIds =
          sortedEquipment.map((EquipmentDef def) => def.id).toList();

      return appOk(
        QuickCreateCatalogSnapshot(
          speciesIds: List<String>.unmodifiable(species),
          classIds: List<String>.unmodifiable(classes),
          backgroundIds: List<String>.unmodifiable(backgrounds),
          equipmentById: Map<String, EquipmentDef>.unmodifiable(equipmentById),
          sortedEquipmentIds: List<String>.unmodifiable(sortedIds),
          defaultSpeciesId: species.firstOrNull,
          defaultClassId: classes.firstOrNull,
          defaultBackgroundId: backgrounds.firstOrNull,
        ),
      );
    } catch (error, _) {
      return appErr(
        DomainError(
          'CatalogLoadFailed',
          message: error.toString(),
        ),
      );
    }
  }

  int _compareEquipmentByLocalizedName(EquipmentDef a, EquipmentDef b) {
    final String nameA = a.name.fr.toLowerCase();
    final String nameB = b.name.fr.toLowerCase();
    final int cmp = nameA.compareTo(nameB);
    if (cmp != 0) {
      return cmp;
    }
    return a.id.compareTo(b.id);
  }
}
