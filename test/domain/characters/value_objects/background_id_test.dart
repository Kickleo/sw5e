/// ---------------------------------------------------------------------------
/// Fichier test : background_id_test.dart
/// Rôle : Couvrir les invariants du Value Object [BackgroundId].
/// ---------------------------------------------------------------------------
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/background_id.dart';

void main() {
  group('BackgroundId', () {
    test('normalise les entrées valides', () {
      expect(BackgroundId(' Outlaw ').value, equals('outlaw'));
    });

    test('rejette les identifiants invalides', () {
      expect(() => BackgroundId(''), throwsA(isA<ArgumentError>()));
      expect(() => BackgroundId('out law'), throwsA(isA<ArgumentError>()));
      expect(() => BackgroundId('outláw'), throwsA(isA<ArgumentError>()));
    });
  });
}
