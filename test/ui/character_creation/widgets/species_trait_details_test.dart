import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/species_trait_details.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const TraitDef keenSenses = TraitDef(
    id: 'keen-senses',
    name: LocalizedText(en: 'Keen Senses', fr: 'Sens aiguisés'),
    description: LocalizedText(
      en: 'You have proficiency in the Perception skill.',
      fr: 'Vous maîtrisez la compétence Perception.',
    ),
  );

  const TraitDef nimbleEscape = TraitDef(
    id: 'nimble-escape',
    name: LocalizedText(en: 'Nimble Escape'),
    description: LocalizedText(
      en: 'You can take the Disengage or Hide action as a bonus action.',
    ),
  );

  Widget _buildApp(Widget child, {Locale locale = const Locale('en')}) {
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

  testWidgets('renders localized trait names and descriptions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildApp(
        SpeciesTraitDetailsList.fromDefinitions(
          traits: const <TraitDef>[keenSenses],
        ),
        locale: const Locale('fr'),
      ),
    );

    expect(find.text('Sens aiguisés'), findsOneWidget);
    expect(
      find.text('Vous maîtrisez la compétence Perception.'),
      findsOneWidget,
    );
  });

  testWidgets('falls back to slug title case when translation missing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildApp(
        SpeciesTraitDetailsList.fromDefinitions(
          traits: const <TraitDef>[nimbleEscape],
        ),
        locale: const Locale('fr'),
      ),
    );

    expect(find.text('Nimble Escape'), findsOneWidget);
    expect(
      find.text('You can take the Disengage or Hide action as a bonus action.'),
      findsOneWidget,
    );
  });

  testWidgets('renders nothing when no traits are provided',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildApp(
        const SpeciesTraitDetailsList.fromDefinitions(traits: <TraitDef>[]),
      ),
    );

    expect(find.byType(SpeciesTraitDetailsList), findsOneWidget);
    expect(find.byType(Card), findsNothing);
  });
}
