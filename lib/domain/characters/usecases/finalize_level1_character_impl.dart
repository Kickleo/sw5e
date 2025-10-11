/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/finalize_level1_character_impl.dart
/// Rôle : Orchestrer la finalisation d'un personnage niveau 1 en s'appuyant sur
///        des use cases intermédiaires dédiés à la préparation et à
///        l'assemblage.
/// Dépendances : PrepareLevel1CharacterContext, AssembleLevel1Character,
///        CharacterRepository, `AppResult`.
/// Exemple d'usage :
///   final result = await FinalizeLevel1CharacterImpl(
///     prepareContext: prep,
///     assembleCharacter: assembler,
///     characters: repo,
///   )(input);
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/core/domain/result.dart' as core;
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/character_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/assemble_level1_character.dart';
import 'package:sw5e_manager/domain/characters/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/domain/characters/usecases/prepare_level1_character_context.dart';

/// Implémentation orchestrant la création complète niveau 1 à partir de
/// composants intermédiaires spécialisés.
///
/// * Pré-condition : les Value Objects contenus dans [FinalizeLevel1Input] sont
///   valides (garanti à leur construction).
/// * Erreurs : renvoie des `DomainError` contextualisés provenant soit de la
///   préparation du contexte, soit de l'assemblage, soit de la persistance.
class FinalizeLevel1CharacterImpl implements FinalizeLevel1Character {
  final PrepareLevel1CharacterContext
      prepareContext; // Précharge espèces/classes/backgrounds.
  final AssembleLevel1Character
      assembleCharacter; // Construit le personnage final à partir du contexte.
  final CharacterRepository
      characters; // Persiste le personnage finalisé en sortie.

  const FinalizeLevel1CharacterImpl({
    required this.prepareContext,
    required this.assembleCharacter,
    required this.characters,
  });

  @override
  Future<AppResult<Character>> call(FinalizeLevel1Input input) async {
    try {
      final contextResult = await prepareContext(input);
      switch (contextResult) {
        case core.Err<Level1CharacterContext>(:final error):
          return appErr(error);
        case core.Ok<Level1CharacterContext>(value: final context):
          final characterResult = await assembleCharacter(
            AssembleLevel1CharacterParams(input: input, context: context),
          );
          switch (characterResult) {
            case core.Err<Character>(:final error):
              return appErr(error);
            case core.Ok<Character>(value: final character):
              await characters.save(character);
              return appOk(character);
          }
      }
    } catch (e) {
      return appErr(DomainError('Unexpected', message: e.toString()));
    }
  }
}
