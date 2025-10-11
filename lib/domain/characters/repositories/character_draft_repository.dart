/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/repositories/character_draft_repository.dart
/// Rôle : Contrat de persistance pour les brouillons de personnages en cours
///        de création.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';

abstract class CharacterDraftRepository {
  Future<void> save(CharacterDraft draft);
  Future<CharacterDraft?> load();
  Future<void> clear();
}
