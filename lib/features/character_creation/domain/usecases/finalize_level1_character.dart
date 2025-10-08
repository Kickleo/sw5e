// lib/features/character_creation/domain/usecases/finalize_level1_character.dart
import 'package:meta/meta.dart';
import 'package:sw5e_manager/core/domain/result.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/ability_score.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/background_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_name.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/class_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/equipment_item_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/quantity.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/species_id.dart';

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

  const FinalizeLevel1Input({
    required this.name,
    required this.speciesId,
    required this.classId,
    required this.backgroundId,
    required this.baseAbilities,
    required this.chosenSkills,
    required this.chosenEquipment,
  });
}

@immutable
class ChosenEquipmentLine {
  final EquipmentItemId itemId;
  final Quantity quantity;
  const ChosenEquipmentLine({required this.itemId, required this.quantity});
}

/// Use case (port) : valide les choix et produit un Character prêt à jouer.
abstract class FinalizeLevel1Character {
  Future<Result<Character>> call(FinalizeLevel1Input input);
}
