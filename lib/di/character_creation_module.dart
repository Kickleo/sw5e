import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw5e_manager/features/character_creation/data/repositories/asset_catalog_repository.dart';
import 'package:sw5e_manager/features/character_creation/data/repositories/in_memory_character_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/character_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/finalize_level1_character_impl.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/list_saved_characters_impl.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return AssetCatalogRepository();
});

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return InMemoryCharacterRepository();
});

final finalizeLevel1CharacterProvider = Provider<FinalizeLevel1Character>((ref) {
  return FinalizeLevel1CharacterImpl(
    catalog: ref.watch(catalogRepositoryProvider),
    characters: ref.watch(characterRepositoryProvider),
  );
});

final listSavedCharactersProvider = Provider<ListSavedCharacters>((ref) {
  return ListSavedCharactersImpl(ref.watch(characterRepositoryProvider));
});
