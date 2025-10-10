/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/finalize_level1_character.dart
/// Rôle : Définir le contrat de finalisation d'un personnage niveau 1.
/// Dépendances : DTO `FinalizeLevel1Input`, entité `Character`, `AppResult`.
/// Exemple d'usage :
///   final result = await useCase(input);
/// ---------------------------------------------------------------------------
library;
import 'package:meta/meta.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/domain/characters/value_objects/background_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_name.dart';
import 'package:sw5e_manager/domain/characters/value_objects/class_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/equipment_item_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/quantity.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';

/// Input DTO pour finaliser un personnage niveau 1 (MVP).
@immutable
class FinalizeLevel1Input {
  final CharacterName name;
  final SpeciesId speciesId;
  final ClassId classId;
  final BackgroundId backgroundId;

  /// Scores de base AVANT application des bonus espèce/background.
  /// Clés attendues: 'str','dex','con','int','wis','cha'
  final Map<String, AbilityScore> baseAbilities;

  /// Compétences choisies (slugs) parmi les listes autorisées.
  final Set<String> chosenSkills;

  /// Équipement choisi (en plus/à la place du pack de départ selon règles).
  final List<ChosenEquipmentLine> chosenEquipment;
  final bool useStartingEquipmentPackage;

  const FinalizeLevel1Input({
    required this.name,
    required this.speciesId,
    required this.classId,
    required this.backgroundId,
    required this.baseAbilities,
    required this.chosenSkills,
    required this.chosenEquipment,
    this.useStartingEquipmentPackage = true,
  });
}

@immutable
class ChosenEquipmentLine {
  final EquipmentItemId itemId;
  final Quantity quantity;
  const ChosenEquipmentLine({required this.itemId, required this.quantity});
}

/// FinalizeLevel1Character = use case validant les choix du joueur et produisant un personnage complet.
///
/// * Pré-condition : l'entrée doit respecter les VO associés (validée à la construction).
/// * Post-condition : retourne un [AppResult] contenant le personnage final prêt à être persistant.
/// * Erreurs : `DomainError` décrivant la règle violée.
abstract class FinalizeLevel1Character {
  Future<AppResult<Character>> call(FinalizeLevel1Input input);
}
