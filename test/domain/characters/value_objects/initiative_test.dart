/// ---------------------------------------------------------------------------
/// Fichier test : initiative_test.dart
/// Rôle : Vérifier les bornes du Value Object [Initiative].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/initiative.dart';

void main() {
  group('Initiative', () {
    test('accepte les valeurs dans les gardes-fous', () {
      expect(Initiative(Initiative.min).value, equals(Initiative.min));
      expect(Initiative(Initiative.max).value, equals(Initiative.max));
    });

    test('rejette les valeurs hors limites', () {
      expect(() => Initiative(Initiative.min - 1), throwsA(isA<ArgumentError>()));
      expect(() => Initiative(Initiative.max + 1), throwsA(isA<ArgumentError>()));
    });

    test('affiche la valeur avec signe correct', () {
      expect(Initiative(3).toString(), equals('+3'));
      expect(Initiative(-2).toString(), equals('-2'));
    });
  });
}
