import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/class_proficiency_formatter.dart';

void main() {
  group('formatClassProficiencies', () {
    test('joins localized weapon categories', () {
      final AppLocalizations l10n = AppLocalizations(const Locale('en'));

      final String result = formatClassProficiencies(
        values: const <String>['simple', 'martial'],
        l10n: l10n,
        category: ClassProficiencyCategory.weapon,
      );

      expect(result, 'Simple weapons, Martial weapons');
    });

    test('uses equipment definitions for tool proficiencies', () {
      final AppLocalizations l10n = AppLocalizations(const Locale('fr'));
      final Map<String, EquipmentDef> equipment = <String, EquipmentDef>{
        'disguise-kit': const EquipmentDef(
          id: 'disguise-kit',
          name: LocalizedText(
            en: 'Disguise kit',
            fr: 'Trousse de déguisement',
          ),
          type: 'tool',
          weightG: 0,
          cost: 25,
        ),
      };

      final String result = formatClassProficiencies(
        values: const <String>['disguise-kit'],
        l10n: l10n,
        category: ClassProficiencyCategory.tool,
        equipmentDefinitions: equipment,
      );

      expect(result, 'Trousse de déguisement');
    });

    test('falls back to localization mappings when equipment missing', () {
      final AppLocalizations l10n = AppLocalizations(const Locale('en'));

      final String result = formatClassProficiencies(
        values: const <String>['vehicles-land'],
        l10n: l10n,
        category: ClassProficiencyCategory.tool,
      );

      expect(result, 'Land vehicles');
    });

    test('returns empty string when no values provided', () {
      final AppLocalizations l10n = AppLocalizations(const Locale('en'));

      final String result = formatClassProficiencies(
        values: const <String>[],
        l10n: l10n,
        category: ClassProficiencyCategory.weapon,
      );

      expect(result, '');
    });
  });
}
