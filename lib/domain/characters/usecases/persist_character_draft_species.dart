/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/persist_character_draft_species.dart
/// Rôle : Définir l'action permettant d'enregistrer les informations liées à
///        l'espèce sélectionnée dans un brouillon de personnage.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/entities/character_draft.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';

abstract class PersistCharacterDraftSpecies {
  Future<AppResult<CharacterDraft>> call(QuickCreateSpeciesDetails details);
}
