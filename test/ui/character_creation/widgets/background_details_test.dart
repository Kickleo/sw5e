import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/background_details.dart';

void main() {
  final AppLocalizations l10n = AppLocalizations(const Locale('en'));
  final ThemeData theme = ThemeData();

  const BackgroundDef detailedBackground = BackgroundDef(
    id: 'outlaw',
    name: LocalizedText(en: 'Outlaw', fr: 'Hors-la-loi'),
    grantedSkills: <String>['stealth'],
    languagesPick: 1,
    toolProficiencies: <String>['disguise-kit'],
    feature: BackgroundFeature(
      name: LocalizedText(en: 'Underworld Contacts', fr: 'Contacts du milieu'),
      effects: <CatalogFeatureEffect>[
        CatalogFeatureEffect(
          id: 'effect-1',
          kind: 'narrative',
          text: LocalizedText(
            en: 'You can always find an underworld contact.',
            fr: 'Vous connaissez toujours un contact du milieu.',
          ),
        ),
      ],
    ),
    personality: BackgroundPersonality(
      traits: <LocalizedText>[
        LocalizedText(en: 'Calm under pressure', fr: 'Calme sous pression'),
      ],
      ideals: <LocalizedText>[
        LocalizedText(en: 'Freedom', fr: 'Liberté'),
      ],
      bonds: <LocalizedText>[
        LocalizedText(en: 'Crew first', fr: 'L\'équipage avant tout'),
      ],
      flaws: <LocalizedText>[
        LocalizedText(en: 'Greedy', fr: 'Avarice'),
      ],
    ),
    equipment: <BackgroundEquipmentGrant>[
      BackgroundEquipmentGrant(
        itemId: 'blaster',
        refType: 'gear',
        quantity: 1,
      ),
    ],
  );

  const Map<String, SkillDef> skillDefinitions = <String, SkillDef>{
    'stealth': SkillDef(
      id: 'stealth',
      ability: 'dex',
      name: LocalizedText(en: 'Stealth', fr: 'Discrétion'),
    ),
  };

  const Map<String, EquipmentDef> equipmentDefinitions = <String, EquipmentDef>{
    'blaster': EquipmentDef(
      id: 'blaster',
      name: LocalizedText(en: 'Blaster', fr: 'Blaster'),
      type: 'weapon',
      weightG: 1000,
      cost: 500,
    ),
    'disguise-kit': EquipmentDef(
      id: 'disguise-kit',
      name: LocalizedText(
        en: 'Disguise Kit (Localized)',
        fr: 'Kit de déguisement',
      ),
      type: 'tool',
      weightG: 500,
      cost: 50,
    ),
  };

  test('buildBackgroundDetails renders sections when data is present', () {
    final List<Widget> widgets = buildBackgroundDetails(
      l10n: l10n,
      theme: theme,
      background: detailedBackground,
      skillDefinitions: skillDefinitions,
      equipmentDefinitions: equipmentDefinitions,
    );

    expect(widgets, isNotEmpty);
    expect(widgets.first, isA<Text>());
    expect((widgets.first as Text).data, l10n.summaryBackgroundSkillsTitle);

    final Iterable<Text> textWidgets = widgets.whereType<Text>();

    // Verify skill bullet is rendered with localized label.
    expect(textWidgets.map((Text text) => text.data), contains('• Stealth'));

    // Languages pick entry should be present.
    expect(
      textWidgets.map((Text text) => text.data),
      contains(l10n.summaryBackgroundLanguagesPick(1)),
    );

    // Tool proficiency bullet should use localized equipment label when available.
    expect(
      textWidgets.map((Text text) => text.data),
      contains('• Disguise Kit (Localized)'),
    );

    // Feature name is localized.
    expect(textWidgets.map((Text text) => text.data), contains('Underworld Contacts'));

    // Effect description is wrapped in a Padding widget with a Text child.
    final Padding effectPadding = widgets.firstWhere((Widget widget) => widget is Padding) as Padding;
    expect(effectPadding.child, isA<Text>());
    expect((effectPadding.child! as Text).data,
        'You can always find an underworld contact.');

    // Personality traits produce bullet entries.
    expect(
      textWidgets.map((Text text) => text.data),
      contains(l10n.summaryBackgroundPersonalityTraits),
    );

    // Equipment bullet combines localized label and quantity.
    expect(textWidgets.map((Text text) => text.data), contains('• Blaster ×1'));
  });

  test('buildBackgroundDetails returns empty list when background is empty', () {
    const BackgroundDef minimalBackground = BackgroundDef(
      id: 'acolyte',
      name: LocalizedText(en: 'Acolyte', fr: 'Acolyte'),
      grantedSkills: <String>[],
    );

    final List<Widget> widgets = buildBackgroundDetails(
      l10n: l10n,
      theme: theme,
      background: minimalBackground,
      skillDefinitions: const <String, SkillDef>{},
      equipmentDefinitions: const <String, EquipmentDef>{},
    );

    expect(widgets, isEmpty);
  });
}
