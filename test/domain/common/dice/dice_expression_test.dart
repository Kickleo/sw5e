import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/common/dice/dice_expression.dart';

void main() {
  group('DiceExpression.parse', () {
    test('parses simple expression with modifier', () {
      final expression = DiceExpression.parse('4d4 + 2');

      expect(expression.terms, hasLength(1));
      expect(expression.terms.first.count, 4);
      expect(expression.terms.first.sides, 4);
      expect(expression.modifier, 2);
      expect(expression.toString(), '4d4+2');
    });

    test('parses expressions with subtraction and implicit count', () {
      final expression = DiceExpression.parse('d6 - 1d4 + 3');

      expect(expression.terms, hasLength(2));
      expect(expression.terms.first.count, 1);
      expect(expression.terms.first.sign, 1);
      expect(expression.terms[1].count, 1);
      expect(expression.terms[1].sign, -1);
      expect(expression.modifier, 3);
      expect(expression.toString(), '1d6-1d4+3');
    });

    test('parses modifier-only expression', () {
      final expression = DiceExpression.parse(' - 7 ');

      expect(expression.terms, isEmpty);
      expect(expression.modifier, -7);
      expect(expression.toString(), '-7');
    });

    test('throws on invalid expressions', () {
      expect(() => DiceExpression.parse('abc'), throwsFormatException);
      expect(() => DiceExpression.parse(''), throwsFormatException);
      expect(() => DiceExpression.parse('2dd6'), throwsFormatException);
      expect(() => DiceExpression.parse('4d4+'), throwsFormatException);
    });
  });

  group('DiceExpression.roll', () {
    test('produces deterministic results with FixedRandom', () {
      final expression = DiceExpression.parse('2d4 + 1');
      final random = FixedRandom([0, 3]);

      final result = expression.roll(random: random);

      expect(result.total, 1 + (1 + 4));
      expect(result.modifier, 1);
      expect(result.details, hasLength(1));
      expect(result.details.first.rolls, equals([1, 4]));
      expect(result.details.first.subtotal, 5);
    });

    test('supports subtracting dice terms', () {
      final expression = DiceExpression.parse('2d6-1d4');
      final random = FixedRandom([5, 0, 3]);

      final result = expression.roll(random: random);

      expect(result.total, equals((6 + 1) - 4));
      expect(result.details, hasLength(2));
      expect(result.details.first.subtotal, 7);
      expect(result.details[1].subtotal, -4);
    });
  });
}

class FixedRandom implements Random {
  FixedRandom(this.values)
      : assert(values.every((value) => value >= 0), 'values must be non-negative');

  final List<int> values;
  var _index = 0;

  @override
  int nextInt(int max) {
    if (_index >= values.length) {
      throw StateError('No more predetermined values.');
    }
    final value = values[_index++];
    if (value >= max) {
      throw RangeError.range(value, 0, max - 1, 'value');
    }
    return value;
  }

  @override
  double nextDouble() => throw UnimplementedError('nextDouble is not supported');

  @override
  bool nextBool() => throw UnimplementedError('nextBool is not supported');
}
