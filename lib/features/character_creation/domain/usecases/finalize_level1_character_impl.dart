// lib/features/character_creation/domain/usecases/finalize_level1_character_impl.dart
import 'package:sw5e_manager/core/domain/result.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/character_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/ability_score.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_trait.dart';
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
import 'package:sw5e_manager/features/character_creation/domain/value_objects/superiority_dice.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/trait_id.dart';

class FinalizeLevel1CharacterImpl implements FinalizeLevel1Character {
  final CatalogRepository catalog;
  final CharacterRepository characters;

  FinalizeLevel1CharacterImpl({
    required this.catalog,
    required this.characters,
  });

  @override
  Future<Result<Character>> call(FinalizeLevel1Input input) async {
    try {
      // 1) Charger et valider séquentiellement (fail-fast)
      final species = await catalog.getSpecies(input.speciesId.value);
      if (species == null) {
        return Result.err(DomainError(
          'UnknownCatalogId',
          message: 'speciesId inconnu',
          details: {'id': input.speciesId.value},
        ));
      }

      final clazz = await catalog.getClass(input.classId.value);
      if (clazz == null) {
        return Result.err(DomainError(
          'UnknownCatalogId',
          message: 'classId inconnu',
          details: {'id': input.classId.value},
        ));
      }

      final background = await catalog.getBackground(input.backgroundId.value);
      if (background == null) {
        return Result.err(DomainError(
          'UnknownCatalogId',
          message: 'backgroundId inconnu',
          details: {'id': input.backgroundId.value},
        ));
      }

      final formulas = await catalog.getFormulas();

      // Mapper les traitIds -> Set<CharacterTrait>
      final traits = <CharacterTrait>{};
      for (final tid in species.traitIds) {
        try {
          traits.add(CharacterTrait(id: TraitId(tid)));
        } on ArgumentError {
          // Si un ID de trait du JSON est invalide, on signale un problème de catalogue
          return Result.err(DomainError(
            'InvalidCatalogData',
            message: 'TraitId invalide pour l’espèce ${species.id}',
            details: {'traitId': tid},
          ));
        }
      }

      // 2) Valider le choix de compétences (MVP: simple)
      final choose = clazz.level1.proficiencies.skillsChoose;
      final from = clazz.level1.proficiencies.skillsFrom.toSet();
      final allowsAnySkill = from.contains('any');
      final hasCorrectCount = input.chosenSkills.length == choose;
      final choicesAreAllowed = allowsAnySkill || from.containsAll(input.chosenSkills);
      if (!hasCorrectCount || !choicesAreAllowed) {
        return Result.err(DomainError('InvalidPrerequisite',
            message: 'Compétences choisies non conformes',
            details: {'expectedChoose': choose, 'from': from, 'chosen': input.chosenSkills}));
      }

      // 3) Abilities finales (MVP: identiques aux baseAbilities; bonus espèce/background à ajouter plus tard)
      final abilities = Map<String, AbilityScore>.from(input.baseAbilities);
      if (!_hasAllSixAbilities(abilities)) {
        return Result.err(const DomainError('InvalidAbilities', message: 'Les 6 caractéristiques doivent être présentes.'));
      }

      // 4) Dérivés
      final level = Level.one;
      final pb = ProficiencyBonus.fromLevel(level);
      final conMod = abilities['con']!.modifier;
      final dexMod = abilities['dex']!.modifier;

      final hp = HitPoints(clazz.hitDie + conMod);
      final init = Initiative(dexMod);
      // MVP: interprétation simple de "10 + mod(DEX)" si pas d’armure/bouclier
      final def = Defense(10 + dexMod);

      // 5) Compétences (fusion classe + background)
      final skillsMap = <String, SkillProficiency>{};
      void addProf(String id, ProficiencySource source) {
        final existing = skillsMap[id];
        if (existing == null) {
          skillsMap[id] = SkillProficiency(
            skillId: id,
            state: ProficiencyState.proficient,
            sources: {source},
          );
        } else {
          // merge des sources
          final merged = {...existing.sources, source};
          skillsMap[id] = existing.copyWith(sources: merged);
        }
      }

      // De la classe (choix)
      for (final id in input.chosenSkills) {
        addProf(id, ProficiencySource.classSource);
      }
      // Du background (granted)
      for (final id in background.grantedSkills) {
        addProf(id, ProficiencySource.background);
      }
      final skills = skillsMap.values.toSet();

      // 6) Inventaire (pack de départ + choix utilisateur)
      final lines = <String, int>{}; // id -> qty
      if (input.useStartingEquipmentPackage) {
        for (final e in clazz.level1.startingEquipment) {
          lines.update(e.id, (v) => v + e.qty, ifAbsent: () => e.qty);
        }
      }
      final chosenLines = <String, int>{};
      for (final e in input.chosenEquipment) {
        final qty = e.quantity.value;
        if (qty <= 0) continue;
        chosenLines.update(e.itemId.value, (v) => v + qty, ifAbsent: () => qty);
        lines.update(e.itemId.value, (v) => v + qty, ifAbsent: () => qty);
      }

      // Créer InventoryLine + encumbrance (en g)
      final inventory = <InventoryLine>[];
      int totalGrams = 0;
      int totalCost = 0;
      for (final entry in lines.entries) {
        final eq = await catalog.getEquipment(entry.key);
        if (eq == null) {
          return Result.err(DomainError('UnknownCatalogId', message: 'equipmentId inconnu', details: {'id': entry.key}));
        }
        final qty = entry.value;
        if (qty <= 0) continue; // filtrer les 0
        inventory.add(InventoryLine(
          itemId: EquipmentItemId(entry.key),
          quantity: Quantity(qty),
        ));
        totalGrams += eq.weightG * qty;
        final purchasedQty = chosenLines[entry.key] ?? 0;
        if (purchasedQty > 0) {
          totalCost += eq.cost * purchasedQty;
        }
      }

      // Capacité de portance : score de Force × 15 lb (converti en grammes).
      const gramsPerPound = 453.59237;
      final strengthScore = abilities['str']!.value;
      final maxCarryGrams = (strengthScore * 15 * gramsPerPound).floor();
      if (totalGrams > maxCarryGrams) {
        return Result.err(DomainError(
          'CarryingCapacityExceeded',
          message:
              'Le poids total de l\'équipement dépasse la capacité de portance (${totalGrams}g > ${maxCarryGrams}g).',
          details: {
            'totalWeightG': totalGrams,
            'maxCarryWeightG': maxCarryGrams,
            'strengthScore': strengthScore,
          },
        ));
      }
      final enc = Encumbrance(totalGrams);

      // 7) Crédits (MVP: crédits de départ de la classe; achats soustraits)
      final baseCredits = clazz.level1.startingCredits ?? 0;
      if (totalCost > baseCredits) {
        return Result.err(DomainError(
          'StartingCreditsExceeded',
          message:
              'Le coût total des achats (${totalCost}cr) dépasse les crédits de départ (${baseCredits}cr).',
          details: {
            'totalCost': totalCost,
            'availableCredits': baseCredits,
          },
        ));
      }
      final credits = Credits(baseCredits - totalCost);

      // 8) Manœuvres & dés de supériorité (MVP: depuis Formulas)
      final sdRule = formulas.superiorityDiceByClass[input.classId.value];
      final superiority = sdRule == null
          ? SuperiorityDice(count: 0, die: null)
          : SuperiorityDice(count: sdRule.count, die: sdRule.die);
      final maneuvers = ManeuversKnown(0);

      // 9) Construire l’entité et sauvegarder
      final character = Character(
        id: CharacterId.generate(),
        name: input.name,
        speciesId: input.speciesId,
        classId: input.classId,
        backgroundId: input.backgroundId,
        level: level,
        abilities: abilities,
        skills: skills,
        proficiencyBonus: pb,
        hitPoints: hp,
        defense: def,
        initiative: init,
        credits: credits,
        inventory: inventory,
        encumbrance: enc,
        maneuversKnown: maneuvers,
        superiorityDice: superiority,
        speciesTraits: traits,
      );

      await characters.save(character);
      return Result.ok(character);
    } catch (e) {
      return Result.err(DomainError('Unexpected', message: e.toString()));
    }
  }

  static bool _hasAllSixAbilities(Map<String, AbilityScore> m) {
    const keys = {'str', 'dex', 'con', 'int', 'wis', 'cha'};
    return m.length == 6 && m.keys.toSet().containsAll(keys);
  }
}
