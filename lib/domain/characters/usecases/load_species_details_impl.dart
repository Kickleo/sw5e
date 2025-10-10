/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/load_species_details_impl.dart
/// Rôle : Implémenter [LoadSpeciesDetails] via le [CatalogRepository].
/// Dépendances : CatalogRepository, AppResult, DomainError.
/// Exemple d'usage :
///   final useCase = LoadSpeciesDetailsImpl(repository);
///   final result = await useCase('human');
/// ---------------------------------------------------------------------------
library;
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';

/// Implémentation standard.
class LoadSpeciesDetailsImpl implements LoadSpeciesDetails {
  /// Crée l'instance.
  const LoadSpeciesDetailsImpl(this._catalog);

  final CatalogRepository _catalog;

  @override
  Future<AppResult<QuickCreateSpeciesDetails>> call(String speciesId) async {
    try {
      final SpeciesDef? species = await _catalog.getSpecies(speciesId);
      if (species == null) {
        return appErr(
          DomainError(
            'UnknownSpecies',
            message: 'Espèce "$speciesId" introuvable dans le catalogue.',
          ),
        );
      }

      final List<TraitDef> traits = <TraitDef>[];
      final List<String> missingTraits = <String>[];
      for (final String traitId in species.traitIds) {
        final TraitDef? trait = await _catalog.getTrait(traitId);
        if (trait == null) {
          missingTraits.add(traitId);
          continue;
        }
        traits.add(trait);
      }

      return appOk(
        QuickCreateSpeciesDetails(
          species: species,
          traits: List<TraitDef>.unmodifiable(traits),
          missingTraitIds: List<String>.unmodifiable(missingTraits),
        ),
      );
    } catch (Object error) {
      return appErr(
        DomainError(
          'SpeciesLoadFailed',
          message: error.toString(),
          details: {'speciesId': speciesId},
        ),
      );
    }
  }
}
