import 'package:flutter/widgets.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// Provides application-specific translations for supported locales.
class AppLocalizations {
  AppLocalizations(this.locale);

  /// Currently supported locale.
  final Locale locale;

  /// List of supported locales.
  static const supportedLocales = [Locale('en'), Locale('fr')];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get languageCode => locale.languageCode;

  bool get isFrench => languageCode == 'fr';

  /// Returns the localized value of a [LocalizedText] according to [locale].
  String localizedCatalogLabel(LocalizedText text) {
    final String? resolved = text.maybeResolve(
      languageCode,
      fallbackLanguageCode: 'en',
    );
    if (resolved != null && resolved.trim().isNotEmpty) {
      return resolved.trim();
    }
    final String fallback = text.resolve('en');
    if (fallback.trim().isNotEmpty) {
      return fallback.trim();
    }
    return text.en.isNotEmpty ? text.en : text.fr;
  }

  String get appTitle => 'SW5e Manager';

  String get homeWelcomeTitle =>
      isFrench ? 'Bienvenue dans SW5e Manager' : 'Welcome to SW5e Manager';

  String get homeTagline => isFrench
      ? 'Gérez vos héros : créez-en un nouveau ou ouvrez une fiche existante.'
      : 'Manage your heroes: create a new one or open an existing sheet.';

  String get homeCreateButton =>
      isFrench ? 'Créer un nouveau personnage' : 'Create a new character';

  String get homeLoadButton => isFrench
      ? 'Charger une fiche existante'
      : 'Load an existing sheet';

  String get homeLanguageLabel =>
      isFrench ? 'Langue de l\'application' : 'Application language';

  String get languageFrench => 'Français';

  String get languageEnglish => 'English';

  String quickCreateStepTitle(int current, int total) => isFrench
      ? 'Création rapide — Étape $current/$total'
      : 'Quick create — Step $current/$total';

  String get quickCreateBackTooltip =>
      isFrench ? 'Retour à l\'accueil' : 'Back to home';

  String get offlineBanner => isFrench
      ? 'Mode hors ligne : certaines fonctionnalités réseau sont indisponibles.'
      : 'Offline mode: some online features are unavailable.';

  String get noStatusMessage =>
      isFrench ? 'Aucun message pour le moment.' : 'No message at the moment.';

  String get loadingCatalog =>
      isFrench ? 'Chargement du catalogue…' : 'Loading catalog…';

  String get genericClose => isFrench ? 'Fermer' : 'Close';

  String get noSpeciesTraits => isFrench
      ? 'Aucun trait spécifique pour cette espèce.'
      : 'No specific trait for this species.';

  String get speciesLabel => isFrench ? 'Espèce' : 'Species';

  String get speciesBrowse => isFrench ? 'Parcourir' : 'Browse';

  String get speciesPickerTitle =>
      isFrench ? 'Choisir une espèce' : 'Choose a species';

  String get classPickerTitle =>
      isFrench ? 'Choisir une classe' : 'Choose a class';

  String get pickerSelectAction =>
      isFrench ? 'Sélectionner' : 'Select';

  String get noSpeciesAvailable => isFrench
      ? 'Aucune espèce disponible'
      : 'No species available';

  String get noClassesAvailable => isFrench
      ? 'Aucune classe disponible'
      : 'No classes available';

  String get noSpeciesSelected => isFrench
      ? 'Aucune espèce sélectionnée'
      : 'No species selected';

  String get noClassSelectedPicker => isFrench
      ? 'Aucune classe sélectionnée'
      : 'No class selected';

  String speciesIdentifier(String id) =>
      isFrench ? 'Identifiant : $id' : 'Identifier: $id';

  String speciesSpeed(String speed) =>
      isFrench ? 'Vitesse : $speed' : 'Speed: $speed';

  String speciesSize(String size) =>
      isFrench ? 'Taille : $size' : 'Size: $size';

  String get speciesPickerTraitsTitle =>
      isFrench ? 'Traits d’espèce' : 'Species traits';

  String get speciesPickerNoTraits => isFrench
      ? 'Aucun trait listé pour cette espèce.'
      : 'No traits listed for this species.';

  String get classPickerNoClass => isFrench
      ? 'Aucune classe sélectionnée'
      : 'No class selected';

