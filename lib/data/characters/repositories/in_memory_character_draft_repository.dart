/// ---------------------------------------------------------------------------
/// Fichier : lib/data/characters/repositories/in_memory_character_draft_repository.dart
/// Rôle : Persistance éphémère des brouillons de personnages pour les tests et
///        le développement.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_draft_repository.dart';

class InMemoryCharacterDraftRepository implements CharacterDraftRepository {
  CharacterDraft? _draft;

  @override
  Future<void> save(CharacterDraft draft) async {
    _draft = draft;
  }

  @override
  Future<CharacterDraft?> load() async => _draft;

  @override
  Future<void> clear() async {
    _draft = null;
  }
}
