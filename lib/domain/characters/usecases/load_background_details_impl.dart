/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/usecases/load_background_details_impl.dart
/// Rôle : Implémenter [LoadBackgroundDetails] en s'appuyant sur le
///        [CatalogRepository].
/// ---------------------------------------------------------------------------
library;

import 'package:sw5e_manager/common/result/app_result.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

import 'package:sw5e_manager/domain/characters/usecases/load_background_details.dart';

class LoadBackgroundDetailsImpl implements LoadBackgroundDetails {
  const LoadBackgroundDetailsImpl(this._catalog);

  final CatalogRepository _catalog;

  @override
  Future<AppResult<QuickCreateBackgroundDetails>> call(String backgroundId) async {
    try {
      final BackgroundDef? background = await _catalog.getBackground(backgroundId);
      if (background == null) {
        return appErr(
          DomainError(
            'UnknownBackground',
            message: 'Historique "$backgroundId" introuvable dans le catalogue.',
          ),
        );
      }

      final Map<String, SkillDef> skillDefinitions = <String, SkillDef>{};
      final List<String> missingSkills = <String>[];
      for (final String skillId in background.grantedSkills) {
        final SkillDef? def = await _catalog.getSkill(skillId);
        if (def == null) {
          missingSkills.add(skillId);
          continue;
        }
        skillDefinitions[skillId] = def;
      }

      final Map<String, EquipmentDef> equipmentDefinitions = <String, EquipmentDef>{};
      final List<String> missingEquipment = <String>[];
      for (final BackgroundEquipmentGrant grant in background.equipment) {
        final EquipmentDef? equipment = await _catalog.getEquipment(grant.itemId);
        if (equipment == null) {
          missingEquipment.add(grant.itemId);
          continue;
        }
        equipmentDefinitions[grant.itemId] = equipment;
      }

      final List<String> missingTools = <String>[];
      for (final String toolId in background.toolProficiencies) {
        final EquipmentDef? tool = await _catalog.getEquipment(toolId);
        if (tool == null) {
          missingTools.add(toolId);
          continue;
        }
        equipmentDefinitions.putIfAbsent(toolId, () => tool);
      }

      return appOk(
        QuickCreateBackgroundDetails(
          background: background,
          skillDefinitions: Map<String, SkillDef>.unmodifiable(skillDefinitions),
          equipmentDefinitions:
              Map<String, EquipmentDef>.unmodifiable(equipmentDefinitions),
          missingSkillIds: List<String>.unmodifiable(missingSkills),
          missingEquipmentIds: List<String>.unmodifiable(missingEquipment),
          missingToolIds: List<String>.unmodifiable(missingTools),
        ),
      );
    } catch (error, _) {
      return appErr(
        DomainError(
          'BackgroundLoadFailed',
          message: error.toString(),
          details: {'backgroundId': backgroundId},
        ),
      );
    }
  }
}
