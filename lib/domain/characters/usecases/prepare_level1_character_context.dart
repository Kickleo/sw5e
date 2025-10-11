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
///
/// Cette structure sert de "snapshot" des informations catalogue au moment où
/// l'utilisateur finalise son personnage. Elle permet de transmettre un bloc
/// cohérent de données à l'étape d'assemblage sans qu'elle ait à recharger les
/// ressources — évitant ainsi les requêtes redondantes et conservant un état
/// stable même si le catalogue change pendant le processus.
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
///
/// En pratique, ce use case agit comme une étape de validation : il vérifie la
/// présence de chaque ressource (espèce, classe, background) avant de passer à
/// l'étape d'assemblage. Cela isole la logique de remontée des erreurs liées au
/// catalogue et permet à d'autres orchestrations futures de réutiliser cette
/// préparation sans dupliquer le code de vérification.
abstract class PrepareLevel1CharacterContext {
  Future<AppResult<Level1CharacterContext>> call(FinalizeLevel1Input input);
}
