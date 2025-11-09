import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/class_feature_list.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const ClassFeature guardianFocus = ClassFeature(
    name: LocalizedText(en: "Guardian's Focus", fr: 'Focalisation du gardien'),
    description: LocalizedText(
      en: 'Sharpen senses to defend allies.',
      fr: 'Affinez vos sens pour défendre vos alliés.',
    ),
    effects: <CatalogFeatureEffect>[
      CatalogFeatureEffect(
        id: 'feature-effect-1',
        kind: 'grant',
        target: 'skill',
        text: LocalizedText(
          en: 'Gain proficiency in a sentinel skill.',
          fr: 'Gagnez la maîtrise d\'une compétence de sentinelle.',
        ),
      ),
    ],
  );

  testWidgets('renders heading, name, description and effect text',
      (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: ClassFeatureList(
              heading: 'Capacités de niveau 1',
              features: <ClassFeature>[guardianFocus],
            ),
          ),
        ),
      );

      expect(find.text('Capacités de niveau 1'), findsOneWidget);
      expect(find.text('Focalisation du gardien'), findsOneWidget);
      expect(
        find.text('Affinez vos sens pour défendre vos alliés.'),
        findsOneWidget,
      );
      expect(
        find.text("Gagnez la maîtrise d'une compétence de sentinelle."),
        findsOneWidget,
      );
  });

  testWidgets('does not render when features have no displayable content',
      (WidgetTester tester) async {
      const ClassFeature emptyFeature = ClassFeature(
        name: LocalizedText(),
        effects: <CatalogFeatureEffect>[],
      );

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: ClassFeatureList(
              heading: 'Level 1 features',
              features: <ClassFeature>[emptyFeature],
            ),
          ),
        ),
      );

      expect(find.text('Level 1 features'), findsNothing);
      expect(find.byType(ClassFeatureList), findsOneWidget);
  });
}
