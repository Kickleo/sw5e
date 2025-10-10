/// ---------------------------------------------------------------------------
/// Fichier test : quantity_test.dart
/// Rôle : Valider les bornes et helpers du Value Object [Quantity].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/quantity.dart';

void main() {
  group('Quantity', () {
    test('expose des helpers cohérents pour 0 et >0', () {
      final Quantity zero = Quantity(0);
      final Quantity positive = Quantity(3);

      expect(zero.isZero, isTrue);
      expect(zero.isPositive, isFalse);
      expect(positive.isZero, isFalse);
      expect(positive.isPositive, isTrue);
    });

    test('rejette les valeurs négatives ou au-delà du garde-fou', () {
      expect(() => Quantity(-1), throwsA(isA<ArgumentError>()));
      expect(() => Quantity(Quantity.maxGuard + 1), throwsA(isA<ArgumentError>()));
    });

    test('copyWith revalide la nouvelle valeur', () {
      final Quantity base = Quantity(1);
      final Quantity copy = base.copyWith(5);

      expect(copy.value, equals(5));
      expect(copy, isNot(same(base)));
    });
  });
}
