/// ---------------------------------------------------------------------------
/// Fichier test : ability_score_test.dart
/// Rôle : Vérifier les invariants du Value Object [AbilityScore] (bornes et
///        calcul du modificateur).
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';

void main() {
  group('AbilityScore', () {
    test('accepte les bornes minimales et maximales', () {
      expect(AbilityScore(AbilityScore.min).value, equals(AbilityScore.min));
      expect(AbilityScore(AbilityScore.max).value, equals(AbilityScore.max));
    });

    test('calcule correctement le modificateur à partir de la valeur', () {
      expect(AbilityScore(8).modifier, equals(-1));
      expect(AbilityScore(10).modifier, equals(0));
      expect(AbilityScore(12).modifier, equals(1));
      expect(AbilityScore(15).modifier, equals(2));
      expect(AbilityScore(20).modifier, equals(5));
      expect(AbilityScore(15).toString(), contains('mod=2'));
    });

    test('rejette une valeur en dehors de la plage autorisée', () {
      expect(() => AbilityScore(0), throwsA(isA<ArgumentError>()));
      expect(() => AbilityScore(21), throwsA(isA<ArgumentError>()));
    });

    test('copyWith retourne une nouvelle instance validée', () {
      final AbilityScore initial = AbilityScore(10);
      final AbilityScore updated = initial.copyWith(12);

      expect(updated.value, equals(12));
      expect(updated, isNot(same(initial)));
    });
  });
}
