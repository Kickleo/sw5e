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
    name: LocalizedText(en: 'Sentinel', fr: 'Sentinelle'),
    hitDie: 10,
    level1: ClassLevel1Data(
      proficiencies: ClassLevel1Proficiencies(
        skillsChoose: 2,
        skillsFrom: <String>['perception'],
      ),
      startingEquipment: const <StartingEquipmentLine>[],
    ),
    multiclassing: ClassMulticlassing(
      abilityRequirements: <String, int>{'dex': 13, 'wis': 13},
    ),
  );

  const Map<String, AbilityDef> abilityDefinitions = <String, AbilityDef>{
    'dex': AbilityDef(
      id: 'dex',
      abbreviation: 'DEX',
      name: LocalizedText(en: 'Dexterity', fr: 'Dextérité'),
    ),
    'wis': AbilityDef(
      id: 'wis',
      abbreviation: 'WIS',
      name: LocalizedText(en: 'Wisdom', fr: 'Sagesse'),
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
          body: const ClassMulticlassingDetails(
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
      name: LocalizedText(en: 'Warrior'),
      hitDie: 10,
      level1: ClassLevel1Data(
        proficiencies: ClassLevel1Proficiencies(
          skillsChoose: 2,
          skillsFrom: <String>['athletics'],
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
          body: const ClassMulticlassingDetails(
            classDef: noRequirements,
            abilityDefinitions: <String, AbilityDef>{},
          ),
        ),
      ),
    );

    expect(find.text('Multiclass requirements'), findsNothing);
  });
}
