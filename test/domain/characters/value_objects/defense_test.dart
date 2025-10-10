/// ---------------------------------------------------------------------------
/// Fichier test : defense_test.dart
/// Rôle : Tester les validations du Value Object [Defense].
/// ---------------------------------------------------------------------------
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/defense.dart';

void main() {
  group('Defense', () {
    test('accepte une valeur dans la plage', () {
      expect(Defense(15).value, equals(15));
    });

    test('rejette les valeurs hors plage', () {
      expect(() => Defense(Defense.min - 1), throwsA(isA<ArgumentError>()));
      expect(() => Defense(Defense.max + 1), throwsA(isA<ArgumentError>()));
    });
  });
}
