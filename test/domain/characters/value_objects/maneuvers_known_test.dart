/// ---------------------------------------------------------------------------
/// Fichier test : maneuvers_known_test.dart
/// Rôle : Couvrir les validations du Value Object [ManeuversKnown].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/maneuvers_known.dart';

void main() {
  group('ManeuversKnown', () {
    test('accepte les valeurs dans la plage', () {
      expect(ManeuversKnown(0).value, equals(0));
      expect(ManeuversKnown(3).value, equals(3));
    });

    test('rejette les valeurs négatives ou trop grandes', () {
      expect(() => ManeuversKnown(-1), throwsA(isA<ArgumentError>()));
      expect(
        () => ManeuversKnown(ManeuversKnown.maxGuard + 1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('copyWith revalide la valeur', () {
      final ManeuversKnown maneuvers = ManeuversKnown(1);
      expect(maneuvers.copyWith(2).value, equals(2));
      expect(() => maneuvers.copyWith(-1), throwsA(isA<ArgumentError>()));
    });
  });
}
