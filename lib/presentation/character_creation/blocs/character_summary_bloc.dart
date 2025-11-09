/// ---------------------------------------------------------------------------
/// Fichier : lib/presentation/character_creation/blocs/character_summary_bloc.dart
/// Rôle : ViewModel MVVM implémenté avec BLoC pour orchestrer l'écran de résumé
///        des personnages sauvegardés (chargement, sélection, partage).
/// Dépendances : ListSavedCharacters (use case domaine), AppLogger,
///        AppResult/AppFailure, entités Character/CharacterId.
/// Exemple d'usage :
///   final bloc = CharacterSummaryBloc(
///     listSavedCharacters: useCase,
///     catalog: catalogRepository,
///     logger: logger,
///   )..add(const CharacterSummaryStarted());
/// ---------------------------------------------------------------------------
library;
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/common/errors/app_failure.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/services/catalog_lookup_service.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/skill_proficiency.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/services/catalog_lookup_service.dart';

/// CharacterSummaryEvent = intention utilisateur/système pour faire évoluer
/// l'état de la vue.
sealed class CharacterSummaryEvent extends Equatable {
  /// Constructeur const par défaut.
  const CharacterSummaryEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// CharacterSummaryStarted = déclenchement initial du chargement catalogue.
class CharacterSummaryStarted extends CharacterSummaryEvent {
  /// Constructeur const.
  const CharacterSummaryStarted();
}

/// CharacterSummaryRefreshRequested = demande explicite de rafraîchissement.
class CharacterSummaryRefreshRequested extends CharacterSummaryEvent {
  /// Constructeur const.
  const CharacterSummaryRefreshRequested();
}

/// CharacterSummaryCharacterSelected = sélection d'un personnage par l'utilisateur.
class CharacterSummaryCharacterSelected extends CharacterSummaryEvent {
  /// Crée un événement pour suivre l'identifiant choisi.
  const CharacterSummaryCharacterSelected(this.characterId);

  /// Identifiant du personnage sélectionné.
  final CharacterId characterId;

  @override
  List<Object?> get props => <Object?>[characterId];
}

/// CharacterSummaryShareRequested = intention de partager le personnage courant.
class CharacterSummaryShareRequested extends CharacterSummaryEvent {
  /// Constructeur const.
  const CharacterSummaryShareRequested(this.l10n);

  /// Localisation utilisée pour formater le message de partage.
  final AppLocalizations l10n;

  @override
  List<Object?> get props => <Object?>[l10n.languageCode];
}

/// CharacterSummaryShareAcknowledged = notification UI indiquant que le partage
/// a été effectué (ou annulé) pour relâcher l'état `isSharing`.
class CharacterSummaryShareAcknowledged extends CharacterSummaryEvent {
  /// Constructeur const.
  const CharacterSummaryShareAcknowledged();
}

/// CharacterSummaryShareIntent = données transmises à l'UI pour lancer le partage.
class CharacterSummaryShareIntent extends Equatable {
  /// Initialise l'intention avec sujet + message texte.
  const CharacterSummaryShareIntent({required this.subject, required this.message});

  /// Sujet utilisé par `Share.share`.
  final String subject;

  /// Contenu textuel à partager.
  final String message;

  @override
  List<Object?> get props => <Object?>[subject, message];
}

/// CharacterSummaryState = photographie immuable de la vue résumé.
class CharacterSummaryState extends Equatable {
  /// Constructeur complet.
  const CharacterSummaryState({
    required this.isLoading,
    required this.characters,
    required this.selectedId,
    required this.failure,
    required this.hasLoadedOnce,
    required this.isSharing,
    required this.shareIntent,
    required this.speciesDefinitions,
    required this.speciesNames,
    required this.classNames,
    required this.classDefinitions,
    required this.backgroundNames,
    required this.backgroundDefinitions,
    required this.skillDefinitions,
    required this.equipmentDefinitions,
    required this.traitDefinitions,
    required this.languageDefinitions,
    required this.abilityDefinitions,
    required this.customizationOptionDefinitions,
    required this.forcePowerDefinitions,
    required this.techPowerDefinitions,
  });

  /// Fabrique initiale (aucun chargement effectué).
  factory CharacterSummaryState.initial() => const CharacterSummaryState(
        isLoading: false,
        characters: <Character>[],
        selectedId: null,
        failure: null,
        hasLoadedOnce: false,
        isSharing: false,
        shareIntent: null,
        speciesDefinitions: <String, SpeciesDef>{},
        speciesNames: <String, LocalizedText>{},
        classNames: <String, LocalizedText>{},
        classDefinitions: <String, ClassDef>{},
        backgroundNames: <String, LocalizedText>{},
        backgroundDefinitions: <String, BackgroundDef>{},
        skillDefinitions: <String, SkillDef>{},
        equipmentDefinitions: <String, EquipmentDef>{},
        traitDefinitions: <String, TraitDef>{},
        languageDefinitions: <String, LanguageDef>{},
        abilityDefinitions: <String, AbilityDef>{},
        customizationOptionDefinitions:
            <String, CustomizationOptionDef>{},
        forcePowerDefinitions: <String, PowerDef>{},
        techPowerDefinitions: <String, PowerDef>{},
      );

