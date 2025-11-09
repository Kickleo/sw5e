import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/class_multiclassing_details.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const ClassDef sentinel = ClassDef(
    id: 'sentinel',
    name: const LocalizedText(en: 'Sentinel', fr: 'Sentinelle'),
    hitDie: 10,
    level1: const ClassLevel1Data(
      proficiencies: const ClassLevel1Proficiencies(
        skillsChoose: 2,
        skillsFrom: const <String>['perception'],
      ),
      startingEquipment: const <StartingEquipmentLine>[],
    ),
    multiclassing: const ClassMulticlassing(
      abilityRequirements: const <String, int>{'dex': 13, 'wis': 13},
    ),
  );

  const Map<String, AbilityDef> abilityDefinitions = <String, AbilityDef>{
    'dex': AbilityDef(
      id: 'dex',
      abbreviation: 'DEX',
      name: const LocalizedText(en: 'Dexterity', fr: 'Dextérité'),
    ),
    'wis': AbilityDef(
      id: 'wis',
      abbreviation: 'WIS',
      name: const LocalizedText(en: 'Wisdom', fr: 'Sagesse'),
    ),
  };

  testWidgets('renders localized requirement labels', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(
          body: ClassMulticlassingDetails(
            classDef: sentinel,
            abilityDefinitions: abilityDefinitions,
          ),
        ),
      ),
    );

    expect(find.text('Prérequis de multi-classe'), findsOneWidget);
    expect(find.text('Dextérité 13, Sagesse 13'), findsOneWidget);
  });

  testWidgets('collapses when no requirements available',
      (WidgetTester tester) async {
    const ClassDef noRequirements = ClassDef(
      id: 'warrior',
      name: const LocalizedText(en: 'Warrior'),
      hitDie: 10,
      level1: const ClassLevel1Data(
        proficiencies: const ClassLevel1Proficiencies(
          skillsChoose: 2,
          skillsFrom: const <String>['athletics'],
        ),
        startingEquipment: const <StartingEquipmentLine>[],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(
          body: ClassMulticlassingDetails(
            classDef: noRequirements,
            abilityDefinitions: <String, AbilityDef>{},
          ),
        ),
      ),
    );

    expect(find.text('Multiclass requirements'), findsNothing);
  });
}
