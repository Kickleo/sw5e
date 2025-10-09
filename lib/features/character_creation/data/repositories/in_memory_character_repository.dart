// lib/features/character_creation/data/repositories/in_memory_character_repository.dart
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/character_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_id.dart';

/// Implémentation ultra-simple pour le MVP/tests manuels.
/// ⚠️ Stocke uniquement en mémoire (perdu au redémarrage de l'app).
class InMemoryCharacterRepository implements CharacterRepository {
  final List<Character> _characters = <Character>[];

  @override
  Future<void> save(Character character) async {
    final index = _characters.indexWhere((c) => c.id == character.id);
    if (index >= 0) {
      _characters[index] = character;
    } else {
      _characters.add(character);
    }
  }

  @override
  Future<Character?> loadLast() async {
    if (_characters.isEmpty) {
      return null;
    }
    return _characters.last;
  }

  @override
  Future<List<Character>> listAll() async {
    return List.unmodifiable(_characters);
  }

  @override
  Future<Character?> loadById(CharacterId id) async {
    for (final character in _characters.reversed) {
      if (character.id == id) {
        return character;
      }
    }
    return null;
  }
}
