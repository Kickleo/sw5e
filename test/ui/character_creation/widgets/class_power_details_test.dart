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
    name: LocalizedText(en: 'Sentinel', fr: 'Sentinelle'),
    hitDie: 10,
    level1: ClassLevel1Data(
      proficiencies: ClassLevel1Proficiencies(
        skillsChoose: 2,
        skillsFrom: <String>['perception'],
      ),
      startingEquipment: <StartingEquipmentLine>[],
    ),
    powerSource: 'force',
    powerList: ClassPowerList(
      forceAllowed: true,
      techAllowed: false,
      spellcastingProgression: 'half',
    ),
  );

  testWidgets('renders localized power details when metadata is present',
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
      name: LocalizedText(en: 'Warrior'),
      hitDie: 10,
      level1: ClassLevel1Data(
        proficiencies: ClassLevel1Proficiencies(
          skillsChoose: 2,
          skillsFrom: <String>['athletics'],
        ),
        startingEquipment: <StartingEquipmentLine>[],
      ),
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
          body: ClassPowerDetails(classDef: noPower),
        ),
      ),
    );

    expect(find.byType(ClassPowerDetails), findsOneWidget);
    expect(find.text('Powers'), findsNothing);
  });
}
