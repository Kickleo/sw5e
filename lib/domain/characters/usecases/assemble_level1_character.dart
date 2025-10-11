/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/assemble_level1_character.dart
/// Rôle : Définir le contrat pour assembler un personnage niveau 1 à partir
///        d'un contexte préparé et des choix du joueur.
/// Dépendances : AppResult, DTO de finalisation, contexte préparé.
/// Exemple d'usage :
///   final characterResult = await assembleUseCase(params);
/// ---------------------------------------------------------------------------
library;

import 'package:meta/meta.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/domain/characters/usecases/prepare_level1_character_context.dart';

/// Paramètres transmis à l'use case d'assemblage.
@immutable
class AssembleLevel1CharacterParams {
  final FinalizeLevel1Input input; // Choix du joueur validés.
  final Level1CharacterContext context; // Données catalogue préparées.

  const AssembleLevel1CharacterParams({
    required this.input,
    required this.context,
  });
}

/// Construit un [Character] complet à partir du contexte et des choix.
///
/// * Pré-condition : les Value Objects contenus dans [FinalizeLevel1Input] sont
///   valides (garanti par leur construction).
/// * Post-condition : retourne un personnage prêt à être persistant ou une
///   erreur métier si une règle est violée.
abstract class AssembleLevel1Character {
  Future<AppResult<Character>> call(AssembleLevel1CharacterParams params);
}
