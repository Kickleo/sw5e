/// ---------------------------------------------------------------------------
/// Fichier test : level_test.dart
/// Rôle : Vérifier les bornes et helpers du Value Object [Level].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/level.dart';

void main() {
  group('Level', () {
    test('accepte les bornes 1..20', () {
      expect(Level(Level.min).value, equals(Level.min));
      expect(Level(Level.max).value, equals(Level.max));
    });

    test('rejette un niveau hors bornes', () {
      expect(() => Level(0), throwsA(isA<ArgumentError>()));
      expect(() => Level(21), throwsA(isA<ArgumentError>()));
    });

    test('fournit un raccourci MVP level one', () {
      expect(Level.one.value, equals(1));
      expect(Level.one.isMvp, isTrue);
    });
  });
}
