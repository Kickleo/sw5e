import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

enum ClassProficiencyCategory { weapon, armor, tool }

String formatClassProficiencies({
  required List<String> values,
  required AppLocalizations l10n,
  required ClassProficiencyCategory category,
  Map<String, EquipmentDef>? equipmentDefinitions,
}) {
  if (values.isEmpty) {
    return '';
  }

  final Iterable<String> labels = values.map((String slug) {
    switch (category) {
      case ClassProficiencyCategory.weapon:
        return l10n.classWeaponCategoryLabel(slug);
      case ClassProficiencyCategory.armor:
        return l10n.classArmorCategoryLabel(slug);
      case ClassProficiencyCategory.tool:
        final EquipmentDef? equipment = equipmentDefinitions?[slug];
        if (equipment != null) {
          final String label = l10n.localizedCatalogLabel(equipment.name).trim();
          if (label.isNotEmpty) {
            return label;
          }
        }
        return l10n.classToolCategoryLabel(slug);
    }
  }).where((String label) => label.isNotEmpty);

  return labels.join(', ');
}