  String classPickerHitDie(int hitDie) =>
      isFrench ? 'Dé de vie : d$hitDie' : 'Hit die: d$hitDie';

  String classPickerSkillsHeading(int choose) => isFrench
      ? 'Compétences : choisir $choose parmi :'
      : 'Skills: choose $choose from:';

  String classPickerSkillLine(String label, String ability) => isFrench
      ? '• $label ($ability)'
      : '• $label ($ability)';

  String get classPickerStartingEquipmentTitle => isFrench
      ? 'Équipement de départ'
      : 'Starting equipment';

  String classPickerEquipmentLine(String label, int qty) => isFrench
      ? '• $label ×$qty'
      : '• $label ×$qty';

  String get classPickerExtraOptionsTitle => isFrench
      ? 'Options supplémentaires'
      : 'Additional options';

  String get classPickerAnySkill =>
      isFrench ? "N'importe quelle compétence" : 'Any skill';

  String get speciesEffectsTitle =>
      isFrench ? 'Effets d’espèce' : 'Species effects';

  String get speciesTraitsTitle =>
      isFrench ? 'Traits d’espèce' : 'Species traits';

  String get effectPassive =>
      isFrench ? 'Effet passif' : 'Passive effect';

  String get effectAction => isFrench ? 'Action' : 'Action';

  String get effectBonusAction =>
      isFrench ? 'Action bonus' : 'Bonus action';

  String get abilitiesHeader => isFrench
      ? 'Attribuez vos caractéristiques'
      : 'Assign your ability scores';

  String get abilityScoreLabel => isFrench ? 'Score' : 'Score';

  String modifierLabel(int? modifier) {
    if (modifier == null) {
      return isFrench ? 'Mod —' : 'Mod —';
    }
    final sign = modifier >= 0 ? '+' : '';
    return isFrench ? 'Mod $sign$modifier' : 'Mod $sign$modifier';
  }

  String get abilityGenerationStandardArray =>
      isFrench ? 'Tableau standard' : 'Standard array';

  String get abilityGenerationStandardArrayDesc => isFrench
      ? 'Utiliser les scores fixes 15, 14, 13, 12, 10 et 8.'
      : 'Use the fixed scores 15, 14, 13, 12, 10 and 8.';

  String get abilityGenerationRoll =>
      isFrench ? 'Lancer les dés' : 'Roll dice';

  String get abilityGenerationRollDesc => isFrench
      ? 'Lancez 4d6, conservez les 3 meilleurs et assignez les 6 scores obtenus.'
      : 'Roll 4d6, drop the lowest, and assign the six resulting scores.';

  String get abilityGenerationManual =>
      isFrench ? 'Saisie manuelle' : 'Manual entry';

  String get abilityGenerationManualDesc => isFrench
      ? 'Entrez vous-même les scores obtenus ailleurs et assignez-les.'
      : 'Enter the scores you obtained elsewhere and assign them.';

  String get rerollDice => isFrench ? 'Lancer les dés' : 'Roll dice';

  String get availableScores =>
      isFrench ? 'Scores disponibles' : 'Available scores';

  String get noGeneratedScores => isFrench
      ? 'Aucun score généré pour le moment.'
      : 'No scores generated yet.';

  String get manualScoreHint => isFrench
      ? 'Chaque champ accepte une valeur entre 1 et 20.'
      : 'Each field accepts a value between 1 and 20.';

  String get abilityTip => isFrench
      ? 'Astuce : pour calculer le modificateur, soustrayez 10 du score et divisez par 2 (arrondi à l’inférieur).'
      : 'Tip: to compute the modifier, subtract 10 from the score and divide by 2 (rounded down).';

  String abilityScoreChip(int score, int count) {
    if (count > 1) {
      return '$score ×$count';
    }
    return score.toString();
  }

  String abilityAbbreviation(String ability) {
    final lower = ability.toLowerCase();
    switch (lower) {
      case 'str':
        return isFrench ? 'FOR' : 'STR';
      case 'dex':
        return isFrench ? 'DEX' : 'DEX';
      case 'con':
        return isFrench ? 'CON' : 'CON';
      case 'int':
        return isFrench ? 'INT' : 'INT';
      case 'wis':
        return isFrench ? 'SAG' : 'WIS';
      case 'cha':
        return isFrench ? 'CHA' : 'CHA';
      default:
        return ability.toUpperCase();
    }
  }

