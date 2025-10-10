/// ---------------------------------------------------------------------------
/// Fichier : test/ui/character_creation/widgets/character_section_divider_golden_test.dart
/// Rôle : Golden test garantissant la stabilité visuelle du séparateur partagé.
/// Dépendances : flutter_test, MaterialApp, CharacterSectionDivider.
/// Exemple d'usage : `flutter test test/ui/character_creation/widgets/character_section_divider_golden_test.dart`.
/// ---------------------------------------------------------------------------
library;
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sw5e_manager/ui/character_creation/widgets/character_section_divider.dart';

/// Crée le fichier golden à partir de la version encodée si nécessaire.
Future<void> _ensureGoldenFileExists() async {
  const goldenBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAMgAAAAMCAYAAAAnIfI8AAAATElEQVR4nO3ZsQ3AMAhFQeNJEsn7'
      'r4gXiH8bF3cT0DwhRHV3D+DT/HsAuJlAIBAIBPW8yw0CBzYIBAKBQCAQlD8InNkgEAgEAoFAsAH+'
      'fwlypZVquQAAAABJRU5ErkJggg==';

  final goldenPath = p.join(
    'test',
    'ui',
    'character_creation',
    'widgets',
    'goldens',
    'character_section_divider.png',
  );

  final file = File(goldenPath);
  if (await file.exists()) {
    return;
  }

  await file.create(recursive: true);
  await file.writeAsBytes(base64Decode(goldenBase64));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_ensureGoldenFileExists);

  testWidgets('CharacterSectionDivider correspond au golden attendu',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SizedBox(
              width: 200,
              child: CharacterSectionDivider(
                spacing: 12,
                thickness: 4,
                color: Color(0xFF202124),
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(CharacterSectionDivider),
      matchesGoldenFile(
        'goldens/character_section_divider.png',
      ),
    );
  });
}
