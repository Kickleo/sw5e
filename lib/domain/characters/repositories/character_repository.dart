/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/repositories/character_repository.dart
/// Rôle : Définir le port de persistance des personnages.
/// Dépendances : Entité `Character` et VO `CharacterId`.
/// Exemple d'usage :
///   await repository.save(character);
/// ---------------------------------------------------------------------------

import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_id.dart';

/// CharacterRepository = port hexagonal chargé de persister les personnages.
///
/// * Contrat : toutes les implémentations doivent retourner des futures résolues
///   ou lever des exceptions de domaine (converties en `AppResult` par les use cases).
abstract class CharacterRepository {
  /// Sauvegarde (ou remplace) le personnage courant.
  Future<void> save(Character character);

  /// Charge le dernier personnage sauvegardé (ou null si aucun).
  Future<Character?> loadLast();

  /// Liste tous les personnages sauvegardés, du plus ancien au plus récent.
  Future<List<Character>> listAll();

  /// Charge un personnage par identifiant.
  Future<Character?> loadById(CharacterId id);
}