  String get skillStepNoAdditionalChoices => isFrench
      ? 'La classe sélectionnée n’offre aucun choix de compétence supplémentaire.'
      : 'The selected class does not grant additional skill choices.';

  String get skillStepNoSkills => isFrench
      ? 'Aucune compétence disponible pour cette classe. Vérifiez le catalogue.'
      : 'No skills are available for this class. Check the catalog.';

  String skillStepHeader(int required, int chosen) {
    final plural = required > 1;
    final remaining = '$chosen/$required';
    if (isFrench) {
      final suffix = plural ? 's' : '';
      return 'Choisissez $required compétence$suffix ($remaining sélectionnées).';
    } else {
      final noun = plural ? 'skills' : 'skill';
      return 'Choose $required $noun ($remaining selected).';
    }
  }

  String skillStepAbilitySubtitle(String ability) => isFrench
      ? 'Basée sur ${abilityAbbreviation(ability)}'
      : 'Based on ${abilityAbbreviation(ability)}';

  String get skillStepLimitReached => isFrench
      ? 'Vous avez atteint le nombre maximum de compétences sélectionnées. Décochez-en une pour en choisir une autre.'
      : 'You reached the maximum number of selected skills. Uncheck one to pick another.';

  String get equipmentStepSelectClass => isFrench
      ? 'Choisissez une classe pour configurer votre équipement.'
      : 'Choose a class to configure your gear.';

  String get equipmentStepCatalogMissing => isFrench
      ? 'Catalogue d’équipement indisponible.'
      : 'Equipment catalog unavailable.';

  String equipmentStepCredits(int credits) => isFrench
      ? 'Crédits de départ : ${credits}cr'
      : 'Starting credits: ${credits}cr';

  String equipmentStepAlternateRoll(String roll) => isFrench
      ? 'Jet alternatif : $roll'
      : 'Alternate roll: $roll';

  String get equipmentStepUseStarting => isFrench
      ? 'Prendre l’équipement de départ de la classe'
      : 'Take the class starting equipment';

  String get equipmentStepNoStarting => isFrench
      ? 'Cette classe ne fournit pas d’équipement spécifique par défaut.'
      : 'This class does not provide default starting equipment.';

  String get equipmentStepOptionsTitle => isFrench
      ? 'Options d’équipement de départ'
      : 'Starting equipment options';

  String get equipmentStepPurchasesTitle => isFrench
      ? 'Achats en cours'
      : 'Current purchases';

  String equipmentStepPurchaseLine(String label, int qty, int cost) => isFrench
      ? '• $label ×$qty (${cost}cr)'
      : '• $label ×$qty (${cost}cr)';

  String equipmentStepCost(int cost) =>
      isFrench ? 'Coût des achats : ${cost}cr' : 'Purchase cost: ${cost}cr';

  String equipmentStepRemainingCredits(int remaining) => isFrench
      ? 'Crédits restants : ${remaining}cr'
      : 'Remaining credits: ${remaining}cr';

  String equipmentStepTotalWeight(String weight) =>
      isFrench ? 'Poids total : $weight' : 'Total weight: $weight';

  String equipmentStepCapacity(String capacity) =>
      isFrench ? 'Capacité : $capacity' : 'Capacity: $capacity';

  String equipmentStepStartingWeight(String weight) => isFrench
      ? 'Équipement de départ : $weight'
      : 'Starting gear: $weight';

  String equipmentStepPurchasesWeight(String weight) => isFrench
      ? 'Achats : $weight'
      : 'Purchases: $weight';

  String get equipmentStepOverCredits => isFrench
      ? 'Vous dépassez vos crédits de départ.'
      : 'You exceed your starting credits.';

  String get equipmentStepOverCapacity => isFrench
      ? 'Le poids total dépasse votre capacité de portance.'
      : 'Total weight exceeds your carrying capacity.';

  String get equipmentStepSearchLabel => isFrench
      ? 'Rechercher un objet…'
      : 'Search an item…';

  String get equipmentStepSearchEmpty => isFrench
      ? 'Aucun équipement ne correspond à votre recherche.'
      : 'No equipment matches your search.';

  String equipmentStepListSubtitle(int cost, String weight, String type) => isFrench
      ? '${cost}cr · $weight · $type'
      : '${cost}cr · $weight · $type';

