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
    required this.speciesNames,
    required this.classIds,
    required this.classNames,
    required this.backgroundIds,
    required this.backgroundNames,
    required this.equipmentById,
    required this.sortedEquipmentIds,
    required this.abilityDefinitions,
    required this.languageDefinitions,
    required this.customizationOptionDefinitions,
    required this.forcePowerDefinitions,
    required this.techPowerDefinitions,
    this.defaultSpeciesId,
    this.defaultClassId,
    this.defaultBackgroundId,
  });

  /// Identifiants d'espèces disponibles.
  final List<String> speciesIds;

  /// Libellés localisés associés aux espèces (clé = identifiant).
  final Map<String, LocalizedText> speciesNames;

  /// Identifiants de classes disponibles.
  final List<String> classIds;

  /// Libellés localisés associés aux classes (clé = identifiant).
  final Map<String, LocalizedText> classNames;

  /// Identifiants de backgrounds disponibles.
  final List<String> backgroundIds;

  /// Libellés localisés associés aux backgrounds (clé = identifiant).
  final Map<String, LocalizedText> backgroundNames;

  /// Map des équipements (clé = slug) pour affichage/validation.
  final Map<String, EquipmentDef> equipmentById;

  /// Ordre déjà trié des équipements pour l'affichage UI.
  final List<String> sortedEquipmentIds;

  /// Définitions des caractéristiques disponibles (clé = slug).
  final Map<String, AbilityDef> abilityDefinitions;

  /// Définitions des langues disponibles (clé = slug).
  final Map<String, LanguageDef> languageDefinitions;

  /// Définitions complètes des options de personnalisation disponibles.
  final Map<String, CustomizationOptionDef> customizationOptionDefinitions;

  /// Définitions complètes des pouvoirs de la Force disponibles.
  final Map<String, PowerDef> forcePowerDefinitions;

  /// Définitions complètes des pouvoirs technologiques disponibles.
  final Map<String, PowerDef> techPowerDefinitions;

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
