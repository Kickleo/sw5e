/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/assemble_level1_character_impl.dart
/// Rôle : Implémenter toute la logique métier d'assemblage d'un personnage
///        niveau 1 (validations, calculs dérivés, inventaire...).
/// Dépendances : CatalogRepository, Value Objects, AppResult.
/// Exemple d'usage :
///   final result = await AssembleLevel1CharacterImpl(catalog)(params);
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/assemble_level1_character.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_trait.dart';
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
import 'package:sw5e_manager/domain/characters/value_objects/superiority_dice.dart';
import 'package:sw5e_manager/domain/characters/value_objects/trait_id.dart';

/// Implémentation qui s'appuie sur le catalogue pour valider et construire
/// l'entité domaine [Character].
class AssembleLevel1CharacterImpl implements AssembleLevel1Character {
  final CatalogRepository catalog; // Requis pour récupérer l'équipement.

  const AssembleLevel1CharacterImpl({required this.catalog});

  @override
  Future<AppResult<Character>> call(AssembleLevel1CharacterParams params) async {
    try {
      final input = params.input;
      final context = params.context;
      final species = context.species;
      final clazz = context.clazz;
      final background = context.background;
      final formulas = context.formulas;

      // ---------------------------------------------------------------------
      // Étape 1 : convertir les identifiants de traits catalogue en Value
      // Objects du domaine. On renvoie une erreur si l'identifiant n'est pas
      // conforme pour éviter de créer un personnage incohérent.
      // ---------------------------------------------------------------------
      final traits = <CharacterTrait>{};
      for (final tid in species.traitIds) {
        try {
          traits.add(CharacterTrait(id: TraitId(tid)));
        } on ArgumentError {
          return appErr(DomainError(
            'InvalidCatalogData',
            message: 'TraitId invalide pour l’espèce ${species.id}',
            details: {'traitId': tid},
          ));
        }
      }

      // ---------------------------------------------------------------------
      // Étape 2 : valider les compétences choisies (règle MVP).
      // On vérifie que le joueur respecte le nombre de choix permis et qu'il
      // sélectionne uniquement des compétences autorisées par la classe.
      // ---------------------------------------------------------------------
      final choose = clazz.level1.proficiencies.skillsChoose;
      final from = clazz.level1.proficiencies.skillsFrom.toSet();
      final allowsAnySkill = from.contains('any');
      final hasCorrectCount = input.chosenSkills.length == choose;
      final choicesAreAllowed = allowsAnySkill || from.containsAll(input.chosenSkills);
      if (!hasCorrectCount || !choicesAreAllowed) {
        return appErr(DomainError('InvalidPrerequisite',
            message: 'Compétences choisies non conformes',
            details: {
              'expectedChoose': choose,
              'from': from,
              'chosen': input.chosenSkills,
            }));
      }

      // ---------------------------------------------------------------------
      // Étape 3 : consolider les caractéristiques. Pour le MVP, elles sont
      // identiques aux entrées utilisateur mais on s'assure que les six scores
      // sont présents. Les bonus raciaux seront ajoutés plus tard au même
      // endroit.
      // ---------------------------------------------------------------------
      final abilities = Map<String, AbilityScore>.from(input.baseAbilities);
      if (!_hasAllSixAbilities(abilities)) {
        return appErr(const DomainError(
            'InvalidAbilities', message: 'Les 6 caractéristiques doivent être présentes.'));
      }

      // ---------------------------------------------------------------------
      // Étape 4 : calcul des dérivés standards de niveau 1 (PV, initiative,
      // défense). Ces règles restent centralisées ici pour qu'elles évoluent en
      // un seul endroit lors des itérations futures.
      // ---------------------------------------------------------------------
      final level = Level.one; // MVP : seul le niveau 1 est supporté.
      final pb = ProficiencyBonus.fromLevel(level); // Bonus de maîtrise standard.
      final conMod = abilities['con']!.modifier;
      final dexMod = abilities['dex']!.modifier;

      final hp = HitPoints(clazz.hitDie + conMod); // PV = max du dé + mod CON.
      final init = Initiative(dexMod); // Initiative = mod DEX.
      final def = Defense(10 + dexMod); // MVP: défense simple sans armure.

      // ---------------------------------------------------------------------
      // Étape 5 : fusionner les compétences issues de la classe et du
      // background. On conserve la provenance dans `sources` pour expliquer à
      // l'utilisateur pourquoi il dispose d'une maîtrise donnée.
      // ---------------------------------------------------------------------
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
          final merged = {...existing.sources, source};
          skillsMap[id] = existing.copyWith(sources: merged);
        }
      }

      for (final id in input.chosenSkills) {
        addProf(id, ProficiencySource.classSource);
      }
      for (final id in background.grantedSkills) {
        addProf(id, ProficiencySource.background);
      }
      final skills = skillsMap.values.toSet();

      // ---------------------------------------------------------------------
      // Étape 6 : construire l'inventaire initial. On additionne les équipements
      // fournis par la classe et ceux achetés manuellement puis on contrôle la
      // capacité de portance.
      // ---------------------------------------------------------------------
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

      final inventory = <InventoryLine>[];
      int totalGrams = 0;
      int totalCost = 0;
      for (final entry in lines.entries) {
        final eq = await catalog.getEquipment(entry.key);
        if (eq == null) {
          return appErr(DomainError('UnknownCatalogId',
              message: 'equipmentId inconnu', details: {'id': entry.key}));
        }
        final qty = entry.value;
        if (qty <= 0) continue;
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
        return appErr(DomainError(
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

      // ---------------------------------------------------------------------
      // Étape 7 : calculer les crédits restants. L'implémentation reste simple
      // pour le MVP (crédits de départ de la classe moins les achats).
      // ---------------------------------------------------------------------
      final baseCredits = clazz.level1.startingCredits ?? 0;
      if (totalCost > baseCredits) {
        return appErr(DomainError(
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

      // ---------------------------------------------------------------------
      // Étape 8 : appliquer les règles issues des formules (dés de supériorité
      // par classe, manœuvres connues, etc.).
      // ---------------------------------------------------------------------
      final sdRule = formulas.superiorityDiceByClass[input.classId.value];
      final superiority = sdRule == null
          ? SuperiorityDice(count: 0, die: null)
          : SuperiorityDice(count: sdRule.count, die: sdRule.die);
      final maneuvers = ManeuversKnown(0); // MVP: aucune manoeuvre connue.

      // ---------------------------------------------------------------------
      // Étape 9 : instancier l'entité domaine finale. Toutes les validations
      // étant passées, on peut générer l'identifiant et retourner un `Ok`.
      // ---------------------------------------------------------------------
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

      return appOk(character);
    } catch (e) {
      return appErr(DomainError('Unexpected', message: e.toString()));
    }
  }

  /// Vérifie que la map contient bien une entrée pour chacune des six
  /// caractéristiques attendues par le système (str, dex, con, int, wis, cha).
  ///
  /// Cette méthode utilitaire reste privée à l'implémentation car elle est
  /// spécifique au workflow de création de personnage niveau 1.
  static bool _hasAllSixAbilities(Map<String, AbilityScore> m) {
    const keys = {'str', 'dex', 'con', 'int', 'wis', 'cha'};
    return m.length == 6 && m.keys.toSet().containsAll(keys);
  }
}
