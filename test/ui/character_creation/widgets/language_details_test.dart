import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/language_details.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const LanguageDef basic = LanguageDef(
    id: 'galactic-basic',
    name: LocalizedText(en: 'Galactic Basic', fr: 'Basic galactique'),
    description: LocalizedText(
      en: 'A lingua franca spoken across the galaxy.',
      fr: 'Langue véhiculaire parlée dans toute la galaxie.',
    ),
    script: LocalizedText(en: 'Aurebesh', fr: 'Aurebesh'),
    typicalSpeakers: <LanguageTypicalSpeaker>[
      LanguageTypicalSpeaker(
        type: 'species',
        id: 'twilek',
        name: LocalizedText(en: "Twi'lek", fr: "Twi'lek"),
      ),
      LanguageTypicalSpeaker(
        type: 'species',
        id: 'human',
        name: LocalizedText(en: 'Human', fr: 'Humain'),
      ),
    ],
  );

  const LanguageDef bothese = LanguageDef(
    id: 'bothese',
    name: LocalizedText(en: 'Bothese', fr: 'Bothese'),
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

  testWidgets('renders localized names and descriptions when available',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        const LanguageDetailsCard(
          languages: <LanguageDef>[basic, bothese],
        ),
        locale: const Locale('fr'),
      ),
    );

    expect(find.text('Langues'), findsOneWidget);
    expect(find.text('Basic galactique'), findsOneWidget);
    expect(
      find.text('Langue véhiculaire parlée dans toute la galaxie.'),
      findsOneWidget,
    );
    expect(find.text('Alphabet : Aurebesh'), findsOneWidget);
    expect(
      find.text("Locuteurs typiques : Twi'lek, Humain"),
      findsOneWidget,
    );
    expect(find.text('Bothese'), findsOneWidget);
  });

  testWidgets('falls back to narrative text when no structured languages',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        const LanguageDetailsCard(
          languages: <LanguageDef>[],
          fallback: LocalizedText(
            en: 'You can speak Galactic Basic and one extra language.',
          ),
        ),
      ),
    );

    expect(find.text('Languages'), findsOneWidget);
    expect(
      find.text('You can speak Galactic Basic and one extra language.'),
      findsOneWidget,
    );
  });

  testWidgets('renders nothing when there is no displayable content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        const LanguageDetailsCard(
          languages: <LanguageDef>[],
          fallback: LocalizedText(),
        ),
      ),
    );

    expect(find.byType(LanguageDetailsCard), findsOneWidget);
    // Card should collapse to an empty widget when nothing can be displayed.
    expect(find.byType(Card), findsNothing);
  });
}
