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
import 'package:sw5e_manager/data/characters/repositories/in_memory_character_repository.dart';
import 'package:sw5e_manager/data/characters/repositories/persistent_character_repository.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/domain/characters/usecases/finalize_level1_character_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_class_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_class_details_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_quick_create_catalog.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_quick_create_catalog_impl.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details_impl.dart';

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
  // -------------------------------------------------------------------------
  // Use cases
  // -------------------------------------------------------------------------
  // Use case de finalisation niveau 1, nécessite catalogue + repository persistant.
  ServiceLocator.registerLazySingleton<FinalizeLevel1Character>(
    () => FinalizeLevel1CharacterImpl(
      catalog: ServiceLocator.resolve<CatalogRepository>(),
      characters: ServiceLocator.resolve<CharacterRepository>(),
    ),
  );
  // Use case listant les personnages sauvegardés.
  ServiceLocator.registerLazySingleton<ListSavedCharacters>(
    () => ListSavedCharactersImpl(
      ServiceLocator.resolve<CharacterRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<LoadQuickCreateCatalog>(
    () => LoadQuickCreateCatalogImpl(
      ServiceLocator.resolve<CatalogRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<LoadSpeciesDetails>(
    () => LoadSpeciesDetailsImpl(
      ServiceLocator.resolve<CatalogRepository>(),
    ),
  );
  ServiceLocator.registerLazySingleton<LoadClassDetails>(
    () => LoadClassDetailsImpl(
      ServiceLocator.resolve<CatalogRepository>(),
    ),
  );
}

/// Expose le repository du catalogue sous forme de provider Riverpod afin
/// d'intégrer facilement les widgets Flutter qui n'utilisent pas directement
/// le `ServiceLocator`. L'appel à `registerCharacterCreationModule` garantit
/// que l'enregistrement de la dépendance est idempotent avant de résoudre
/// l'instance.
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  registerCharacterCreationModule(); // S'assure que le module est enregistré.
  return ServiceLocator.resolve<CatalogRepository>();
});

/// Retourne l'implémentation du repository de personnages : en mode release,
/// on s'appuie sur la persistance, sinon on reste en mémoire pour accélérer les
/// itérations. Le provider permet aux couches UI de rester déclaratives.
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
final loadQuickCreateCatalogProvider = Provider<LoadQuickCreateCatalog>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<LoadQuickCreateCatalog>();
});

/// Fournit l'accès aux détails complets d'une espèce (trait, vitesse, etc.)
/// pour alimenter les écrans ou formulaires de création.
final loadSpeciesDetailsProvider = Provider<LoadSpeciesDetails>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<LoadSpeciesDetails>();
});

/// Fournit l'use case de lecture des détails d'une classe : compétences,
/// archétypes, etc. (selon ce qui est disponible dans le catalogue).
final loadClassDetailsProvider = Provider<LoadClassDetails>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<LoadClassDetails>();
});
