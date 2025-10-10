/// ---------------------------------------------------------------------------
/// Fichier test : hit_points_test.dart
/// Rôle : Vérifier les gardes-fous du Value Object [HitPoints].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/hit_points.dart';

void main() {
  group('HitPoints', () {
    test('accepte une valeur positive', () {
      expect(HitPoints(12).value, equals(12));
    });

    test('rejette les valeurs invalides', () {
      expect(() => HitPoints(0), throwsA(isA<ArgumentError>()));
      expect(() => HitPoints(HitPoints.maxGuard + 1), throwsA(isA<ArgumentError>()));
    });

    test('copyWith valide la nouvelle valeur', () {
      final HitPoints hp = HitPoints(10);
      expect(hp.copyWith(15).value, equals(15));
      expect(() => hp.copyWith(0), throwsA(isA<ArgumentError>()));
    });
  });
}
