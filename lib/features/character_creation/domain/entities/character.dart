// lib/features/character_creation/domain/entities/character.dart
import 'package:meta/meta.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/ability_score.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/background_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_name.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_trait.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/class_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/credits.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/defense.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/encumbrance.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/equipment_item_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/hit_points.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/initiative.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/level.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/maneuvers_known.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/proficiency_bonus.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/quantity.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/skill_proficiency.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/species_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/superiority_dice.dart';

/// Entité domaine - Personnage niveau 1 (MVP) avec Value Objects.
@immutable
class Character {
  // Identité & choix structurels
  final CharacterName name;
  final SpeciesId speciesId;
  final ClassId classId;
  final BackgroundId backgroundId;

  // Niveau (MVP = 1)
  final Level level;

  /// Abilities finales (après bonus espèce/background)
  /// Clés attendues: 'str','dex','con','int','wis','cha'
  final Map<String, AbilityScore> abilities;

  /// Compétences maîtrisées (V.O. avec sources/état)
  final Set<SkillProficiency> skills;

  // Dérivés
  final ProficiencyBonus proficiencyBonus;
  final HitPoints hitPoints;
  final Defense defense;
  final Initiative initiative;

  // Économie & inventaire
  final Credits credits;
  final List<InventoryLine> inventory;
  final Encumbrance encumbrance;

  // Manœuvres (si classe applicable)
  final ManeuversKnown maneuversKnown;
  final SuperiorityDice superiorityDice;

  // Traits natifs issus de l'espèce (ex: bothan → nimble-escape, shrewd)
  final Set<CharacterTrait> speciesTraits;

  Character({
    required this.name,
    required this.speciesId,
    required this.classId,
    required this.backgroundId,
    required this.level,
    required this.abilities,
    required this.skills,
    required this.proficiencyBonus,
    required this.hitPoints,
    required this.defense,
    required this.initiative,
    required this.credits,
    required this.inventory,
    required this.encumbrance,
    required this.maneuversKnown,
    required this.superiorityDice,
    this.speciesTraits = const <CharacterTrait>{},
  })  : assert(level.value == 1, 'MVP: level doit être 1'),
        assert(_hasAllSixAbilities(abilities),
            'abilities doit contenir exactement {str,dex,con,int,wis,cha}'),
        // Pas de lignes d’inventaire à quantité nulle dans l’état final
        assert(inventory.every((l) => !l.quantity.isZero),
            'inventory ne doit pas contenir de quantité nulle');

  static bool _hasAllSixAbilities(Map<String, AbilityScore> m) {
    const keys = {'str', 'dex', 'con', 'int', 'wis', 'cha'};
    return m.length == 6 && m.keys.toSet().containsAll(keys);
  }
}

/// Ligne d’inventaire (VO pour l'ID d’objet + VO quantité)
@immutable
class InventoryLine {
  final EquipmentItemId itemId;
  final Quantity quantity;

  const InventoryLine({
    required this.itemId,
    required this.quantity,
  });
}
