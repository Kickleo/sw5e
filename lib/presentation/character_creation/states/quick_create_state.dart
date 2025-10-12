/// Etat immuable de l'assistant de création rapide.
///
/// La structure regroupe quatre familles d'informations :
///
/// 1. les indicateurs de chargement/action (ex. `isLoadingCatalog`) utilisés
///    pour afficher des spinners ;
/// 2. les données fournies par les repositories (catalogues, définitions) ;
/// 3. les choix utilisateur (sélections, champs saisis) ;
/// 4. les métadonnées de flux (étape courante, messages, erreurs, résultat).
///
/// Toutes les propriétés sont `final` afin de favoriser la création de nouveaux
/// états via [copyWith] et de préserver la prévisibilité des transitions dans le
/// BLoC.
library;
import 'package:meta/meta.dart';
import 'package:sw5e_manager/common/errors/app_failure.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';

/// QuickCreateStep = progression du wizard (vue -> BLoC).
enum QuickCreateStep { species, abilities, classes, skills, equipment, background }

/// AbilityGenerationMode = modes d'attribution des caractéristiques.
enum AbilityGenerationMode { standardArray, roll, manual }

/// Photographie complète de la progression : sélections utilisateur, résultats
/// des chargements, messages d'erreur et indicateurs d'activité. Les méthodes
/// dérivées (non montrées ici) facilitent la logique d'activation des étapes.
@immutable
class QuickCreateState {
  // --- Etats de chargement/action -------------------------------------------------
  final bool isLoadingCatalog;
  final bool isLoadingClassDetails;
  final bool isLoadingEquipment;
  final bool isCreating;

  // --- Données catalogues ---------------------------------------------------------
  final List<String> species;
  final List<String> classes;
  final List<String> backgrounds;
  final ClassDef? selectedClassDef;
  final List<TraitDef> selectedSpeciesTraits;
  final List<CharacterEffect> selectedSpeciesEffects;
  final List<String> availableSkills;
  final Map<String, SkillDef> skillDefinitions;
  final Map<String, EquipmentDef> equipmentDefinitions;
  final List<String> equipmentList;

  // --- Choix utilisateur ----------------------------------------------------------
  final String? selectedSpecies;
  final String? selectedClass;
  final String? selectedBackground;
  final Set<String> chosenSkills;
  final int skillChoicesRequired;
  final Map<String, int> chosenEquipment;
  final bool useStartingEquipment;
  final String characterName;
  final Map<String, int?> abilityAssignments;
  final List<int> abilityPool;
  final AbilityGenerationMode abilityMode;

  // --- Métadonnées UI -------------------------------------------------------------
  final int stepIndex;
  final String? statusMessage;
  final AppFailure? failure;
  final QuickCreateCompletion? completion;
  final bool hasLoadedOnce;

  const QuickCreateState({
    required this.isLoadingCatalog,
    required this.isLoadingClassDetails,
    required this.isLoadingEquipment,
    required this.isCreating,
    required this.species,
    required this.classes,
    required this.backgrounds,
    required this.selectedSpecies,
    required this.selectedClass,
    required this.selectedBackground,
    required this.selectedClassDef,
    required this.selectedSpeciesTraits,
    required this.selectedSpeciesEffects,
    required this.availableSkills,
    required this.skillDefinitions,
    required this.chosenSkills,
    required this.skillChoicesRequired,
    required this.equipmentDefinitions,
    required this.equipmentList,
    required this.chosenEquipment,
    required this.useStartingEquipment,
    required this.stepIndex,
    required this.characterName,
    required this.statusMessage,
    required this.failure,
    required this.completion,
    required this.hasLoadedOnce,
    required this.abilityAssignments,
    required this.abilityPool,
    required this.abilityMode,
  });

  factory QuickCreateState.initial() => const QuickCreateState(
        isLoadingCatalog: false,
        isLoadingClassDetails: false,
        isLoadingEquipment: false,
        isCreating: false,
        species: <String>[],
        classes: <String>[],
        backgrounds: <String>[],
        selectedSpecies: null,
        selectedClass: null,
        selectedBackground: null,
        selectedClassDef: null,
        selectedSpeciesTraits: <TraitDef>[],
        selectedSpeciesEffects: <CharacterEffect>[],
        availableSkills: <String>[],
        skillDefinitions: <String, SkillDef>{},
        chosenSkills: <String>{},
        skillChoicesRequired: 0,
        equipmentDefinitions: <String, EquipmentDef>{},
        equipmentList: <String>[],
        chosenEquipment: <String, int>{},
        useStartingEquipment: true,
        stepIndex: 0,
        characterName: 'Rey',
        statusMessage: null,
        failure: null,
        completion: null,
        hasLoadedOnce: false,
        abilityAssignments: <String, int?>{
          'str': 15,
          'dex': 14,
          'con': 13,
          'int': 12,
          'wis': 10,
          'cha': 8,
        },
        abilityPool: <int>[15, 14, 13, 12, 10, 8],
        abilityMode: AbilityGenerationMode.standardArray,
      );

