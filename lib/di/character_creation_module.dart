/// ---------------------------------------------------------------------------
/// Fichier : lib/di/character_creation_module.dart
/// Rôle : Centraliser l'enregistrement et l'exposition des dépendances liées à
///        la création de personnage (catalogue, repositories, use cases).
/// Dépendances : flutter_riverpod (bridging legacy), ServiceLocator, couches
///        data/domain correspondantes.
/// Exemple d'usage :
///   registerCharacterCreationModule();
// ignore: unintended_html_in_doc_comment
///   final useCase = ServiceLocator.resolve<FinalizeLevel1Character>();
/// ---------------------------------------------------------------------------
library;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw5e_manager/common/di/service_locator.dart';
import 'package:sw5e_manager/data/catalog/repositories/asset_catalog_repository.dart';
import 'package:sw5e_manager/data/characters/repositories/in_memory_character_draft_repository.dart';
import 'package:sw5e_manager/data/characters/repositories/in_memory_character_repository.dart';
import 'package:sw5e_manager/data/characters/repositories/persistent_character_draft_repository.dart';
import 'package:sw5e_manager/data/characters/repositories/persistent_character_repository.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/assemble_level1_character.dart';
import 'package:sw5e_manager/domain/characters/usecases/assemble_level1_character_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/clear_character_draft.dart';
import 'package:sw5e_manager/domain/characters/usecases/clear_character_draft_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/domain/characters/usecases/finalize_level1_character_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_background_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_background_details_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_character_draft.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_character_draft_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_background_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_background_details_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_class_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_class_details_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_quick_create_catalog.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_quick_create_catalog_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_ability_scores.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_ability_scores_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_background.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_background_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_class.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_class_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_equipment.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_equipment_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_name.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_name_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_skills.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_skills_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_species.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_species_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_step.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_step_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/prepare_level1_character_context.dart';
import 'package:sw5e_manager/domain/characters/usecases/prepare_level1_character_context_impl.dart';

