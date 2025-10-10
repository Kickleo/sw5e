/// ---------------------------------------------------------------------------
/// Fichier : in_memory_character_repository.dart
/// Rôle : Adapter de persistance en mémoire pour `CharacterRepository`.
/// Dépendances : entité `Character`, value object `CharacterId`.
/// Exemple d'usage :
///   final repo = InMemoryCharacterRepository();
///   await repo.save(character);
/// ---------------------------------------------------------------------------
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_repository.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_id.dart';

/// InMemoryCharacterRepository = persistance éphémère pour tests/démos.
///
/// Ce repository conserve les personnages dans une liste locale. Il respecte
/// l'interface `CharacterRepository` mais ne doit pas être utilisé en
/// production car les données sont perdues au redémarrage de l'application.
class InMemoryCharacterRepository implements CharacterRepository {
  final List<Character> _characters = <Character>[];

  /// Sauvegarde ou remplace un personnage.
  @override
  ///
  /// - Pré-condition : `character.id` est défini et unique.
  /// - Post-condition : le personnage est présent dans `_characters`.
  Future<void> save(Character character) async {
    final index = _characters.indexWhere((c) => c.id == character.id);
    if (index >= 0) {
      _characters[index] = character;
    } else {
      _characters.add(character);
    }
  }

  /// Récupère le dernier personnage enregistré.
  @override
  ///
  /// - Post-condition : retourne `null` si aucun personnage n'a été sauvegardé.
  Future<Character?> loadLast() async {
    if (_characters.isEmpty) {
      return null;
    }
    return _characters.last;
  }

  /// Liste tous les personnages sauvegardés.
  @override
  ///
  /// - Post-condition : renvoie une vue non modifiable.
  Future<List<Character>> listAll() async {
    return List.unmodifiable(_characters);
  }

  /// Recherche un personnage par identifiant.
  @override
  ///
  /// - Pré-condition : `id` est valide.
  /// - Post-condition : retourne `null` si aucun personnage ne correspond.
  Future<Character?> loadById(CharacterId id) async {
    for (final character in _characters.reversed) {
      if (character.id == id) {
        return character;
      }
    }
    return null;
  }
}
