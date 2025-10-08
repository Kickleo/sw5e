// lib/features/character_creation/data/repositories/in_memory_character_repository.dart
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/character_repository.dart';

/// Implémentation ultra-simple pour le MVP/tests manuels.
/// ⚠️ Stocke uniquement en mémoire (perdu au redémarrage de l'app).
class InMemoryCharacterRepository implements CharacterRepository {
  Character? _last;

  @override
  Future<void> save(Character character) async {
    _last = character;
  }

  @override
  Future<Character?> loadLast() async {
    return _last;
  }
}
