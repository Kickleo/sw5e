/// ---------------------------------------------------------------------------
/// Fichier : lib/data/characters/repositories/in_memory_character_draft_repository.dart
/// Rôle : Persistance éphémère des brouillons de personnages pour les tests et
///        le développement.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';

/// Stockage en mémoire utilisé par les tests/unitaires et les environnements
/// de développement pour éviter les dépendances disque.
class InMemoryCharacterDraftRepository implements CharacterDraftRepository {
  /// Dernier brouillon conservé en mémoire vive.
  CharacterDraft? _draft;

  @override
  Future<void> save(CharacterDraft draft) async {
    /// Remplace simplement la référence courante : pas de copie nécessaire
    /// puisque les entités sont immuables dans la couche domaine.
    _draft = draft;
  }

  @override
  Future<CharacterDraft?> load() async => _draft;

  @override
  Future<void> clear() async {
    /// Réinitialise totalement l'état pour simuler une purge de stockage.
    _draft = null;
  }
}