  /// Message d'erreur prêt à l'affichage en interface (code + libellé).
  String? get errorMessage =>
      failure?.toDisplayMessage(includeCode: true);

  QuickCreateState copyWith({
    bool? isLoadingCatalog,
    bool? isLoadingClassDetails,
    bool? isLoadingEquipment,
    bool? isCreating,
    List<String>? species,
    List<String>? classes,
    List<String>? backgrounds,
    Object? selectedSpecies = _sentinel,
    Object? selectedClass = _sentinel,
    Object? selectedBackground = _sentinel,
    Object? selectedClassDef = _sentinel,
    List<TraitDef>? selectedSpeciesTraits,
    List<CharacterEffect>? selectedSpeciesEffects,
    List<String>? availableSkills,
    Map<String, SkillDef>? skillDefinitions,
    Set<String>? chosenSkills,
    int? skillChoicesRequired,
    Map<String, EquipmentDef>? equipmentDefinitions,
    List<String>? equipmentList,
    Map<String, int>? chosenEquipment,
    bool? useStartingEquipment,
    int? stepIndex,
    String? characterName,
    Object? statusMessage = _sentinel,
    Object? failure = _sentinel,
    Object? completion = _sentinel,
    bool? hasLoadedOnce,
    Map<String, int?>? abilityAssignments,
    List<int>? abilityPool,
    AbilityGenerationMode? abilityMode,
  }) {
    return QuickCreateState(
      isLoadingCatalog: isLoadingCatalog ?? this.isLoadingCatalog,
      isLoadingClassDetails: isLoadingClassDetails ?? this.isLoadingClassDetails,
      isLoadingEquipment: isLoadingEquipment ?? this.isLoadingEquipment,
      isCreating: isCreating ?? this.isCreating,
      species: species ?? this.species,
      classes: classes ?? this.classes,
      backgrounds: backgrounds ?? this.backgrounds,
      selectedSpecies: selectedSpecies == _sentinel
          ? this.selectedSpecies
          : selectedSpecies as String?,
      selectedClass:
          selectedClass == _sentinel ? this.selectedClass : selectedClass as String?,
      selectedBackground: selectedBackground == _sentinel
          ? this.selectedBackground
          : selectedBackground as String?,
      selectedClassDef: selectedClassDef == _sentinel
          ? this.selectedClassDef
          : selectedClassDef as ClassDef?,
      selectedSpeciesTraits: selectedSpeciesTraits ?? this.selectedSpeciesTraits,
      selectedSpeciesEffects:
          selectedSpeciesEffects ?? this.selectedSpeciesEffects,
      availableSkills: availableSkills ?? this.availableSkills,
      skillDefinitions: skillDefinitions ?? this.skillDefinitions,
      chosenSkills: chosenSkills ?? this.chosenSkills,
      skillChoicesRequired: skillChoicesRequired ?? this.skillChoicesRequired,
      equipmentDefinitions: equipmentDefinitions ?? this.equipmentDefinitions,
      equipmentList: equipmentList ?? this.equipmentList,
      chosenEquipment: chosenEquipment ?? this.chosenEquipment,
      useStartingEquipment: useStartingEquipment ?? this.useStartingEquipment,
      stepIndex: stepIndex ?? this.stepIndex,
      characterName: characterName ?? this.characterName,
      statusMessage:
          statusMessage == _sentinel ? this.statusMessage : statusMessage as String?,
      failure: failure == _sentinel ? this.failure : failure as AppFailure?,
      completion:
          completion == _sentinel ? this.completion : completion as QuickCreateCompletion?,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      abilityAssignments: abilityAssignments ?? this.abilityAssignments,
      abilityPool: abilityPool ?? this.abilityPool,
      abilityMode: abilityMode ?? this.abilityMode,
    );
  }

  QuickCreateStep get currentStep => QuickCreateStep.values[stepIndex];

  /// Indique si les prérequis de l'étape courante sont remplis pour autoriser
  /// l'utilisateur à avancer.
  bool get canGoNext {
    switch (currentStep) {
      case QuickCreateStep.species:
        return selectedSpecies != null;
      case QuickCreateStep.abilities:
        return hasValidAbilityAssignments;
      case QuickCreateStep.classes:
        return selectedClass != null;
      case QuickCreateStep.skills:
        return hasValidSkillSelection;
      case QuickCreateStep.equipment:
        return hasValidEquipmentSelection;
      case QuickCreateStep.background:
        return canCreate;
    }
  }

  /// Autorise le retour en arrière tant que l'utilisateur n'est pas à la toute
  /// première étape.
  bool get canGoPrevious => stepIndex > 0;

  /// Valide les compétences sélectionnées : soit aucun choix requis, soit le
  /// nombre de cases cochées correspond au quota imposé par la classe.
  bool get hasValidSkillSelection =>
      skillChoicesRequired == 0 || chosenSkills.length == skillChoicesRequired;

