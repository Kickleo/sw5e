/// Entités de la couche domaine représentant un personnage finalisé et son
/// inventaire.
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

/// Représente l'état persistant d'un personnage prêt à être sauvegardé ou
/// affiché à l'écran.
///
/// L'entité agrège toutes les décisions prises durant le wizard : identité,
/// choix d'espèce/classe, scores calculés et inventaire final. Le constructeur
/// vérifie explicitement les invariants fonctionnels :
///
/// - le MVP cible des personnages niveau 1 uniquement ;
/// - la carte des caractéristiques doit contenir exactement les six abréviations
///   standards (str, dex, con, int, wis, cha) ;
/// - l'inventaire ne conserve que des quantités strictement positives (les
///   objets à 0 sont filtrés au niveau du wizard).
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

  /// Construit un personnage en s'assurant que les invariants métiers sont
  /// respectés. L'utilisation d'objets valeur pour chaque champ évite de devoir
  /// répéter les validations dans les couches supérieures.
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
///
/// Utilisée par [Character.inventory] pour mémoriser la dotation finale. Les
/// règles de validation (quantité > 0) sont portées par [Quantity].
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