  /// Indique si un chargement est en cours.
  final bool isLoading;

  /// Liste des personnages disponibles.
  final List<Character> characters;

  /// Identifiant explicitement sélectionné.
  final CharacterId? selectedId;

  /// Échec éventuel associé au dernier chargement/action.
  final AppFailure? failure;

  /// Indique si au moins un chargement a déjà abouti (succès/erreur).
  final bool hasLoadedOnce;

  /// Indique si une opération de partage est en préparation.
  final bool isSharing;

  /// Éventuelle intention de partage à exécuter par la vue.
  final CharacterSummaryShareIntent? shareIntent;

  /// Définitions complètes des espèces référencées (langues, vitesse, etc.).
  final Map<String, SpeciesDef> speciesDefinitions;

  /// Libellés localisés des espèces référencées par les personnages.
  final Map<String, LocalizedText> speciesNames;

  /// Libellés localisés des classes référencées par les personnages.
  final Map<String, LocalizedText> classNames;

  /// Définitions complètes des classes référencées (niveau 1, maîtrises, traits).
  final Map<String, ClassDef> classDefinitions;

  /// Libellés localisés des historiques référencés par les personnages.
  final Map<String, LocalizedText> backgroundNames;

  /// Définitions complètes des historiques référencés (caractéristiques, équipement).
  final Map<String, BackgroundDef> backgroundDefinitions;

  /// Définitions des compétences utilisées par les personnages.
  final Map<String, SkillDef> skillDefinitions;

  /// Définitions d'équipement présentes dans les inventaires sauvegardés.
  final Map<String, EquipmentDef> equipmentDefinitions;

  /// Définitions des traits d'espèce possédés par les personnages.
  final Map<String, TraitDef> traitDefinitions;

  /// Définitions des langues référencées par les espèces des personnages.
  final Map<String, LanguageDef> languageDefinitions;

  /// Définitions des caractéristiques référencées par les personnages.
  final Map<String, AbilityDef> abilityDefinitions;

  /// Définitions des options de personnalisation référencées.
  final Map<String, CustomizationOptionDef> customizationOptionDefinitions;

  /// Définitions des pouvoirs de Force référencés par les personnages.
  final Map<String, PowerDef> forcePowerDefinitions;

  /// Définitions des pouvoirs technologiques référencés par les personnages.
  final Map<String, PowerDef> techPowerDefinitions;

  /// Renvoie le personnage actuellement sélectionné (ou le dernier connu en fallback).
  Character? get selectedCharacter {
    if (characters.isEmpty) {
      return null;
    }
    if (selectedId == null) {
      return characters.last;
    }
    return characters.firstWhere(
      (Character character) => character.id == selectedId,
      orElse: () => characters.last,
    );
  }

  /// Indique si une erreur est présente.
  bool get hasError => failure != null;
  String? get errorMessage =>
      failure?.toDisplayMessage(includeCode: true);

  /// Indique si la liste est vide.
  bool get isEmpty => characters.isEmpty;

