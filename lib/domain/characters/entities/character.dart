/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/entities/character.dart
/// Rôle : Modéliser un personnage de niveau 1 ainsi que son inventaire
///        dans la couche domaine.
/// Dépendances : Value Objects du dossier `value_objects/` et `meta` pour
///        l'annotation d'immutabilité.
/// Exemple d'usage :
///   final character = Character(...);
/// ---------------------------------------------------------------------------
/// ---------------------------------------------------------------------------
library;
import 'package:meta/meta.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/domain/characters/value_objects/background_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_name.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_trait.dart';
import 'package:sw5e_manager/domain/characters/value_objects/class_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/credits.dart';
import 'package:sw5e_manager/domain/characters/value_objects/defense.dart';
import 'package:sw5e_manager/domain/characters/value_objects/encumbrance.dart';
import 'package:sw5e_manager/domain/characters/value_objects/equipment_item_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/hit_points.dart';
import 'package:sw5e_manager/domain/characters/value_objects/initiative.dart';
import 'package:sw5e_manager/domain/characters/value_objects/level.dart';
import 'package:sw5e_manager/domain/characters/value_objects/maneuvers_known.dart';
import 'package:sw5e_manager/domain/characters/value_objects/proficiency_bonus.dart';
import 'package:sw5e_manager/domain/characters/value_objects/quantity.dart';
import 'package:sw5e_manager/domain/characters/value_objects/skill_proficiency.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/superiority_dice.dart';

/// Character = entité domaine représentant l'état persistant d'un héros.
///
/// * Pré-conditions :
///   - `level` doit représenter le niveau 1 (MVP).
///   - `abilities` doit contenir exactement les six clés attendues.
///   - `inventory` ne doit pas contenir de quantité nulle.
/// * Post-condition : structure immuable prête à être persistée ou affichée.
/// * Erreurs : assertions déclenchées en mode debug si un invariant est violé.
@immutable
class Character {
  /// Identifiant unique du personnage.
  final CharacterId id;

  /// Nom lisible du personnage.
  final CharacterName name;

  /// Espèce choisie dans le catalogue.
  final SpeciesId speciesId;

  /// Classe jouée (Jedi, Soldat, etc.).
  final ClassId classId;

  /// Historique (background) sélectionné.
  final BackgroundId backgroundId;

  /// Niveau courant (MVP = 1).
  final Level level;

  /// Scores d'aptitudes finaux (clefs : str/dex/con/int/wis/cha).
  final Map<String, AbilityScore> abilities;

  /// Compétences maîtrisées accompagnées de leur source.
  final Set<SkillProficiency> skills;

  /// Bonus de maîtrise calculé pour le niveau.
  final ProficiencyBonus proficiencyBonus;

  /// Points de vie calculés.
  final HitPoints hitPoints;

  /// Classe d'armure/defense du personnage.
  final Defense defense;

  /// Initiative (modificateur de Dex + bonus).
  final Initiative initiative;

  /// Richesse actuelle en crédits.
  final Credits credits;

  /// Inventaire final (immutable).
  final List<InventoryLine> inventory;

  /// Calcul d'encombrement associé à l'inventaire.
  final Encumbrance encumbrance;

  /// Nombre de manoeuvres connues (si applicable).
  final ManeuversKnown maneuversKnown;

  /// Réserve de dés de supériorité.
  final SuperiorityDice superiorityDice;

  /// Traits raciaux conférés par l'espèce.
  final Set<CharacterTrait> speciesTraits;

  /// Construit une instance en validant les invariants via assertions.
  Character({
    required this.id,
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
        // Vérifie que les six caractéristiques de base sont bien présentes.
        assert(
          _hasAllSixAbilities(abilities),
          'abilities doit contenir exactement {str,dex,con,int,wis,cha}',
        ),
        // Empêche la persistance d'objets ayant une quantité nulle.
        assert(
          inventory.every((InventoryLine l) => !l.quantity.isZero),
          'inventory ne doit pas contenir de quantité nulle',
        );

  static bool _hasAllSixAbilities(Map<String, AbilityScore> abilities) {
    const Set<String> keys = <String>{'str', 'dex', 'con', 'int', 'wis', 'cha'};
    // Utilise un set pour vérifier rapidement la présence des six abréviations.
    return abilities.length == 6 && abilities.keys.toSet().containsAll(keys);
  }
}

/// InventoryLine = ligne d'inventaire immuable (objet + quantité).
@immutable
class InventoryLine {
  /// Identifiant d'objet (slug catalogue).
  final EquipmentItemId itemId;

  /// Quantité strictement positive.
  final Quantity quantity;

  const InventoryLine({
    required this.itemId,
    required this.quantity,
  }); // Pas d'assert ici : `Quantity` garantit déjà l'invariant > 0.
}
