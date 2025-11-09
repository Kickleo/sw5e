import 'package:flutter/widgets.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/localization/species_effect_localization.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_trait.dart';
import 'package:sw5e_manager/domain/characters/value_objects/skill_proficiency.dart';

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

  String get classPickerPrimaryAbilitiesTitle =>
      isFrench ? 'Caractéristiques principales' : 'Primary abilities';

  String get classPickerSavingThrowsTitle =>
      isFrench ? 'Jets de sauvegarde' : 'Saving throws';

  String get classPickerWeaponProficienciesTitle =>
      isFrench ? 'Maîtrises d’armes' : 'Weapon proficiencies';

  String get classPickerArmorProficienciesTitle =>
      isFrench ? 'Maîtrises d’armures' : 'Armor proficiencies';

  String get classPickerToolProficienciesTitle =>
      isFrench ? 'Maîtrises d’outils' : 'Tool proficiencies';

  String get classPickerLevel1FeaturesTitle =>
      isFrench ? 'Capacités de niveau 1' : 'Level 1 features';

  String get classMulticlassRequirementsTitle =>
      isFrench ? 'Prérequis de multi-classe' : 'Multiclass requirements';

  String classMulticlassRequirementValue(String abilityLabel, int score) =>
      '$abilityLabel $score';

  String classMulticlassRequirementsLine(String details) => isFrench
      ? 'Prérequis multi-classe : $details'
      : 'Multiclass requirements: $details';

  String get classPowerSectionTitle =>
      isFrench ? 'Pouvoirs' : 'Powers';

  String classPowerSourceLine(String sourceSlug) {
    final String label = _localizedPowerSource(sourceSlug);
    return isFrench
        ? 'Source de pouvoirs : $label'
        : 'Power source: $label';
  }

  String classPowerForceLine(bool allowed) => isFrench
      ? 'Pouvoirs de la Force : ${allowed ? 'autorisés' : 'interdits'}'
      : 'Force powers: ${allowed ? 'allowed' : 'not allowed'}';

  String classPowerTechLine(bool allowed) => isFrench
      ? 'Pouvoirs technologiques : ${allowed ? 'autorisés' : 'interdits'}'
      : 'Tech powers: ${allowed ? 'allowed' : 'not allowed'}';

  String classPowerProgressionLine(String? progressionSlug) {
    if (progressionSlug == null || progressionSlug.trim().isEmpty) {
      return '';
    }
    final String label = _localizedSpellcastingProgression(progressionSlug);
    return isFrench
        ? 'Progression de lanceur : $label'
        : 'Casting progression: $label';
  }

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

  String get speciesAbilityBonusesTitle => isFrench
      ? 'Augmentation de caractéristiques'
      : 'Ability score increases';

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

  static const Map<String, String> _abilityLabelsEn = <String, String>{
    'str': 'Strength',
    'dex': 'Dexterity',
    'con': 'Constitution',
    'int': 'Intelligence',
    'wis': 'Wisdom',
    'cha': 'Charisma',
  };

  static const Map<String, String> _abilityLabelsFr = <String, String>{
    'str': 'Force',
    'dex': 'Dextérité',
    'con': 'Constitution',
    'int': 'Intelligence',
    'wis': 'Sagesse',
    'cha': 'Charisme',
  };

  static const Map<String, String> _weaponCategoryLabelsEn = <String, String>{
    'simple': 'Simple weapons',
    'martial': 'Martial weapons',
    'simple-blasters': 'Simple blasters',
    'martial-blasters': 'Martial blasters',
  };

  static const Map<String, String> _weaponCategoryLabelsFr = <String, String>{
    'simple': 'Armes simples',
    'martial': 'Armes martiales',
    'simple-blasters': 'Blasters simples',
    'martial-blasters': 'Blasters martiaux',
  };

  static const Map<String, String> _armorCategoryLabelsEn = <String, String>{
    'light': 'Light armor',
    'medium': 'Medium armor',
    'heavy': 'Heavy armor',
    'shields': 'Shields',
  };

  static const Map<String, String> _armorCategoryLabelsFr = <String, String>{
    'light': 'Armure légère',
    'medium': 'Armure intermédiaire',
    'heavy': 'Armure lourde',
    'shields': 'Boucliers',
  };

  static const Map<String, String> _toolCategoryLabelsEn = <String, String>{
    'artisan-tools': "Artisan's tools",
    'musical-instrument': 'Musical instrument',
    'gaming-set': 'Gaming set',
    'vehicles-land': 'Land vehicles',
    'vehicles-air': 'Air vehicles',
    'vehicles-space': 'Space vehicles',
    'vehicles-sea': 'Water vehicles',
    'disguise-kit': 'Disguise kit',
    'forgery-kit': 'Forgery kit',
    'poisoners-kit': "Poisoner's kit",
    'hacking-kit': 'Hacking kit',
    'breathing-gear': 'Breathing gear',
  };

  static const Map<String, String> _toolCategoryLabelsFr = <String, String>{
    'artisan-tools': "Outils d'artisan",
    'musical-instrument': 'Instrument de musique',
    'gaming-set': 'Jeu de société',
    'vehicles-land': 'Véhicules terrestres',
    'vehicles-air': 'Véhicules aériens',
    'vehicles-space': 'Véhicules spatiaux',
    'vehicles-sea': 'Véhicules marins',
    'disguise-kit': 'Trousse de déguisement',
    'forgery-kit': 'Trousse de contrefaçon',
    'poisoners-kit': 'Trousse de poisonnier',
    'hacking-kit': 'Trousse de piratage',
    'breathing-gear': 'Équipement respiratoire',
  };

  String abilityLabel(
    String ability, {
    LocalizedText? catalogName,
  }) {
    if (catalogName != null) {
      final String resolved = localizedCatalogLabel(catalogName).trim();
      if (resolved.isNotEmpty) {
        return resolved;
      }
    }
    final String lower = ability.toLowerCase();
    final Map<String, String> defaults =
        isFrench ? _abilityLabelsFr : _abilityLabelsEn;
    final String? label = defaults[lower];
    if (label != null && label.trim().isNotEmpty) {
      return label;
    }
    final String? englishFallback = _abilityLabelsEn[lower];
    if (englishFallback != null && englishFallback.trim().isNotEmpty) {
      return englishFallback;
    }
    return ability.toUpperCase();
  }

  String classWeaponCategoryLabel(String slug) {
    final String lower = slug.toLowerCase();
    final Map<String, String> labels =
        isFrench ? _weaponCategoryLabelsFr : _weaponCategoryLabelsEn;
    final String? label = labels[lower];
    if (label != null && label.isNotEmpty) {
      return label;
    }
    return _titleCase(slug);
  }

  String classArmorCategoryLabel(String slug) {
    final String lower = slug.toLowerCase();
    final Map<String, String> labels =
        isFrench ? _armorCategoryLabelsFr : _armorCategoryLabelsEn;
    final String? label = labels[lower];
    if (label != null && label.isNotEmpty) {
      return label;
    }
    return _titleCase(slug);
  }

  String classToolCategoryLabel(String slug) {
    final String lower = slug.toLowerCase();
    final Map<String, String> labels =
        isFrench ? _toolCategoryLabelsFr : _toolCategoryLabelsEn;
    final String? label = labels[lower];
    if (label != null && label.isNotEmpty) {
      return label;
    }
    return _titleCase(slug);
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

  String skillStepAbilitySubtitle(
    String ability, {
    LocalizedText? catalogName,
  }) {
    final String label = abilityLabel(ability, catalogName: catalogName);
    final String abbreviation = abilityAbbreviation(ability);
    return isFrench
        ? 'Basée sur $label ($abbreviation)'
        : 'Based on $label ($abbreviation)';
  }

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

  String equipmentStepWeaponCategory(String category) => isFrench
      ? 'Catégorie : $category'
      : 'Category: $category';

  String equipmentStepWeaponDamage(String dice, String damageType) => isFrench
      ? 'Dégâts : $dice $damageType'
      : 'Damage: $dice $damageType';

  String equipmentStepDamageNotes(String notes) => isFrench
      ? 'Notes de dégâts : $notes'
      : 'Damage notes: $notes';

  String equipmentStepWeaponRange(int? primaryMeters, int? maximumMeters) {
    String formatValue(int meters) => '$meters m';
    final String prefix = isFrench ? 'Portée : ' : 'Range: ';
    if (primaryMeters != null && maximumMeters != null) {
      if (primaryMeters == maximumMeters) {
        return '$prefix${formatValue(primaryMeters)}';
      }
      return '$prefix${formatValue(primaryMeters)} / ${formatValue(maximumMeters)}';
    }
    if (primaryMeters != null) {
      return '$prefix${formatValue(primaryMeters)}';
    }
    if (maximumMeters != null) {
      return '$prefix${formatValue(maximumMeters)}';
    }
    return '$prefix—';
  }

  String equipmentStepWeaponProperties(String properties) => isFrench
      ? 'Propriétés : $properties'
      : 'Properties: $properties';

  String equipmentStepRarity(String rarity) => isFrench
      ? 'Rareté : $rarity'
      : 'Rarity: $rarity';

  String equipmentDetailsWeight(String weight) => isFrench
      ? 'Poids : $weight'
      : 'Weight: $weight';

  List<String> equipmentMetadataLines(EquipmentDef def) {
    final List<String> lines = <String>[];

    if (def.weightG > 0) {
      lines.add(equipmentDetailsWeight(_formatWeight(def.weightG)));
    }

    if (def.weaponDamage.isNotEmpty) {
      final List<String> segments = def.weaponDamage
          .map((WeaponDamage damage) {
            final String dice = _formatWeaponDice(damage);
            final String typeLabel = damage.damageTypeName != null
                ? localizedCatalogLabel(damage.damageTypeName!).trim()
                : _titleCase(damage.damageType);
            if (dice.trim().isEmpty && typeLabel.isEmpty) {
              return '';
            }
            if (typeLabel.isEmpty) {
              return dice;
            }
            if (dice.trim().isEmpty) {
              return typeLabel;
            }
            return '$dice $typeLabel';
          })
          .where((String value) => value.trim().isNotEmpty)
          .toList(growable: false);
      if (segments.isNotEmpty) {
        final String joined = segments.join(', ');
        lines.add(isFrench ? 'Dégâts : $joined' : 'Damage: $joined');
      }
    }

    for (final WeaponDamage damage in def.weaponDamage) {
      final LocalizedText? notes = damage.damageTypeNotes;
      if (notes == null) {
        continue;
      }
      final String label = localizedCatalogLabel(notes).trim();
      if (label.isNotEmpty) {
        lines.add(equipmentStepDamageNotes(label));
      }
    }

    if (def.weaponRange != null) {
      lines.add(
        equipmentStepWeaponRange(
          def.weaponRange!.primary,
          def.weaponRange!.maximum,
        ),
      );
    }

    if (def.weaponProperties.isNotEmpty) {
      final String properties = def.weaponProperties
          .map(_titleCase)
          .where((String value) => value.trim().isNotEmpty)
          .join(', ');
      if (properties.isNotEmpty) {
        lines.add(equipmentStepWeaponProperties(properties));
      }
    }

    if (def.rarity != null && def.rarity!.trim().isNotEmpty) {
      lines.add(equipmentStepRarity(_titleCase(def.rarity!)));
    }

    return lines;
  }

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

  String get characterCustomizationOptionsTitle => isFrench
      ? 'Options de personnalisation'
      : 'Customization options';

  String get characterForcePowersTitle =>
      isFrench ? 'Pouvoirs de la Force' : 'Force powers';

  String get characterTechPowersTitle =>
      isFrench ? 'Pouvoirs technologiques' : 'Tech powers';

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
  String get summaryCustomizationOptionsTitle => isFrench
      ? 'Options de personnalisation'
      : 'Customization options';
  String get summaryForcePowersTitle =>
      isFrench ? 'Pouvoirs de la Force' : 'Force powers';
  String get summaryTechPowersTitle =>
      isFrench ? 'Pouvoirs technologiques' : 'Tech powers';
  String get summaryClassLevel1FeaturesTitle =>
      isFrench ? 'Capacités de niveau 1' : 'Level 1 features';
  String get summaryBackgroundDetails =>
      isFrench ? 'Historique' : 'Background';
  String get summaryNoBackgroundSelected => isFrench
      ? 'Aucun historique sélectionné.'
      : 'No background selected.';
  String get summaryBackgroundSkillsTitle =>
      isFrench ? 'Compétences accordées' : 'Granted skills';
  String summaryBackgroundLanguagesPick(int count) => isFrench
      ? 'Langues supplémentaires à choisir : $count'
      : 'Additional languages to choose: $count';
  String get summaryBackgroundToolsTitle =>
      isFrench ? 'Maîtrises d’outils' : 'Tool proficiencies';
  String get summaryBackgroundFeatureTitle =>
      isFrench ? 'Capacité d’historique' : 'Background feature';
  String get summaryBackgroundPersonalityTraits =>
      isFrench ? 'Traits de personnalité' : 'Personality traits';
  String get summaryBackgroundPersonalityIdeals =>
      isFrench ? 'Idéaux' : 'Ideals';
  String get summaryBackgroundPersonalityBonds =>
      isFrench ? 'Liens' : 'Bonds';
  String get summaryBackgroundPersonalityFlaws =>
      isFrench ? 'Défauts' : 'Flaws';
  String get summaryBackgroundEquipmentTitle =>
      isFrench ? 'Équipement associé' : 'Background equipment';
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

  String get quickCreateBackgroundSkillsTitle =>
      isFrench ? 'Compétences accordées' : 'Granted skills';

  String quickCreateBackgroundLanguagesPick(int count) {
    final bool plural = count > 1;
    final String suffix = plural ? 's' : '';
    return isFrench
        ? 'Choisissez $count langue$suffix supplémentaire$suffix.'
        : 'Choose $count additional language$suffix.';
  }

  String get quickCreateBackgroundToolsTitle =>
      isFrench ? 'Maîtrises d’outils' : 'Tool proficiencies';

  String get quickCreateBackgroundFeatureTitle =>
      isFrench ? 'Capacité d’historique' : 'Background feature';

  String get quickCreateBackgroundPersonalityTraitsTitle =>
      isFrench ? 'Traits de personnalité' : 'Personality traits';

  String get quickCreateBackgroundPersonalityIdealsTitle =>
      isFrench ? 'Idéaux' : 'Ideals';

  String get quickCreateBackgroundPersonalityBondsTitle =>
      isFrench ? 'Liens' : 'Bonds';

  String get quickCreateBackgroundPersonalityFlawsTitle =>
      isFrench ? 'Défauts' : 'Flaws';

  String get quickCreateBackgroundEquipmentTitle =>
      isFrench ? 'Équipement associé' : 'Background equipment';

  String get quickCreateCharacterCreated =>
      isFrench ? 'Personnage créé'
      : 'Character created';

  String get languagesTitle => isFrench ? 'Langues' : 'Languages';

  String languageScriptLabel(String script) =>
      isFrench ? 'Alphabet : $script' : 'Script: $script';

  String languageTypicalSpeakersLabel(String speakers) => isFrench
      ? 'Locuteurs typiques : $speakers'
      : 'Typical speakers: $speakers';

  String quickCreateCharacterSummary(
    Character character, {
    Map<String, LocalizedText> speciesNames = const <String, LocalizedText>{},
    Map<String, LocalizedText> classNames = const <String, LocalizedText>{},
    Map<String, ClassDef> classDefinitions = const <String, ClassDef>{},
    Map<String, LocalizedText> backgroundNames =
        const <String, LocalizedText>{},
    Map<String, BackgroundDef> backgroundDefinitions =
        const <String, BackgroundDef>{},
    Map<String, SkillDef> skillDefinitions = const <String, SkillDef>{},
    Map<String, EquipmentDef> equipmentDefinitions =
        const <String, EquipmentDef>{},
    Map<String, TraitDef> traitDefinitions = const <String, TraitDef>{},
    Map<String, AbilityDef> abilityDefinitions = const <String, AbilityDef>{},
    Map<String, CustomizationOptionDef> customizationOptionDefinitions =
        const <String, CustomizationOptionDef>{},
    Map<String, PowerDef> forcePowerDefinitions = const <String, PowerDef>{},
    Map<String, PowerDef> techPowerDefinitions = const <String, PowerDef>{},
    SpeciesDef? speciesDefinition,
    List<LanguageDef> speciesLanguages = const <LanguageDef>[],
  }) {
    final String species =
        _resolveCatalogName(speciesNames, character.speciesId.value);
    final String className =
        _resolveCatalogName(classNames, character.classId.value);
    final String background =
        _resolveCatalogName(backgroundNames, character.backgroundId.value);

    final ClassDef? classDefinition =
        classDefinitions[character.classId.value];

    final BackgroundDef? backgroundDefinition =
        backgroundDefinitions[character.backgroundId.value];

    final List<String> abilityBonusLines = <String>[];
    if (speciesDefinition != null &&
        speciesDefinition.abilityBonuses.isNotEmpty) {
      final SpeciesAbilityBonusFormatter formatter = SpeciesAbilityBonusFormatter(
        SpeciesEffectLocalizationCatalog.forLanguage(languageCode),
      );
      abilityBonusLines.addAll(
        speciesDefinition.abilityBonuses
            .where((SpeciesAbilityBonus bonus) => bonus.amount != 0)
            .map(formatter.format)
            .map((String value) => value.trim())
            .where((String value) => value.isNotEmpty),
      );
    }

    final String skills = character.skills
        .map((SkillProficiency skill) =>
            _resolveSkillName(skillDefinitions, skill.skillId))
        .join(', ');

    final String inventory = character.inventory.map((InventoryLine line) {
      final EquipmentDef? def = equipmentDefinitions[line.itemId.value];
      final String label;
      if (def != null) {
        final String resolved = localizedCatalogLabel(def.name).trim();
        label = resolved.isNotEmpty
            ? resolved
            : _resolveEquipmentName(equipmentDefinitions, line.itemId.value);
      } else {
        label = _resolveEquipmentName(equipmentDefinitions, line.itemId.value);
      }
      final String base = '$label x${line.quantity.value}';
      if (def == null) {
        return base;
      }
      final List<String> metadata = equipmentMetadataLines(def);
      if (metadata.isEmpty) {
        return base;
      }
      final String details = metadata.join(isFrench ? ' ; ' : '; ');
      return '$base — $details';
    }).join(', ');

    final String traits = character.speciesTraits
        .map(
          (CharacterTrait trait) =>
              _resolveTraitName(traitDefinitions, trait.id.value),
        )
        .where((String label) => label.isNotEmpty)
        .join(', ');

    final List<String> classLines = <String>[];
    if (classDefinition != null) {
      if (classDefinition.powerSource != null &&
          classDefinition.powerSource!.trim().isNotEmpty) {
        classLines.add(classPowerSourceLine(classDefinition.powerSource!));
      }
      final ClassPowerList? powerList = classDefinition.powerList;
      if (powerList != null) {
        classLines.add(classPowerForceLine(powerList.forceAllowed));
        classLines.add(classPowerTechLine(powerList.techAllowed));
        final String progressionLine =
            classPowerProgressionLine(powerList.spellcastingProgression);
        if (progressionLine.isNotEmpty) {
          classLines.add(progressionLine);
        }
      }

      final ClassMulticlassing? multiclassing = classDefinition.multiclassing;
      if (multiclassing != null &&
          multiclassing.hasAbilityRequirements) {
        final List<MapEntry<String, int>> requirements =
            multiclassing.abilityRequirements.entries.toList()
              ..sort((MapEntry<String, int> a, MapEntry<String, int> b) =>
                  a.key.compareTo(b.key));
        final List<String> requirementLabels = <String>[];
        for (final MapEntry<String, int> entry in requirements) {
          final AbilityDef? ability = abilityDefinitions[entry.key];
          final String abilityLabel;
          if (ability != null) {
            final String localized =
                localizedCatalogLabel(ability.name).trim();
            if (localized.isNotEmpty) {
              abilityLabel = localized;
            } else if (ability.abbreviation.trim().isNotEmpty) {
              abilityLabel = ability.abbreviation.trim();
            } else {
              abilityLabel = entry.key.toUpperCase();
            }
          } else {
            abilityLabel = entry.key.toUpperCase();
          }
          requirementLabels.add(
            classMulticlassRequirementValue(abilityLabel, entry.value),
          );
        }
        if (requirementLabels.isNotEmpty) {
          classLines.add(
            classMulticlassRequirementsLine(requirementLabels.join(', ')),
          );
        }
      }

      final List<ClassFeature> features = classDefinition.level1.classFeatures;
      if (features.isNotEmpty) {
        for (final ClassFeature feature in features) {
          final String name = localizedCatalogLabel(feature.name).trim();
          final List<String> details = <String>[];
          final String description =
              _localizedOptional(feature.description).trim();
          if (description.isNotEmpty) {
            details.add(description);
          }
          final List<String> effectTexts = feature.effects
              .map((CatalogFeatureEffect effect) =>
                  _localizedOptional(effect.text))
              .where((String value) => value.isNotEmpty)
              .toList();
          details.addAll(effectTexts);

          if (name.isNotEmpty && details.isNotEmpty) {
            classLines.add('$name: ${details.join(' ')}');
          } else if (name.isNotEmpty) {
            classLines.add(name);
          } else if (details.isNotEmpty) {
            classLines.add(details.join(' '));
          }
        }
      }
    }

    final List<String> backgroundLines = <String>[];
    if (backgroundDefinition != null) {
      final List<String> grantedSkillLabels = backgroundDefinition.grantedSkills
          .map((String id) => _resolveSkillName(skillDefinitions, id))
          .where((String label) => label.isNotEmpty)
          .toList();
      if (grantedSkillLabels.isNotEmpty) {
        backgroundLines.add(
          '$summaryBackgroundSkillsTitle: ${grantedSkillLabels.join(', ')}',
        );
      }

      if (backgroundDefinition.languagesPick > 0) {
        backgroundLines
            .add(summaryBackgroundLanguagesPick(backgroundDefinition.languagesPick));
      }

      final List<String> toolLabels = backgroundDefinition.toolProficiencies
          .map((String id) => _resolveEquipmentName(equipmentDefinitions, id))
          .where((String label) => label.isNotEmpty)
          .toList();
      if (toolLabels.isNotEmpty) {
        backgroundLines.add(
          '$summaryBackgroundToolsTitle: ${toolLabels.join(', ')}',
        );
      }

      final BackgroundFeature? feature = backgroundDefinition.feature;
      if (feature != null) {
        final String featureName = localizedCatalogLabel(feature.name).trim();
        if (featureName.isNotEmpty) {
          backgroundLines.add(
            '$summaryBackgroundFeatureTitle: $featureName',
          );
        }

        final List<String> effectTexts = feature.effects
            .map((CatalogFeatureEffect effect) =>
                _localizedOptional(effect.text))
            .where((String text) => text.isNotEmpty)
            .toList();
        backgroundLines.addAll(effectTexts);
      }

      final BackgroundPersonality? personality = backgroundDefinition.personality;
      if (personality != null) {
        void addPersonalitySection(
          String title,
          List<LocalizedText> values,
        ) {
          if (values.isEmpty) {
            return;
          }
          final List<String> labels = values
              .map(localizedCatalogLabel)
              .map((String value) => value.trim())
              .where((String value) => value.isNotEmpty)
              .toList();
          if (labels.isEmpty) {
            return;
          }
          backgroundLines.add('$title: ${labels.join(', ')}');
        }

        addPersonalitySection(
          summaryBackgroundPersonalityTraits,
          personality.traits,
        );
        addPersonalitySection(
          summaryBackgroundPersonalityIdeals,
          personality.ideals,
        );
        addPersonalitySection(
          summaryBackgroundPersonalityBonds,
          personality.bonds,
        );
        addPersonalitySection(
          summaryBackgroundPersonalityFlaws,
          personality.flaws,
        );
      }

      if (backgroundDefinition.equipment.isNotEmpty) {
        final List<String> equipmentLines = <String>[];
        for (final BackgroundEquipmentGrant grant
            in backgroundDefinition.equipment) {
          final EquipmentDef? def = equipmentDefinitions[grant.itemId];
          final String resolved = def != null
              ? localizedCatalogLabel(def.name).trim()
              : '';
          final String label = resolved.isNotEmpty
              ? resolved
              : _resolveEquipmentName(equipmentDefinitions, grant.itemId);
          if (label.isEmpty) {
            continue;
          }
          if (def == null) {
            equipmentLines.add('$label x${grant.quantity}');
            continue;
          }
          final List<String> metadata = equipmentMetadataLines(def);
          if (metadata.isEmpty) {
            equipmentLines.add('$label x${grant.quantity}');
            continue;
          }
          final String details = metadata.join(isFrench ? ' ; ' : '; ');
          equipmentLines.add('$label x${grant.quantity} — $details');
        }
        if (equipmentLines.isNotEmpty) {
          backgroundLines.add(
            '${summaryBackgroundEquipmentTitle}: ${equipmentLines.join(', ')}',
          );
        }
      }
    }

    final List<String> customizationLines = <String>[];
    for (final String optionId in character.customizationOptionIds) {
      final CustomizationOptionDef? option =
          customizationOptionDefinitions[optionId];
      String label = _titleCase(optionId);
      if (option != null) {
        final String localized = localizedCatalogLabel(option.name).trim();
        if (localized.isNotEmpty) {
          label = localized;
        }
      }
      label = label.trim();
      if (label.isEmpty) {
        continue;
      }
      final Iterable<String>? localizedEffects = option?.effects?.map(
        (CatalogFeatureEffect effect) =>
            _localizedOptional(effect.text).trim(),
      );
      final List<String> effectTexts = localizedEffects
              ?.where((String value) => value.isNotEmpty)
              .toList() ??
          const <String>[];
      if (effectTexts.isNotEmpty) {
        final String details = effectTexts.join(isFrench ? ' ; ' : '; ');
        customizationLines.add('$label: $details');
      } else {
        customizationLines.add(label);
      }
    }

    String powerLine(PowerDef? def, String id) {
      String label = _titleCase(id);
      if (def != null) {
        final String localized = localizedCatalogLabel(def.name).trim();
        if (localized.isNotEmpty) {
          label = localized;
        }
      }
      label = label.trim();
      if (label.isEmpty) {
        return '';
      }
      if (def == null) {
        return label;
      }
      final String description =
          localizedCatalogLabel(def.description).trim();
      if (description.isEmpty) {
        return label;
      }
      return '$label: $description';
    }

    final List<String> forcePowerLines = character.forcePowerIds
        .map((String id) => powerLine(forcePowerDefinitions[id], id))
        .where((String value) => value.trim().isNotEmpty)
        .toList();

    final List<String> techPowerLines = character.techPowerIds
        .map((String id) => powerLine(techPowerDefinitions[id], id))
        .where((String value) => value.trim().isNotEmpty)
        .toList();

    final List<String> languageLabels = <String>[];
    final Set<String> normalizedLanguages = <String>{};
    for (final LanguageDef language in speciesLanguages) {
      final String label = localizedCatalogLabel(language.name).trim();
      if (label.isEmpty) {
        continue;
      }
      final String normalized = label.toLowerCase();
      if (!normalizedLanguages.add(normalized)) {
        continue;
      }
      languageLabels.add(label);
    }

    String languages;
    if (languageLabels.isNotEmpty) {
      languages = languageLabels.join(', ');
    } else if (speciesDefinition?.languages != null) {
      languages =
          localizedCatalogLabel(speciesDefinition!.languages!).trim();
    } else {
      languages = '';
    }

    final String abilityBonusesText =
        abilityBonusLines.isNotEmpty ? abilityBonusLines.join(', ') : '';

    final buffer = StringBuffer();
    if (isFrench) {
      buffer
        ..writeln('Nom : ${character.name.value}')
        ..writeln('Espèce : $species')
        ..writeln('Classe : $className')
        ..writeln('Historique : $background')
        ..writeln()
        ..writeln('PV : ${character.hitPoints.value}')
        ..writeln('Défense : ${character.defense.value}')
        ..writeln('Initiative : ${character.initiative.value}')
        ..writeln('Crédits : ${character.credits.value}')
        ..writeln(
          '$speciesAbilityBonusesTitle : ${abilityBonusesText.isEmpty ? "—" : abilityBonusesText}',
        )
        ..writeln('Langues : ${languages.isEmpty ? "—" : languages}')
        ..writeln('Inventaire : $inventory')
        ..writeln('Compétences : $skills');
      if (traits.isNotEmpty) {
        buffer.writeln('Traits : $traits');
      }
      if (classLines.isNotEmpty) {
        buffer
          ..writeln()
          ..writeln('$summaryClassFeatures :');
        for (final String line in classLines) {
          buffer.writeln('• $line');
        }
      }
      if (backgroundLines.isNotEmpty) {
        buffer
          ..writeln()
          ..writeln('$summaryBackgroundDetails :');
        for (final String line in backgroundLines) {
          buffer.writeln('• $line');
        }
      }
      if (customizationLines.isNotEmpty) {
        buffer
          ..writeln()
          ..writeln('$summaryCustomizationOptionsTitle :');
        for (final String line in customizationLines) {
          buffer.writeln('• $line');
        }
      }
      if (forcePowerLines.isNotEmpty) {
        buffer
          ..writeln()
          ..writeln('$summaryForcePowersTitle :');
        for (final String line in forcePowerLines) {
          buffer.writeln('• $line');
        }
      }
      if (techPowerLines.isNotEmpty) {
        buffer
          ..writeln()
          ..writeln('$summaryTechPowersTitle :');
        for (final String line in techPowerLines) {
          buffer.writeln('• $line');
        }
      }
    } else {
      buffer
        ..writeln('Name: ${character.name.value}')
        ..writeln('Species: $species')
        ..writeln('Class: $className')
        ..writeln('Background: $background')
        ..writeln()
        ..writeln('HP: ${character.hitPoints.value}')
        ..writeln('Defense: ${character.defense.value}')
        ..writeln('Initiative: ${character.initiative.value}')
        ..writeln('Credits: ${character.credits.value}')
        ..writeln(
          '$speciesAbilityBonusesTitle: ${abilityBonusesText.isEmpty ? "—" : abilityBonusesText}',
        )
        ..writeln('Languages: ${languages.isEmpty ? "—" : languages}')
        ..writeln('Inventory: $inventory')
        ..writeln('Skills: $skills');
      if (traits.isNotEmpty) {
        buffer.writeln('Traits: $traits');
      }
      if (classLines.isNotEmpty) {
        buffer
          ..writeln()
          ..writeln('$summaryClassFeatures:');
        for (final String line in classLines) {
          buffer.writeln('• $line');
        }
      }
      if (backgroundLines.isNotEmpty) {
        buffer
          ..writeln()
          ..writeln('$summaryBackgroundDetails:');
        for (final String line in backgroundLines) {
          buffer.writeln('• $line');
        }
      }
      if (customizationLines.isNotEmpty) {
        buffer
          ..writeln()
          ..writeln('$summaryCustomizationOptionsTitle:');
        for (final String line in customizationLines) {
          buffer.writeln('• $line');
        }
      }
      if (forcePowerLines.isNotEmpty) {
        buffer
          ..writeln()
          ..writeln('$summaryForcePowersTitle:');
        for (final String line in forcePowerLines) {
          buffer.writeln('• $line');
        }
      }
      if (techPowerLines.isNotEmpty) {
        buffer
          ..writeln()
          ..writeln('$summaryTechPowersTitle:');
        for (final String line in techPowerLines) {
          buffer.writeln('• $line');
        }
      }
    }
    return buffer.toString();
  }

  String savedCharacterShareSubject(String name) =>
      isFrench ? 'Personnage SW5e : $name' : 'SW5e character: $name';

  String _resolveCatalogName(
    Map<String, LocalizedText> names,
    String id,
  ) {
    final LocalizedText? text = names[id];
    if (text != null) {
      final String label = localizedCatalogLabel(text).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }

  String _resolveSkillName(Map<String, SkillDef> defs, String id) {
    final SkillDef? def = defs[id];
    if (def != null) {
      final String label = localizedCatalogLabel(def.name).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }

  String _resolveEquipmentName(Map<String, EquipmentDef> defs, String id) {
    final EquipmentDef? def = defs[id];
    if (def != null) {
      final String label = localizedCatalogLabel(def.name).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }

  String _resolveTraitName(Map<String, TraitDef> defs, String id) {
    final TraitDef? def = defs[id];
    if (def != null) {
      final String label = localizedCatalogLabel(def.name).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }

  String _localizedPowerSource(String slug) {
    final String normalized = slug.trim().toLowerCase();
    switch (normalized) {
      case 'force':
        return isFrench ? 'Force' : 'Force';
      case 'tech':
        return isFrench ? 'Technologie' : 'Tech';
      case 'martial':
        return isFrench ? 'Martiale' : 'Martial';
      case 'primal':
        return isFrench ? 'Primale' : 'Primal';
      default:
        return _titleCase(normalized);
    }
  }

  String _localizedSpellcastingProgression(String slug) {
    final String normalized = slug.trim().toLowerCase();
    switch (normalized) {
      case 'full':
        return isFrench ? 'Lanceur complet' : 'Full caster';
      case 'half':
        return isFrench ? 'Lanceur moitié' : 'Half caster';
      case 'third':
        return isFrench ? 'Lanceur tiers' : 'Third caster';
      case 'quarter':
        return isFrench ? 'Lanceur quart' : 'Quarter caster';
      case 'artificer':
        return isFrench ? 'Progression artificier' : 'Artificer progression';
      case 'none':
        return isFrench ? 'Aucune' : 'None';
      default:
        return _titleCase(normalized);
    }
  }

  String _localizedOptional(LocalizedText? text) {
    if (text == null) {
      return '';
    }
    final String label = localizedCatalogLabel(text).trim();
    return label;
  }

  String _formatWeaponDice(WeaponDamage damage) {
    final int? count = damage.diceCount;
    final int? die = damage.diceDie;
    final int? modifier = damage.diceModifier;
    if (count == null || die == null) {
      if (modifier != null && modifier != 0) {
        return modifier > 0 ? '+$modifier' : '$modifier';
      }
      return '';
    }
    final String base = '${count}d$die';
    if (modifier == null || modifier == 0) {
      return base;
    }
    final String mod = modifier > 0 ? '+$modifier' : '$modifier';
    return '$base$mod';
  }

  String _formatWeight(int grams) {
    final double kilograms = grams / 1000;
    if (kilograms >= 10 || kilograms <= -10) {
      return '${kilograms.toStringAsFixed(1)} kg';
    }
    return '${kilograms.toStringAsFixed(2)} kg';
  }

  String _titleCase(String slug) {
    return slug
        .split(RegExp(r'[\-_.]'))
        .where((String part) => part.isNotEmpty)
        .map(
          (String part) =>
              part[0].toUpperCase() + part.substring(1).toLowerCase(),
        )
        .join(' ');
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
