// lib/features/character_creation/domain/repositories/character_repository.dart

import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';

/// Port de persistance des personnages côté domaine.
/// (Implémenté en Data via Drift, fichiers, etc.)
abstract class CharacterRepository {
  /// Sauvegarde (ou remplace) le personnage courant.
  Future<void> save(Character character);

  /// Charge le dernier personnage sauvegardé (ou null si aucun).
  Future<Character?> loadLast();
}