  /// Préconditions nécessaires à la finalisation : l'intégralité des champs
  /// obligatoires doivent être renseignés et valides.
  bool get canCreate =>
      selectedSpecies != null &&
      selectedClass != null &&
      selectedBackground != null &&
      characterName.trim().isNotEmpty &&
      hasValidSkillSelection &&
      hasValidAbilityAssignments &&
      hasValidEquipmentSelection;

  /// Vérifie que l'équipement choisi respecte les limites de poids et de
  /// budget définies par la classe.
  bool get hasValidEquipmentSelection {
    if (selectedClassDef == null) {
      return false;
    }
    if (isLoadingEquipment) {
      return false;
    }
    final totalWeight = totalInventoryWeightG;
    if (totalWeight == null) {
      return false;
    }
    final capacity = carryingCapacityLimitG;
    if (capacity != null && totalWeight > capacity) {
      return false;
    }
    final credits = availableCredits;
    if (credits >= 0 && totalPurchasedEquipmentCost > credits) {
      return false;
    }
    return true;
  }

  /// Budget initial octroyé par la classe (0 si les détails ne sont pas chargés).
  int get availableCredits => selectedClassDef?.level1.startingCredits ?? 0;

  /// Calcule le coût total des achats manuels en tenant compte des quantités.
  int get totalPurchasedEquipmentCost {
    var total = 0;
    for (final entry in chosenEquipment.entries) {
      final def = equipmentDefinitions[entry.key];
      if (def == null) {
        return total;
      }
      if (entry.value <= 0) continue;
      total += def.cost * entry.value;
    }
    return total;
  }

  /// Montant restant disponible après achats manuels.
  int get remainingCredits => availableCredits - totalPurchasedEquipmentCost;

  /// Limite d'encombrement convertie en grammes selon les règles SW5e.
  int? get carryingCapacityLimitG {
    final strength = abilityAssignments['str'];
    if (strength == null) {
      return null;
    }
    const gramsPerPound = 453.59237;
    return (strength * 15 * gramsPerPound).floor();
  }

  /// Poids total en grammes de l'inventaire combinant pack de départ et achats.
  int? get totalInventoryWeightG {
    final classDef = selectedClassDef;
    if (classDef == null) {
      return null;
    }
    var total = 0;
    if (useStartingEquipment) {
      for (final line in classDef.level1.startingEquipment) {
        final def = equipmentDefinitions[line.id];
        if (def == null) {
          return null;
        }
        total += def.weightG * line.qty;
      }
    }
    for (final entry in chosenEquipment.entries) {
      final def = equipmentDefinitions[entry.key];
      if (def == null) {
        return null;
      }
      if (entry.value <= 0) continue;
      total += def.weightG * entry.value;
    }
    return total;
  }

  /// Vérifie que toutes les caractéristiques ont une valeur autorisée et que le
  /// pool de points n'est pas dépassé (sauf mode manuel qui autorise toute
  /// valeur dans l'intervalle).
  bool get hasValidAbilityAssignments {
    for (final ability in abilityOrder) {
      final value = abilityAssignments[ability];
      if (value == null || value < AbilityScore.min || value > AbilityScore.max) {
        return false;
      }
    }
    if (abilityMode == AbilityGenerationMode.manual) {
      return true;
    }
    final poolCounts = <int, int>{};
    for (final value in abilityPool) {
      poolCounts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }
    final assignedCounts = <int, int>{};
    for (final value in abilityAssignments.values) {
      if (value == null) continue;
      assignedCounts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }
    for (final entry in assignedCounts.entries) {
      final available = poolCounts[entry.key] ?? 0;
      if (entry.value > available) {
        return false;
      }
    }
    return true;
  }

  static const List<String> abilityOrder = ['str', 'dex', 'con', 'int', 'wis', 'cha'];

  static const Map<String, String> abilityLabels = {
    'str': 'Force',
    'dex': 'Dextérité',
    'con': 'Constitution',
    'int': 'Intelligence',
    'wis': 'Sagesse',
    'cha': 'Charisme',
  };

  static const Map<String, String> abilityAbbreviations = {
    'str': 'FOR',
    'dex': 'DEX',
    'con': 'CON',
    'int': 'INT',
    'wis': 'SAG',
    'cha': 'CHA',
  };
}

/// QuickCreateCompletion = résultat final du wizard (succès ou erreur).
sealed class QuickCreateCompletion {
  /// Constructeur const par défaut.
  const QuickCreateCompletion();
}

/// QuickCreateSuccess = finalisation réussie avec un [Character] prêt.
final class QuickCreateSuccess extends QuickCreateCompletion {
  /// Personnage résultant de la finalisation.
  final Character character;

  /// Crée un succès avec le personnage finalisé.
  const QuickCreateSuccess(this.character);
}

/// QuickCreateFailure = encapsule un [AppFailure] métier.
final class QuickCreateFailure extends QuickCreateCompletion {
  /// Erreur métier détaillée.
  final AppFailure failure;

  /// Crée un échec avec l'erreur correspondante.
  const QuickCreateFailure(this.failure);
}

const Object _sentinel = Object();
