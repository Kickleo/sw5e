import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/class_power_details.dart';

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
    powerSource: 'force',
    powerList: const ClassPowerList(
      forceAllowed: true,
      techAllowed: false,
      spellcastingProgression: 'half',
    ),
  );

  testWidgets('renders localized power details when metadata is present',
      (WidgetTester tester) async {
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
          body: ClassPowerDetails(classDef: sentinel),
        ),
      ),
    );

    expect(find.text('Pouvoirs'), findsOneWidget);
    expect(find.text('Source de pouvoirs : Force'), findsOneWidget);
    expect(find.text('Pouvoirs de la Force : autorisés'), findsOneWidget);
    expect(find.text('Pouvoirs technologiques : interdits'), findsOneWidget);
    expect(find.text('Progression de lanceur : Lanceur moitié'), findsOneWidget);
  });

  testWidgets('collapses when no power metadata is available',
      (WidgetTester tester) async {
    const ClassDef noPower = ClassDef(
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
          body: ClassPowerDetails(classDef: noPower),
        ),
      ),
    );

    expect(find.byType(ClassPowerDetails), findsOneWidget);
    expect(find.text('Powers'), findsNothing);
  });
}
