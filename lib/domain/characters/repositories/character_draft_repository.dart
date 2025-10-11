/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/repositories/character_draft_repository.dart
/// Rôle : Contrat de persistance pour les brouillons de personnages en cours
///        de création.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';

abstract class CharacterDraftRepository {
  /// Persist the provided draft snapshot.
  Future<void> save(CharacterDraft draft);

  /// Retrieve the persisted draft, or null if none has been stored yet.
  Future<CharacterDraft?> load();

  /// Remove any stored draft data to reset the creation flow.
  Future<void> clear();
}
