import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/species_ability_bonuses.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('renders localized ability bonuses', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        const SpeciesAbilityBonusesCard(
          bonuses: <SpeciesAbilityBonus>[
            SpeciesAbilityBonus(ability: 'int', amount: 2),
            SpeciesAbilityBonus(ability: 'wis', amount: 1),
          ],
        ),
        locale: const Locale('fr'),
      ),
    );

    expect(find.text('Augmentation de caractéristiques'), findsOneWidget);
    expect(find.textContaining('+2 Intelligence'), findsOneWidget);
    expect(find.textContaining('+1 Sagesse'), findsOneWidget);
  });

  testWidgets('collapses when there are no displayable bonuses',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        const SpeciesAbilityBonusesCard(
          bonuses: <SpeciesAbilityBonus>[],
        ),
      ),
    );

    // The widget should shrink to an empty box when nothing can be displayed.
    expect(find.byType(Card), findsNothing);
  });

  test('hasDisplayableContent ignores zero-value bonuses', () {
    expect(
      SpeciesAbilityBonusesCard.hasDisplayableContent(const <SpeciesAbilityBonus>[
        SpeciesAbilityBonus(ability: 'str', amount: 0),
      ]),
      isFalse,
    );
  });
}
