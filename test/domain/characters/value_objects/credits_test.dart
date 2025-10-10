/// ---------------------------------------------------------------------------
/// Fichier test : credits_test.dart
/// Rôle : Tester les validations de [Credits].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/credits.dart';

void main() {
  group('Credits', () {
    test('accepte les valeurs dans la plage autorisée', () {
      expect(Credits(0).value, equals(0));
      expect(Credits(100).value, equals(100));
    });

    test('rejette les valeurs négatives et hors garde-fou', () {
      expect(() => Credits(-1), throwsA(isA<ArgumentError>()));
      expect(() => Credits(Credits.maxGuard + 1), throwsA(isA<ArgumentError>()));
    });

    test('copyWith revalide la nouvelle valeur', () {
      final Credits credits = Credits(50);
      expect(credits.copyWith(75).value, equals(75));
      expect(() => credits.copyWith(-1), throwsA(isA<ArgumentError>()));
    });
  });
}
