/// ---------------------------------------------------------------------------
/// Fichier : lib/di/character_creation_module.dart
/// Rôle : Centraliser l'enregistrement et l'exposition des dépendances liées à
///        la création de personnage (catalogue, repositories, use cases).
/// Dépendances : flutter_riverpod (bridging legacy), ServiceLocator, couches
///        data/domain correspondantes.
/// Exemple d'usage :
///   registerCharacterCreationModule();
///   final useCase = ServiceLocator.resolve<FinalizeLevel1Character>();
/// ---------------------------------------------------------------------------
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw5e_manager/common/di/service_locator.dart';
import 'package:sw5e_manager/data/catalog/repositories/asset_catalog_repository.dart';
import 'package:sw5e_manager/data/characters/repositories/in_memory_character_repository.dart';
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

/// Enregistre les dépendances du module si nécessaire (idempotent).
void registerCharacterCreationModule() {
  ServiceLocator.registerLazySingleton<CatalogRepository>(
    () => AssetCatalogRepository(),
  );
  ServiceLocator.registerLazySingleton<CharacterRepository>(
    () => InMemoryCharacterRepository(),
  );
  ServiceLocator.registerLazySingleton<FinalizeLevel1Character>(
    () => FinalizeLevel1CharacterImpl(
      catalog: ServiceLocator.resolve<CatalogRepository>(),
      characters: ServiceLocator.resolve<CharacterRepository>(),
    ),
  );
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

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<CatalogRepository>();
});

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<CharacterRepository>();
});

final finalizeLevel1CharacterProvider = Provider<FinalizeLevel1Character>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<FinalizeLevel1Character>();
});

final listSavedCharactersProvider = Provider<ListSavedCharacters>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<ListSavedCharacters>();
});

final loadQuickCreateCatalogProvider = Provider<LoadQuickCreateCatalog>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<LoadQuickCreateCatalog>();
});

final loadSpeciesDetailsProvider = Provider<LoadSpeciesDetails>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<LoadSpeciesDetails>();
});

final loadClassDetailsProvider = Provider<LoadClassDetails>((ref) {
  registerCharacterCreationModule();
  return ServiceLocator.resolve<LoadClassDetails>();
});
