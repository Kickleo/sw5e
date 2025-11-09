import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/catalog_details.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const CustomizationOptionDef makashi = CustomizationOptionDef(
    id: 'form-ii-makashi',
    name: LocalizedText(en: 'Makashi Form', fr: 'Forme Makashi'),
    category: 'lightsaber-form',
    effects: <CatalogFeatureEffect>[
      CatalogFeatureEffect(
        id: 'effect-1',
        kind: 'bonus',
        text: LocalizedText(
          en: 'Gain advantage on melee parry checks.',
          fr: 'Gagne un avantage sur les tests de parade au corps-à-corps.',
        ),
      ),
    ],
  );

  const PowerDef battleMeditation = PowerDef(
    id: 'battle-meditation',
    powerType: 'force',
    name: LocalizedText(en: 'Battle Meditation', fr: 'Méditation de combat'),
    level: 3,
    castingTime: 'action',
    description: LocalizedText(
      en: 'Bolster allies with a wave of calm focus.',
      fr: 'Renforce les alliés par une vague de concentration sereine.',
    ),
  );

  Widget buildTestApp(Widget child, {Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );
  }

  testWidgets('renders customization option names and effects using localization',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        const CustomizationOptionDetailsList(
          optionIds: <String>['form-ii-makashi'],
          optionDefinitions: <String, CustomizationOptionDef>{
            'form-ii-makashi': makashi,
          },
        ),
        locale: const Locale('fr'),
      ),
    );

    expect(find.text('Forme Makashi'), findsOneWidget);
    expect(
      find.text('Gagne un avantage sur les tests de parade au corps-à-corps.'),
      findsOneWidget,
    );
  });

  testWidgets('falls back to title case when option definition is missing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        const CustomizationOptionDetailsList(
          optionIds: <String>['unknown-option'],
          optionDefinitions: <String, CustomizationOptionDef>{},
        ),
      ),
    );

    expect(find.text('Unknown Option'), findsOneWidget);
  });

  testWidgets('renders power names and descriptions from catalog definitions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        const PowerDetailsList(
          powerIds: <String>['battle-meditation'],
          powerDefinitions: <String, PowerDef>{
            'battle-meditation': battleMeditation,
          },
        ),
        locale: const Locale('fr'),
      ),
    );

    expect(find.text('Méditation de combat'), findsOneWidget);
    expect(
      find.text('Renforce les alliés par une vague de concentration sereine.'),
      findsOneWidget,
    );
  });
}
