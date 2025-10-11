import 'dart:math';

/// Represents a dice expression such as `4d4 + 2` or `2d6 - 1`.
class DiceExpression {
  const DiceExpression._({
    required List<DiceTerm> terms,
    required this.modifier,
  }) : terms = List.unmodifiable(terms);

  /// Parses [source] into a [DiceExpression].
  factory DiceExpression.parse(String source) {
    final normalized = source.replaceAll(RegExp(r'\s+'), '');
    if (normalized.isEmpty) {
      throw const FormatException('Empty dice expression');
    }

    final tokenRegex = RegExp(r'([+\-]?[^+\-]+)');
    final matches = tokenRegex.allMatches(normalized).toList();
    if (matches.isEmpty) {
      throw FormatException('Invalid dice expression: "$source"');
    }

    final consumed = matches.map((match) => match.group(0)!).join();
    if (consumed.length != normalized.length) {
      throw FormatException('Invalid dice expression: "$source"');
    }

    final terms = <DiceTerm>[];
    var modifier = 0;

    for (final match in matches) {
      final token = match.group(0)!;
      final sign = token.startsWith('-') ? -1 : 1;
      final body = token.startsWith(RegExp(r'[+\-]'))
          ? token.substring(1)
          : token;

      if (body.isEmpty) {
        throw FormatException('Invalid dice expression: "$source"');
      }

      final parts = body.split(RegExp(r'[dD]'));
      if (body.contains(RegExp(r'[dD]'))) {
        if (parts.length != 2) {
          throw FormatException('Invalid dice expression: "$source"');
        }

        final countPart = parts[0];
        final sidesPart = parts[1];
        final count = countPart.isEmpty ? 1 : int.tryParse(countPart);
        final sides = int.tryParse(sidesPart);

        if (count == null || count <= 0) {
          throw FormatException(
            'Dice count must be a positive integer in: "${match.group(0)!}"',
          );
        }
        if (sides == null || sides <= 0) {
          throw FormatException(
            'Dice sides must be a positive integer in: "${match.group(0)!}"',
          );
        }

        terms.add(DiceTerm(count: count, sides: sides, sign: sign));
        continue;
      }

      final constant = int.tryParse(body);
      if (constant == null) {
        throw FormatException('Invalid dice expression: "$source"');
      }
      modifier += sign * constant;
    }

    return DiceExpression._(terms: terms, modifier: modifier);
  }

  final List<DiceTerm> terms;
  final int modifier;

  bool get isEmpty => terms.isEmpty && modifier == 0;

  /// Rolls the dice expression using [random] or a default [Random] instance.
  DiceRollResult roll({Random? random}) {
    final generator = random ?? Random();
    final details = <DiceRollDetail>[];
    var total = modifier;

    for (final term in terms) {
      final rolls = <int>[];
      for (var i = 0; i < term.count; i++) {
        final roll = generator.nextInt(term.sides) + 1;
        rolls.add(roll);
      }
      final subtotal = rolls.fold<int>(0, (sum, value) => sum + value) * term.sign;
      total += subtotal;
      details.add(DiceRollDetail(term: term, rolls: rolls, subtotal: subtotal));
    }

    return DiceRollResult(total: total, modifier: modifier, details: details);
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    for (var i = 0; i < terms.length; i++) {
      final term = terms[i];
      if (i == 0) {
        buffer.write(term.toString());
      } else {
        buffer.write(term.sign < 0 ? '-' : '+');
        buffer.write(term.copyWith(sign: 1));
      }
    }
    if (modifier != 0 || buffer.isEmpty) {
      if (buffer.isNotEmpty && modifier > 0) {
        buffer.write('+');
      }
      if (modifier < 0) {
        buffer.write('-');
        buffer.write(modifier.abs());
      } else {
        buffer.write(modifier);
      }
    }
    return buffer.toString();
  }
}

/// Represents a dice term such as `4d4` or `1d6`.
class DiceTerm {
  const DiceTerm({
    required this.count,
    required this.sides,
    this.sign = 1,
  }) : assert(sign == 1 || sign == -1, 'sign must be either 1 or -1');

  final int count;
  final int sides;
  final int sign;

  DiceTerm copyWith({int? count, int? sides, int? sign}) => DiceTerm(
        count: count ?? this.count,
        sides: sides ?? this.sides,
        sign: sign ?? this.sign,
      );

  @override
  String toString() {
    final prefix = sign < 0 ? '-' : '';
    return '$prefix${count}d$sides';
  }
}

/// Holds the outcome of a dice roll.
class DiceRollResult {
  DiceRollResult({
    required this.total,
    required this.details,
    required this.modifier,
  }) : details = List.unmodifiable(details);

  final int total;
  final int modifier;
  final List<DiceRollDetail> details;
}

/// Holds the detail for a single dice term roll.
class DiceRollDetail {
  DiceRollDetail({
    required this.term,
    required List<int> rolls,
    required this.subtotal,
  }) : rolls = List.unmodifiable(rolls);

  final DiceTerm term;
  final List<int> rolls;
  final int subtotal;
}
