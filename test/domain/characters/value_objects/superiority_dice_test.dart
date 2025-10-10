/// ---------------------------------------------------------------------------
/// Fichier test : superiority_dice_test.dart
/// Rôle : Vérifier les règles du Value Object [SuperiorityDice].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/superiority_dice.dart';

void main() {
  group('SuperiorityDice', () {
    test('accepte un pool vide', () {
      final dice = SuperiorityDice(count: 0);
      expect(dice.isEmpty, isTrue);
      expect(dice.die, isNull);
    });

    test('accepte un pool valide', () {
      final dice = SuperiorityDice(count: 2, die: 8);
      expect(dice.count, equals(2));
      expect(dice.die, equals(8));
      expect(dice.toString(), equals('2d8'));
    });

    test('rejette les combinaisons invalides', () {
      expect(() => SuperiorityDice(count: -1), throwsA(isA<ArgumentError>()));
      expect(() => SuperiorityDice(count: 1), throwsA(isA<ArgumentError>()));
      expect(
        () => SuperiorityDice(count: 1, die: 3),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => SuperiorityDice(count: SuperiorityDice.maxGuard + 1, die: 6),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
