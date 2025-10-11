/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/load_quick_create_catalog.dart
/// Rôle : Définir le contrat permettant de charger le snapshot de catalogue
///        nécessaire à l'assistant de création rapide.
/// Dépendances : AppResult (alias de Result), CatalogRepository, entités de
///        catalogue exposées au domaine.
/// Exemple d'usage :
///   final snapshot = await loadQuickCreateCatalog();
///   snapshot.match(ok: (value) => value.speciesIds, err: (error) => ...);
/// ---------------------------------------------------------------------------
library;
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// QuickCreateCatalogSnapshot = structure immuable regroupant les listes et
/// définitions nécessaires pour initialiser le wizard côté présentation.
class QuickCreateCatalogSnapshot {
  /// Crée une instance.
  const QuickCreateCatalogSnapshot({
    required this.speciesIds,
    required this.classIds,
    required this.backgroundIds,
    required this.equipmentById,
    required this.sortedEquipmentIds,
    this.defaultSpeciesId,
    this.defaultClassId,
    this.defaultBackgroundId,
  });

  /// Identifiants d'espèces disponibles.
  final List<String> speciesIds;

  /// Identifiants de classes disponibles.
  final List<String> classIds;

  /// Identifiants de backgrounds disponibles.
  final List<String> backgroundIds;

  /// Map des équipements (clé = slug) pour affichage/validation.
  final Map<String, EquipmentDef> equipmentById;

  /// Ordre déjà trié des équipements pour l'affichage UI.
  final List<String> sortedEquipmentIds;

  /// Sélection par défaut suggérée pour l'espèce.
  final String? defaultSpeciesId;

  /// Sélection par défaut suggérée pour la classe.
  final String? defaultClassId;

  /// Sélection par défaut suggérée pour le background.
  final String? defaultBackgroundId;
}

/// LoadQuickCreateCatalog = use case qui fournit les listes de base pour
/// l'assistant de création rapide.
abstract class LoadQuickCreateCatalog {
  /// Exécute le chargement.
  ///
  /// Pré-condition : le catalogue hors-ligne est disponible.
  /// Post-condition : les listes sont triées et prêtes pour l'UI.
  /// Erreurs : [DomainError] `CatalogLoadFailed` en cas d'échec d'E/S.
  Future<AppResult<QuickCreateCatalogSnapshot>> call();
}