  /// Copie immuable avec remplacement partiel.
  CharacterSummaryState copyWith({
    bool? isLoading,
    List<Character>? characters,
    CharacterId? selectedId,
    bool clearSelection = false,
    AppFailure? failure,
    bool clearFailure = false,
    bool? hasLoadedOnce,
    bool? isSharing,
    CharacterSummaryShareIntent? shareIntent,
    bool resetShareIntent = false,
    Map<String, SpeciesDef>? speciesDefinitions,
    Map<String, LocalizedText>? speciesNames,
    Map<String, LocalizedText>? classNames,
    Map<String, ClassDef>? classDefinitions,
    Map<String, LocalizedText>? backgroundNames,
    Map<String, BackgroundDef>? backgroundDefinitions,
    Map<String, SkillDef>? skillDefinitions,
    Map<String, EquipmentDef>? equipmentDefinitions,
    Map<String, TraitDef>? traitDefinitions,
    Map<String, LanguageDef>? languageDefinitions,
    Map<String, AbilityDef>? abilityDefinitions,
    Map<String, CustomizationOptionDef>? customizationOptionDefinitions,
    Map<String, PowerDef>? forcePowerDefinitions,
    Map<String, PowerDef>? techPowerDefinitions,
  }) {
    return CharacterSummaryState(
      isLoading: isLoading ?? this.isLoading,
      characters: characters != null
          ? List<Character>.unmodifiable(characters)
          : this.characters,
      selectedId: clearSelection
          ? null
          : (selectedId ?? this.selectedId),
      failure: clearFailure ? null : (failure ?? this.failure),
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      isSharing: isSharing ?? this.isSharing,
      shareIntent:
          resetShareIntent ? null : (shareIntent ?? this.shareIntent),
      speciesDefinitions: speciesDefinitions ?? this.speciesDefinitions,
      speciesNames: speciesNames ?? this.speciesNames,
      classNames: classNames ?? this.classNames,
      classDefinitions: classDefinitions ?? this.classDefinitions,
      backgroundNames: backgroundNames ?? this.backgroundNames,
      backgroundDefinitions:
          backgroundDefinitions ?? this.backgroundDefinitions,
      skillDefinitions: skillDefinitions ?? this.skillDefinitions,
      equipmentDefinitions: equipmentDefinitions ?? this.equipmentDefinitions,
      traitDefinitions: traitDefinitions ?? this.traitDefinitions,
      languageDefinitions: languageDefinitions ?? this.languageDefinitions,
      abilityDefinitions: abilityDefinitions ?? this.abilityDefinitions,
      customizationOptionDefinitions: customizationOptionDefinitions ??
          this.customizationOptionDefinitions,
      forcePowerDefinitions:
          forcePowerDefinitions ?? this.forcePowerDefinitions,
      techPowerDefinitions: techPowerDefinitions ?? this.techPowerDefinitions,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        isLoading,
        characters,
        selectedId,
        failure,
        hasLoadedOnce,
        isSharing,
        shareIntent,
      speciesDefinitions,
      speciesNames,
      classNames,
      classDefinitions,
      backgroundNames,
      backgroundDefinitions,
      skillDefinitions,
        equipmentDefinitions,
        traitDefinitions,
        languageDefinitions,
        abilityDefinitions,
        customizationOptionDefinitions,
        forcePowerDefinitions,
        techPowerDefinitions,
      ];
}

/// CharacterSummaryBloc = ViewModel MVVM assurant la logique de l'écran résumé.
class CharacterSummaryBloc
    extends Bloc<CharacterSummaryEvent, CharacterSummaryState> {
  /// Construit le bloc avec ses dépendances métier/logging.
  CharacterSummaryBloc({
    required ListSavedCharacters listSavedCharacters,
    required CatalogRepository catalog,
    AppLogger? logger,
    CatalogLookupService? catalogLookupService,
  })  : _listSavedCharacters = listSavedCharacters,
        _logger = logger ?? _NoopAppLogger(),
        super(CharacterSummaryState.initial()) {
    _catalogLookupService =
        catalogLookupService ?? CatalogLookupService(catalog: catalog, logger: _logger);
    on<CharacterSummaryStarted>(_onStarted);
    on<CharacterSummaryRefreshRequested>(_onRefreshRequested);
    on<CharacterSummaryCharacterSelected>(_onCharacterSelected);
    on<CharacterSummaryShareRequested>(_onShareRequested);
    on<CharacterSummaryShareAcknowledged>(_onShareAcknowledged);
  }

  final ListSavedCharacters _listSavedCharacters;
  final AppLogger _logger;
  late final CatalogLookupService _catalogLookupService;

  Future<void> _onStarted(
    CharacterSummaryStarted event,
    Emitter<CharacterSummaryState> emit,
  ) async {
    await _loadCharacters(emit: emit, force: true);
  }

  Future<void> _onRefreshRequested(
    CharacterSummaryRefreshRequested event,
    Emitter<CharacterSummaryState> emit,
  ) async {
    await _loadCharacters(emit: emit, force: true);
  }

  void _onCharacterSelected(
    CharacterSummaryCharacterSelected event,
    Emitter<CharacterSummaryState> emit,
  ) {
    if (state.selectedId == event.characterId) {
      return;
    }
    final bool exists =
        state.characters.any((Character c) => c.id == event.characterId);
    if (!exists) {
      _logger.warn(
        'CharacterSummaryBloc.selectCharacter: id absent de la liste',
        payload: {'characterId': event.characterId.value},
      );
      return;
    }
    emit(
      state.copyWith(
        selectedId: event.characterId,
        resetShareIntent: true,
        isSharing: false,
      ),
    );
  }

  Future<void> _onShareRequested(
    CharacterSummaryShareRequested event,
    Emitter<CharacterSummaryState> emit,
  ) async {
    final Character? character = state.selectedCharacter;
    if (character == null) {
      _logger.warn('CharacterSummaryBloc.share: aucun personnage sélectionné');
      return;
    }
    if (state.isSharing) {
      return;
    }

    final SpeciesDef? speciesDef =
        state.speciesDefinitions[character.speciesId.value];
    final List<LanguageDef> speciesLanguages = <LanguageDef>[];
    if (speciesDef != null) {
      for (final String languageId in speciesDef.languageIds) {
        final LanguageDef? def = state.languageDefinitions[languageId];
        if (def != null) {
          speciesLanguages.add(def);
        }
      }
    }

    final String message = event.l10n.quickCreateCharacterSummary(
      character,
      speciesNames: state.speciesNames,
      classNames: state.classNames,
      classDefinitions: state.classDefinitions,
      backgroundNames: state.backgroundNames,
      backgroundDefinitions: state.backgroundDefinitions,
      skillDefinitions: state.skillDefinitions,
      equipmentDefinitions: state.equipmentDefinitions,
      traitDefinitions: state.traitDefinitions,
      abilityDefinitions: state.abilityDefinitions,
      customizationOptionDefinitions: state.customizationOptionDefinitions,
      forcePowerDefinitions: state.forcePowerDefinitions,
      techPowerDefinitions: state.techPowerDefinitions,
      speciesDefinition: speciesDef,
      speciesLanguages: speciesLanguages,
    );

    emit(
      state.copyWith(
        isSharing: true,
        shareIntent: CharacterSummaryShareIntent(
          subject:
              event.l10n.savedCharacterShareSubject(character.name.value),
          message: message,
        ),
      ),
    );
  }

  void _onShareAcknowledged(
    CharacterSummaryShareAcknowledged event,
    Emitter<CharacterSummaryState> emit,
  ) {
    emit(
      state.copyWith(
        isSharing: false,
        resetShareIntent: true,
      ),
    );
  }

  Future<void> _loadCharacters({
    required Emitter<CharacterSummaryState> emit,
    required bool force,
  }) async {
    if (state.isLoading && !force) {
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        clearFailure: true,
        resetShareIntent: true,
        isSharing: false,
      ),
    );

    late final AppResult<List<Character>> result;
    try {
      result = await _listSavedCharacters();
    } on Object catch (error, stackTrace) {
      _logger.error(
        'CharacterSummaryBloc.load: exception inattendue',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          isLoading: false,
          failure: AppFailure.fromException(
            error,
            code: 'UnexpectedLoadFailure',
          ),
          hasLoadedOnce: true,
        ),
      );
      return;
    }

