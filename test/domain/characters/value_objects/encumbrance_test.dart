/// ---------------------------------------------------------------------------
/// Fichier test : encumbrance_test.dart
/// Rôle : Vérifier les contraintes du Value Object [Encumbrance].
/// ---------------------------------------------------------------------------
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/encumbrance.dart';

void main() {
  group('Encumbrance', () {
    test('accepte des charges positives ou nulles', () {
      expect(Encumbrance(0).grams, equals(0));
      expect(Encumbrance(2500).grams, equals(2500));
    });

    test('rejette les charges négatives ou hors garde-fou', () {
      expect(() => Encumbrance(-1), throwsA(isA<ArgumentError>()));
      expect(() => Encumbrance(Encumbrance.maxGuard + 1), throwsA(isA<ArgumentError>()));
    });

    test('indique si aucune charge', () {
      expect(Encumbrance(0).isZero, isTrue);
      expect(Encumbrance(1).isZero, isFalse);
    });
  });
}
