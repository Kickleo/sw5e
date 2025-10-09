// lib/di/character_creation_module.dart
import 'package:get_it/get_it.dart';
import 'package:sw5e_manager/features/character_creation/data/repositories/asset_catalog_repository.dart';
import 'package:sw5e_manager/features/character_creation/data/repositories/in_memory_character_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/character_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/finalize_level1_character_impl.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/load_last_character.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/load_last_character_impl.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/list_saved_characters_impl.dart';

final sl = GetIt.instance;

/// À appeler une seule fois au démarrage de l’app.
Future<void> registerCharacterCreationModule() async {
  // Repos
  sl.registerLazySingleton<CatalogRepository>(() => AssetCatalogRepository());
  sl.registerLazySingleton<CharacterRepository>(() => InMemoryCharacterRepository());

  // Use case
  sl.registerLazySingleton<FinalizeLevel1Character>(
    () => FinalizeLevel1CharacterImpl(
      catalog: sl<CatalogRepository>(),
      characters: sl<CharacterRepository>(),
    ),
  );
  sl.registerLazySingleton<LoadLastCharacter>(
    () => LoadLastCharacterImpl(sl<CharacterRepository>()),
  );
  sl.registerLazySingleton<ListSavedCharacters>(
    () => ListSavedCharactersImpl(sl<CharacterRepository>()),
  );
}