  String navigationErrorMessage(Object? error) => isFrench
      ? 'Erreur de navigation : $error'
      : 'Navigation error: $error';

  String get manualScoreRequired => isFrench ? 'Requis' : 'Required';

  String get manualScoreNumberError =>
      isFrench ? 'Entrez un nombre' : 'Enter a number';

  String manualScoreRangeError(int min, int max) => isFrench
      ? 'Doit être entre $min et $max'
      : 'Must be between $min and $max';

  String get classLabel => isFrench ? 'Classe' : 'Class';

  String get classDetails => isFrench ? 'Détails' : 'Details';

  String get noClassSelected => isFrench
      ? 'Aucune classe sélectionnée.'
      : 'No class selected.';

  String get hitDiceLabel =>
      isFrench ? 'Dé de vie' : 'Hit die';

  String classSkillsChoice(int count) => isFrench
      ? 'Compétences : choisir $count (étape suivante)'
      : 'Skills: choose $count (next step)';

  String get startingEquipmentTitle => isFrench
      ? 'Équipement de départ :'
      : 'Starting equipment:';

  String get startingEquipmentEmpty => isFrench
      ? 'Équipement de départ : cette classe ne propose pas de pack pré-défini.'
      : 'Starting equipment: this class does not offer a predefined pack.';

  String get startingEquipmentOptionsTitle =>
      isFrench ? 'Options :' : 'Options:';

  String startingEquipmentLine(String label, int quantity) =>
      '• $label ×$quantity';

  String startingEquipmentOption(LocalizedText option) =>
      '• ${localizedCatalogLabel(option)}';

  String quickCreateSummaryTitle(String name) => isFrench
      ? 'Résumé de $name'
      : '$name summary';

  String get savedCharactersTitle =>
      isFrench ? 'Personnages enregistrés'
      : 'Saved characters';

  String get backToHomeTooltip =>
      isFrench ? "Retour à l'accueil" : 'Back to home';

  String get refreshTooltip =>
      isFrench ? 'Rafraîchir' : 'Refresh';

  String get unknownError =>
      isFrench ? 'Erreur inconnue' : 'Unknown error';

  String get savedCharactersEmpty => isFrench
      ? 'Aucun personnage enregistré pour le moment.'
      : 'No characters saved yet.';

  String get retryLabel => isFrench ? 'Réessayer' : 'Try again';

  String get shareTooltip => isFrench ? 'Partager' : 'Share';

  String get characterSummaryTitle =>
      isFrench ? 'Résumé de personnage' : 'Character summary';

  String get savedCharacterDropdownLabel => isFrench
      ? 'Personnage sauvegardé'
      : 'Saved character';

  String get statLevel => isFrench ? 'Niveau' : 'Level';
  String get statDefense => isFrench ? 'Défense' : 'Defense';
  String get statCarriedWeight =>
      isFrench ? 'Poids porté' : 'Carried weight';

  String get characterProfileTitle =>
      isFrench ? 'Profil' : 'Profile';

  String get characterSpeciesTraitsHeading => isFrench
      ? 'Traits d’espèce :'
      : 'Species traits:';

  String get characterAbilitiesTitle =>
      isFrench ? 'Caractéristiques' : 'Abilities';

  String get characterMasteredSkillsTitle => isFrench
      ? 'Compétences maîtrisées'
      : 'Mastered skills';

  String get characterInventoryTitle =>
      isFrench ? 'Inventaire' : 'Inventory';

  String get characterInventoryEmpty =>
      isFrench ? 'Vide' : 'Empty';

  String get characterNoSkills => isFrench ? 'Aucune' : 'None';

  String get characterManeuversTitle => isFrench
      ? 'Manœuvres / Dés de supériorité'
      : 'Maneuvers / Superiority dice';

  String characterManeuversKnown(int known) => isFrench
      ? 'Connues : $known'
      : 'Known: $known';

  String characterManeuverDice(int count, int? die) => isFrench
      ? 'Dés : ${count}d${die ?? '-'}'
      : 'Dice: ${count}d${die ?? '-'}';

  String get abilitiesTableAbility => isFrench ? 'Carac' : 'Ability';
  String get abilitiesTableScore => isFrench ? 'Score' : 'Score';
  String get abilitiesTableModifier => isFrench ? 'Mod' : 'Mod';

