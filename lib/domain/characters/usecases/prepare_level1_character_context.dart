/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/prepare_level1_character_context.dart
/// Rôle : Définir le contrat et les données de contexte pour préparer
///        l'assemblage d'un personnage niveau 1.
/// Dépendances : AppResult, DTO de finalisation, définitions de catalogue.
/// Exemple d'usage :
///   final ctxResult = await prepareContextUseCase(input);
/// ---------------------------------------------------------------------------
library;

import 'package:meta/meta.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/finalize_level1_character.dart';

/// Regroupe toutes les données immuables nécessaires pour construire un
/// personnage niveau 1 : définitions d'espèce, classe, background et formules.
@immutable
class Level1CharacterContext {
  final SpeciesDef species; // Définition d'espèce validée.
  final ClassDef clazz; // Classe choisie par l'utilisateur.
  final BackgroundDef background; // Historique sélectionné.
  final FormulasDef formulas; // Tables et règles dérivées.

  const Level1CharacterContext({
    required this.species,
    required this.clazz,
    required this.background,
    required this.formulas,
  });
}

/// Prépare le contexte nécessaire à l'assemblage d'un personnage.
///
/// * Pré-condition : les identifiants fournis dans [FinalizeLevel1Input] doivent
///   être valides du point de vue des Value Objects.
/// * Post-condition : retourne un contexte complet si toutes les entrées sont
///   trouvées dans le catalogue ; sinon, une erreur descriptive.
abstract class PrepareLevel1CharacterContext {
  Future<AppResult<Level1CharacterContext>> call(FinalizeLevel1Input input);
}
