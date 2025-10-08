// lib/features/character_creation/domain/usecases/load_last_character.dart
import 'package:sw5e_manager/core/domain/result.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';

/// Use case (port) : charge le dernier personnage sauvegardé.
/// Convention :
/// - Ok(null)  => aucun personnage sauvegardé
/// - Ok(value) => personnage trouvé
/// - Err(...)  => erreur inattendue (IO, corruption, etc.)
abstract class LoadLastCharacter {
  Future<Result<Character?>> call();
}