  String get emptySavedCharacters =>
      isFrench ? 'Aucun personnage sauvegardé.' : 'No saved characters.';

  String savedCharactersHeader(String species, String classId) => isFrench
      ? 'Espèce : $species • Classe : $classId'
      : 'Species: $species • Class: $classId';

  String savedCharactersBackground(String background) => isFrench
      ? 'Historique : $background'
      : 'Background: $background';

  String savedCharactersLevel(int level) =>
      isFrench ? 'Niveau $level' : 'Level $level';

  String savedCharactersDefense(int defense) =>
      isFrench ? 'Défense $defense' : 'Defense $defense';

  String get statHp => isFrench ? 'PV' : 'HP';
  String get statInitiative => isFrench ? 'Init' : 'Init';
  String get statProficiency =>
      isFrench ? 'Bonus maîtrise' : 'Proficiency bonus';
  String get statCredits => isFrench ? 'Crédits' : 'Credits';
  String get statEncumbrance => isFrench ? 'Charge' : 'Encumbrance';

  String get savedCharactersCharacteristicsTitle =>
      isFrench ? 'Caractéristiques' : 'Abilities';
  String get savedCharactersSkillsTitle =>
      isFrench ? 'Compétences' : 'Skills';
  String get savedCharactersInventoryTitle =>
      isFrench ? 'Inventaire' : 'Inventory';

  String inventoryLine(String label, int qty) => isFrench
      ? '• $label ×$qty'
      : '• $label ×$qty';

  String get summaryUnknown => isFrench ? 'Inconnu' : 'Unknown';

  String get summaryStepSpecies => isFrench ? 'Espèce' : 'Species';
  String get summaryStepAbilities =>
      isFrench ? 'Caractéristiques' : 'Abilities';
  String get summaryStepClass => isFrench ? 'Classe' : 'Class';
  String get summaryStepSkills => isFrench ? 'Compétences' : 'Skills';
  String get summaryStepEquipment =>
      isFrench ? 'Équipement' : 'Equipment';
  String get summaryStepBackground =>
      isFrench ? 'Historique' : 'Background';

  String get summaryTitle =>
      isFrench ? 'Résumé du personnage' : 'Character summary';
  String get summaryProgression =>
      isFrench ? 'Progression' : 'Progress';
  String get summaryIdentity =>
      isFrench ? 'Identité' : 'Identity';
  String get summaryClassFeatures =>
      isFrench ? 'Caractéristiques de classe' : 'Class features';
  String get summarySpecies => isFrench ? 'Espèce' : 'Species';
  String get summaryAbilities => isFrench ? 'Caractéristiques' : 'Abilities';
  String get summarySkills => isFrench ? 'Compétences' : 'Skills';
  String get summaryEquipment => isFrench ? 'Équipement' : 'Equipment';
  String get summaryCarryingAndFinance => isFrench
      ? 'Capacité de charge & finances'
      : 'Carrying capacity & finances';

  String get summaryName => isFrench ? 'Nom' : 'Name';
  String get summarySpeciesLabel => isFrench ? 'Espèce' : 'Species';
  String get summaryClassLabel => isFrench ? 'Classe' : 'Class';
  String get summaryBackgroundLabel =>
      isFrench ? 'Historique' : 'Background';

  String get summaryNotProvided =>
      isFrench ? 'Non renseigné' : 'Not provided';
  String summaryNotSelected({bool feminine = false}) {
    if (isFrench) {
      return feminine ? 'Non sélectionnée' : 'Non sélectionné';
    }
    return 'Not selected';
  }

  String get summaryNoClassSelected => isFrench
      ? 'Aucune classe sélectionnée pour l’instant.'
      : 'No class selected yet.';

  String get summaryHitDie => isFrench ? 'Dé de vie' : 'Hit die';

  String summaryClassSkillChoice(int choose, int from) => isFrench
      ? 'Compétences à choisir : $choose parmi $from'
      : 'Skills to choose: $choose from $from';

  String get summaryNoEquipmentOptions => isFrench
      ? 'Cette classe ne propose pas d’options d’équipement.'
      : 'This class offers no equipment options.';

  String get summaryEquipmentOptionsTitle => isFrench
      ? 'Options d’équipement de départ :'
      : 'Starting equipment options:';

  String get summaryNoSpeciesTraits => isFrench
      ? 'Aucun trait d’espèce sélectionné.'
      : 'No species traits selected.';

