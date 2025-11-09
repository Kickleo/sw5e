/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/load_background_details.dart
/// Rôle : Définir le contrat pour récupérer les informations d'un historique
///        (background) nécessaires aux écrans de création rapide.
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// Données agrégées pour afficher un historique et ses effets.
class QuickCreateBackgroundDetails {
  const QuickCreateBackgroundDetails({
    required this.background,
    this.skillDefinitions = const <String, SkillDef>{},
    this.equipmentDefinitions = const <String, EquipmentDef>{},
    this.missingSkillIds = const <String>[],
    this.missingEquipmentIds = const <String>[],
    this.missingToolIds = const <String>[],
  });

  final BackgroundDef background;
  final Map<String, SkillDef> skillDefinitions;
  final Map<String, EquipmentDef> equipmentDefinitions;
  final List<String> missingSkillIds;
  final List<String> missingEquipmentIds;
  final List<String> missingToolIds;
}

/// Contrat du use case permettant de charger un historique par son identifiant.
abstract class LoadBackgroundDetails {
  Future<AppResult<QuickCreateBackgroundDetails>> call(String backgroundId);
}
