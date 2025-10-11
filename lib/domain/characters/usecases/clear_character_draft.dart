/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/clear_character_draft.dart
/// Rôle : Contrat pour supprimer le brouillon persistant après finalisation.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';

abstract class ClearCharacterDraft {
  Future<AppResult<void>> call();
}
