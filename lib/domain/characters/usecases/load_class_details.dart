/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/load_class_details.dart
/// Rôle : Définir le contrat pour récupérer les informations nécessaires à la
///        sélection d'une classe (proficiencies, compétences, définitions).
/// Dépendances : AppResult, CatalogRepository, entités de classe/compétence.
/// Exemple d'usage :
///   final context = await loadClassDetails('guardian');
/// ---------------------------------------------------------------------------
import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// QuickCreateClassDetails = réponse domaine avec toutes les informations
/// utiles pour l'écran de sélection de classe.
class QuickCreateClassDetails {
  /// Crée l'instance.
  const QuickCreateClassDetails({
    required this.classDef,
    required this.availableSkillIds,
    required this.skillDefinitions,
    required this.skillChoicesRequired,
    this.missingSkillIds = const <String>[],
  });

  /// Définition complète de la classe.
  final ClassDef classDef;

  /// Compétences proposées (déjà triées).
  final List<String> availableSkillIds;

  /// Définitions associées aux compétences proposées.
  final Map<String, SkillDef> skillDefinitions;

  /// Nombre de compétences à choisir.
  final int skillChoicesRequired;

  /// Compétences introuvables dans le catalogue.
  final List<String> missingSkillIds;
}

/// Contrat du use case.
abstract class LoadClassDetails {
  /// Pré-condition : `classId` provient du catalogue.
  /// Post-condition : les compétences sont triées (alpha) et leurs définitions
  ///                  disponibles autant que possible.
  /// Erreurs : `UnknownClass` si la classe n'existe pas, `ClassLoadFailed`
  ///           sinon.
  Future<AppResult<QuickCreateClassDetails>> call(String classId);
}