  String get summarySkillsNone => isFrench
      ? 'Aucune compétence choisie pour le moment.'
      : 'No skills chosen yet.';

  String summarySkillsSelection(int chosen, int required) => isFrench
      ? 'Sélection ($chosen/$required)'
      : 'Selection ($chosen/$required)';

  String summarySkillLine(String label, String ability) => isFrench
      ? '• $label ($ability)'
      : '• $label ($ability)';

  String get summaryEquipmentNone => isFrench
      ? 'Aucun équipement sélectionné.'
      : 'No equipment selected.';

  String get summaryStartingEquipmentTitle => isFrench
      ? 'Équipement de départ'
      : 'Starting equipment';

  String summaryPurchaseLine(String label, int qty, int cost) => isFrench
      ? '• $label ×$qty (${cost}cr)'
      : '• $label ×$qty (${cost}cr)';

  String get summaryStartingCredits => isFrench
      ? 'Crédits de départ'
      : 'Starting credits';
  String get summaryCurrentCost =>
      isFrench ? 'Coût actuel' : 'Current cost';
  String get summaryRemainingCredits => isFrench
      ? 'Crédits restants'
      : 'Remaining credits';
  String get summaryTotalWeight =>
      isFrench ? 'Poids total' : 'Total weight';
  String get summaryCarryCapacity =>
      isFrench ? 'Charge maximale' : 'Carry capacity';
  String get summaryUnknownWeight =>
      isFrench ? 'Indéterminé' : 'Unknown';
  String get summaryUnknownCapacity =>
      isFrench ? 'Indéterminée' : 'Unknown';

  String get quickCreatePrevious =>
      isFrench ? 'Précédent' : 'Previous';

  String get quickCreateNext => isFrench ? 'Suivant' : 'Next';

  String get quickCreateSubmit => isFrench ? 'Créer le personnage' : 'Create character';

  String get quickCreateNameLabel =>
      isFrench ? 'Nom du personnage' : 'Character name';

  String get quickCreateBackgroundLabel =>
      isFrench ? 'Historique'
      : 'Background';

  String get quickCreateBackgroundHint =>
      isFrench ? 'Sélectionnez un historique'
      : 'Select a background';

  String get quickCreateNameHint =>
      isFrench ? 'Nom du personnage'
      : 'Character name';

  String get quickCreateEquipmentReminder => isFrench
      ? 'Pensez à vérifier votre équipement avant de finaliser la création.'
      : 'Make sure to review your gear before finalizing the character.';

  String get quickCreateCharacterCreated =>
      isFrench ? 'Personnage créé'
      : 'Character created';

  String quickCreateCharacterSummary(Character character) {
    final buffer = StringBuffer();
    if (isFrench) {
      buffer
        ..writeln('Nom: ${character.name.value}')
        ..writeln('Espèce: ${character.speciesId.value}')
        ..writeln('Classe: ${character.classId.value}')
        ..writeln('BG: ${character.backgroundId.value}')
        ..writeln()
        ..writeln('HP: ${character.hitPoints.value}')
        ..writeln('Défense: ${character.defense.value}')
        ..writeln('Initiative: ${character.initiative.value}')
        ..writeln('Crédits: ${character.credits.value}')
        ..writeln('Inventaire: ${character.inventory.map((line) => "${line.itemId.value} x${line.quantity.value}").join(', ')}')
        ..write('Compétences: ${character.skills.map((skill) => skill.skillId).join(', ')}');
    } else {
      buffer
        ..writeln('Name: ${character.name.value}')
        ..writeln('Species: ${character.speciesId.value}')
        ..writeln('Class: ${character.classId.value}')
        ..writeln('Background: ${character.backgroundId.value}')
        ..writeln()
        ..writeln('HP: ${character.hitPoints.value}')
        ..writeln('Defense: ${character.defense.value}')
        ..writeln('Initiative: ${character.initiative.value}')
        ..writeln('Credits: ${character.credits.value}')
        ..writeln('Inventory: ${character.inventory.map((line) => "${line.itemId.value} x${line.quantity.value}").join(', ')}')
        ..write('Skills: ${character.skills.map((skill) => skill.skillId).join(', ')}');
    }
    return buffer.toString();
  }

  String get loadingLabel =>
      isFrench ? 'Chargement…' : 'Loading…';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