    await result.match<Future<void>>(
      ok: (List<Character> characters) async {
        final CharacterId? nextSelectedId = _resolveSelection(
          characters,
          state.selectedId,
        );
        final CatalogLookupResult lookups =
            await _catalogLookupService.buildForCharacters(characters: characters);
        emit(
          state.copyWith(
            isLoading: false,
            characters: characters,
            selectedId: nextSelectedId,
            hasLoadedOnce: true,
            clearFailure: true,
            resetShareIntent: true,
            isSharing: false,
            speciesDefinitions: lookups.speciesDefinitions,
            speciesNames: lookups.speciesNames,
            classNames: lookups.classNames,
            classDefinitions: lookups.classDefinitions,
            backgroundNames: lookups.backgroundNames,
            backgroundDefinitions: lookups.backgroundDefinitions,
            skillDefinitions: lookups.skillDefinitions,
            equipmentDefinitions: lookups.equipmentDefinitions,
            traitDefinitions: lookups.traitDefinitions,
            languageDefinitions: lookups.languageDefinitions,
            abilityDefinitions: lookups.abilityDefinitions,
            customizationOptionDefinitions:
                lookups.customizationOptionDefinitions,
            forcePowerDefinitions: lookups.forcePowerDefinitions,
            techPowerDefinitions: lookups.techPowerDefinitions,
          ),
        );
      },
      err: (DomainError error) async {
        _logger.error(
          'CharacterSummaryBloc.load: erreur domaine',
          error: error,
        );
        emit(
          state.copyWith(
            isLoading: false,
            failure: AppFailure.fromDomain(error),
            hasLoadedOnce: true,
            characters: state.characters,
            resetShareIntent: true,
            isSharing: false,
          ),
        );
      },
    );
  }

  CharacterId? _resolveSelection(
    List<Character> characters,
    CharacterId? previousSelection,
  ) {
    if (characters.isEmpty) {
      return null;
    }
    if (previousSelection == null) {
      return characters.last.id;
    }
    for (final Character character in characters) {
      if (character.id == previousSelection) {
        return character.id;
      }
    }
    return characters.last.id;
  }

}

class _NoopAppLogger implements AppLogger {
  @override
  void error(String message, {Object? payload, Object? error, StackTrace? stackTrace}) {}

  @override
  void info(String message, {Object? payload}) {}

  @override
  void warn(String message, {Object? payload, Object? error, StackTrace? stackTrace}) {}
}
