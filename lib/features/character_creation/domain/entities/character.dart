// lib/features/character_creation/domain/entities/character.dart
import 'package:meta/meta.dart';

/// Entité domaine - MVP niveau 1 (version primitive).
/// NOTE: ces types primitifs seront remplacés par nos Value Objects
/// (CharacterName, SpeciesId, ClassId, etc.) dans l'étape suivante.
@immutable
class Character {
  // Identité & choix structurels
  final String name;           // TODO: CharacterName
  final String speciesId;      // TODO: SpeciesId (slug)
  final String classId;        // TODO: ClassId (slug)
  final String backgroundId;   // TODO: BackgroundId (slug)

  // Niveau (MVP = 1)
  final int level;             // TODO: Level VO (bornes 1..20, MVP=1)

  /// Abilities finales (après bonus espèce/background)
  /// Clés attendues: str, dex, con, int, wis, cha
  final Map<String, int> abilities; // TODO: Map<AbilityId, AbilityScore>

  /// Compétences maîtrisées (slugs)
  final Set<String> skills;    // TODO: Set<SkillProficiency>

  // Dérivés
  final int proficiencyBonus;  // TODO: ProficiencyBonus (MVP: +2)
  final int hitPoints;         // TODO: HitPoints (>=1)
  final int defense;           // TODO: Defense (garde-fou 5..35)
  final int initiative;        // TODO: Initiative (-10..+20)

  // Économie & inventaire
  final int credits;           // TODO: Credits (>=0)
  final List<InventoryLine> inventory; // TODO: use EquipmentItemId + Quantity
  final int encumbranceG;      // en grammes // TODO: Encumbrance VO

  // Manœuvres (si classe applicable)
  final int maneuversKnown;    // TODO: ManeuversKnown (>=0)
  final int superiorityDiceCount; // TODO: SuperiorityDice.count
  final int? superiorityDie;      // faces: 4/6/8/10/12 ou null si count=0

  const Character({
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
    required this.encumbranceG,
    required this.maneuversKnown,
    required this.superiorityDiceCount,
    required this.superiorityDie,
  })  : assert(level == 1, 'MVP: level doit être 1'),
        assert(_hasAllSixAbilities(abilities),
            'abilities doit contenir exactement {str,dex,con,int,wis,cha}'),
        assert(proficiencyBonus >= 2 && proficiencyBonus <= 6),
        assert(hitPoints >= 1),
        assert(defense >= 5 && defense <= 35),
        assert(credits >= 0),
        assert(initiative >= -10 && initiative <= 20),
        assert(encumbranceG >= 0),
        assert(maneuversKnown >= 0),
        assert(superiorityDiceCount >= 0),
        assert(
          (superiorityDiceCount == 0 && superiorityDie == null) ||
              (superiorityDiceCount > 0 &&
                  (superiorityDie == 4 ||
                      superiorityDie == 6 ||
                      superiorityDie == 8 ||
                      superiorityDie == 10 ||
                      superiorityDie == 12)),
          'Si superiorityDiceCount>0, superiorityDie ∈ {4,6,8,10,12}; '
          'sinon superiorityDie doit être null',
        );

  static bool _hasAllSixAbilities(Map<String, int> m) {
    const keys = {'str', 'dex', 'con', 'int', 'wis', 'cha'};
    return m.length == 6 && m.keys.toSet().containsAll(keys);
  }
}

/// Ligne d’inventaire simplifiée (slug + quantité)
@immutable
class InventoryLine {
  final String equipmentItemId; // TODO: EquipmentItemId VO (slug)
  final int quantity;           // TODO: Quantity VO (>=0)

  const InventoryLine({
    required this.equipmentItemId,
    required this.quantity,
  }) : assert(quantity >= 0);
}
