/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/load_species_details.dart
/// Rôle : Définir le contrat pour récupérer les détails d'une espèce (traits et
///        métadonnées) requis par le wizard.
/// Dépendances : AppResult, CatalogRepository et définitions associées.
/// Exemple d'usage :
///   final details = await loadSpeciesDetails('human');
/// ---------------------------------------------------------------------------
library;
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// QuickCreateSpeciesDetails = valeur renvoyée pour afficher les traits.
class QuickCreateSpeciesDetails {
  /// Crée une instance immuable.
  const QuickCreateSpeciesDetails({
    required this.species,
    required this.traits,
    this.languages = const <LanguageDef>[],
    this.missingTraitIds = const <String>[],
  });

  /// Définition brute de l'espèce.
  final SpeciesDef species;

  /// Traits résolus et prêts à l'affichage.
  final List<TraitDef> traits;

  /// Langues associées à l'espèce, résolues depuis le catalogue v2.
  final List<LanguageDef> languages;

  /// Identifiants de traits absents du catalogue (pour remontée de logs).
  final List<String> missingTraitIds;
}

/// Contrat du use case.
abstract class LoadSpeciesDetails {
  /// Pré-condition : l'identifiant d'espèce provient du catalogue.
  /// Post-condition : les traits sont triés dans l'ordre de déclaration.
  /// Erreurs : `UnknownSpecies` si l'identifiant est introuvable, sinon
  ///           `SpeciesLoadFailed` en cas d'exception inattendue.
  Future<AppResult<QuickCreateSpeciesDetails>> call(String speciesId);
}
