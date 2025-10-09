// lib/features/character_creation/domain/usecases/list_saved_characters.dart
import 'package:sw5e_manager/core/domain/result.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';

/// Use case : liste tous les personnages sauvegardés.
///
/// - Ok([]) si aucun personnage
/// - Err(...) pour les erreurs inattendues
abstract class ListSavedCharacters {
  Future<Result<List<Character>>> call();
}