/// Enregistre toutes les dépendances nécessaires à la création de personnage.
///
/// La fonction peut être appelée plusieurs fois sans effet secondaire grâce à
/// l'utilisation systématique de `registerLazySingleton`. Elle est donc
/// invoquée par chaque provider Riverpod avant de résoudre la dépendance,
/// évitant d'avoir à exposer la logique d'initialisation dans les widgets.
void registerCharacterCreationModule() {
  // -------------------------------------------------------------------------
  // Repositories
  // -------------------------------------------------------------------------
  // Dans notre architecture, un repository encapsule l'accès à une source de
  // données (fichiers, mémoire, base distante) et expose au domaine un contrat
  // simple, sans fuite de détails techniques. Il représente donc la frontière
  // entre la logique métier (use cases, entités) et l'infrastructure.
  // Repository catalogue basé sur les assets (instancié une seule fois).
  ServiceLocator.registerLazySingleton<CatalogRepository>(
    () => AssetCatalogRepository(),
  );
  // Repository personnages : on bascule dynamiquement selon le mode
  // d'exécution pour éviter toute écriture disque pendant le développement.
  ServiceLocator.registerLazySingleton<CharacterRepository>(
    () => kReleaseMode
        ? PersistentCharacterRepository()
        : InMemoryCharacterRepository(),
  );
  ServiceLocator.registerLazySingleton<CharacterDraftRepository>(
    () => kReleaseMode
        ? PersistentCharacterDraftRepository()
        : InMemoryCharacterDraftRepository(),
  );
  // -------------------------------------------------------------------------
  // Use cases
  // -------------------------------------------------------------------------
  // Un use case représente une action métier complète (scénario utilisateur)
  // orchestrant différents repositories/services pour accomplir une finalité
  // observable par l'utilisateur. Il définit l'API de la couche domaine, ce
  // qui permet à l'UI de déclencher des comportements de haut niveau sans
  // connaître les détails d'exécution.
  // Use case préparant les données catalogue indispensables à la finalisation
  // (espèce, classe, background, tables de formules). Isolé pour pouvoir être
  // réutilisé dans d'autres orchestrations futures.
  ServiceLocator.registerLazySingleton<PrepareLevel1CharacterContext>(
    () => PrepareLevel1CharacterContextImpl(
      catalog: ServiceLocator.resolve<CatalogRepository>(),
    ),
  );
  // Use case d'assemblage : transforme le contexte + les choix du joueur en un
  // objet [Character] cohérent en appliquant toutes les validations métiers.
  ServiceLocator.registerLazySingleton<AssembleLevel1Character>(
    () => AssembleLevel1CharacterImpl(
      catalog: ServiceLocator.resolve<CatalogRepository>(),
    ),
  );
  // Use case de finalisation niveau 1 : il orchestre les étapes précédentes
  // (préparation + assemblage) avant de déléguer la persistance au repository.
  ServiceLocator.registerLazySingleton<FinalizeLevel1Character>(
    () => FinalizeLevel1CharacterImpl(
      prepareContext: ServiceLocator.resolve<PrepareLevel1CharacterContext>(),
      assembleCharacter: ServiceLocator.resolve<AssembleLevel1Character>(),
      characters: ServiceLocator.resolve<CharacterRepository>(),
    ),
  );
  // Use case listant les personnages sauvegardés : il interroge le repository
  // de personnages pour restituer la collection complète aux écrans de
  // sélection/gestion.
  ServiceLocator.registerLazySingleton<ListSavedCharacters>(
    () => ListSavedCharactersImpl(
      ServiceLocator.resolve<CharacterRepository>(),
    ),
  );
  // Use case chargeant le catalogue de création rapide : il compose les
  // différentes entrées (espèces, classes, historiques…) nécessaires pour la
  // vue simplifiée, en s'appuyant uniquement sur le repository de catalogue.
  ServiceLocator.registerLazySingleton<LoadQuickCreateCatalog>(
    () => LoadQuickCreateCatalogImpl(
      ServiceLocator.resolve<CatalogRepository>(),
    ),
  );
  // Use case centralisant le chargement des détails d'une espèce. Il étend les
  // informations de base (nom, vitesse) avec les traits et autres métadonnées
  // requises par les écrans de personnalisation.
  ServiceLocator.registerLazySingleton<LoadSpeciesDetails>(
    () => LoadSpeciesDetailsImpl(
      ServiceLocator.resolve<CatalogRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<LoadCharacterDraft>(
    () => LoadCharacterDraftImpl(
      ServiceLocator.resolve<CharacterDraftRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<PersistCharacterDraftName>(
    () => PersistCharacterDraftNameImpl(
      ServiceLocator.resolve<CharacterDraftRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<PersistCharacterDraftSpecies>(
    () => PersistCharacterDraftSpeciesImpl(
      ServiceLocator.resolve<CharacterDraftRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<PersistCharacterDraftClass>(
    () => PersistCharacterDraftClassImpl(
      ServiceLocator.resolve<CharacterDraftRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<PersistCharacterDraftBackground>(
    () => PersistCharacterDraftBackgroundImpl(
      ServiceLocator.resolve<CharacterDraftRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<PersistCharacterDraftAbilityScores>(
    () => PersistCharacterDraftAbilityScoresImpl(
      ServiceLocator.resolve<CharacterDraftRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<PersistCharacterDraftSkills>(
    () => PersistCharacterDraftSkillsImpl(
      ServiceLocator.resolve<CharacterDraftRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<PersistCharacterDraftEquipment>(
    () => PersistCharacterDraftEquipmentImpl(
      ServiceLocator.resolve<CharacterDraftRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<PersistCharacterDraftStep>(
    () => PersistCharacterDraftStepImpl(
      ServiceLocator.resolve<CharacterDraftRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<ClearCharacterDraft>(
    () => ClearCharacterDraftImpl(
      ServiceLocator.resolve<CharacterDraftRepository>(),
    ),
  );
  // Use case responsable de la lecture des informations d'une classe (niveaux,
  // archétypes, capacités). Il isole la logique d'agrégation pour ne présenter
  // que les données pertinentes au domaine/UI.
  ServiceLocator.registerLazySingleton<LoadClassDetails>(
    () => LoadClassDetailsImpl(
      ServiceLocator.resolve<CatalogRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<LoadBackgroundDetails>(
    () => LoadBackgroundDetailsImpl(
      ServiceLocator.resolve<CatalogRepository>(),
    ),
  );
}

/// Expose le repository du catalogue sous forme de provider Riverpod afin
/// d'intégrer facilement les widgets Flutter qui n'utilisent pas directement
/// le `ServiceLocator`. L'appel à `registerCharacterCreationModule` garantit
/// que l'enregistrement de la dépendance est idempotent avant de résoudre
/// l'instance.
///
/// Ce provider est volontairement simple (aucun cache custom) car Riverpod se
/// charge déjà de mémoriser la valeur tant qu'un `ProviderScope` reste actif.
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  registerCharacterCreationModule(); // S'assure que le module est enregistré.
  return ServiceLocator.resolve<CatalogRepository>();
});

/// Retourne l'implémentation du repository de personnages : en mode release,
/// on s'appuie sur la persistance, sinon on reste en mémoire pour accélérer les
/// itérations. Le provider permet aux couches UI de rester déclaratives.
///
/// Noter que l'implémentation retournée dépend du flag `kReleaseMode` défini
/// par Flutter : aucune configuration additionnelle n'est nécessaire côté UI.
final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<CharacterRepository>();
});

/// Fournit l'use case orchestrant la finalisation d'un personnage niveau 1.
/// Celui-ci combine les données du catalogue (espèces, classes, etc.) avec les
/// actions de persistance pour matérialiser le personnage sauvegardé.
final finalizeLevel1CharacterProvider = Provider<FinalizeLevel1Character>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<FinalizeLevel1Character>();
});

/// Use case listant les personnages existants en s'appuyant sur le repository
/// de persistance. Le provider permet de le consommer en `ref.watch`.
final listSavedCharactersProvider = Provider<ListSavedCharacters>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<ListSavedCharacters>();
});

/// Charge le catalogue utilisé pour la "création rapide" (une vue simplifiée
/// présentant les options principales). Centralisé ici pour mutualiser les
/// dépendances entre écrans.
///
/// Ce use case se limite au catalogue ; il n'accède pas au repository de
/// personnages car la création rapide se contente de préparer des choix.
final loadQuickCreateCatalogProvider = Provider<LoadQuickCreateCatalog>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<LoadQuickCreateCatalog>();
});

/// Fournit l'accès aux détails complets d'une espèce (trait, vitesse, etc.)
/// pour alimenter les écrans ou formulaires de création.
///
/// L'UI peut l'utiliser en `ref.watch` pour réagir automatiquement aux
/// changements de la couche data (par exemple si le catalogue est rechargé).
final loadSpeciesDetailsProvider = Provider<LoadSpeciesDetails>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<LoadSpeciesDetails>();
});

/// Fournit l'use case de lecture des détails d'une classe : compétences,
/// archétypes, etc. (selon ce qui est disponible dans le catalogue).
///
/// Comme pour l'espèce, Riverpod se charge de fournir la même instance tant que
/// le provider reste dans l'arbre ; il n'est donc pas nécessaire de conserver
/// manuellement la référence côté widget.
final loadClassDetailsProvider = Provider<LoadClassDetails>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<LoadClassDetails>();
});

/// Fournit l'use case récupérant les informations détaillées d'un historique
/// (compétences accordées, équipement, trait narratif, etc.).
final loadBackgroundDetailsProvider = Provider<LoadBackgroundDetails>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<LoadBackgroundDetails>();
});
