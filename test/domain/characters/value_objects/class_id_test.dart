/// ---------------------------------------------------------------------------
/// Fichier test : class_id_test.dart
/// Rôle : Garantir la validation du Value Object [ClassId].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/class_id.dart';

void main() {
  group('ClassId', () {
    test('normalise la valeur en slug', () {
      expect(ClassId(' Guardian ').value, equals('guardian'));
    });

    test('rejette les entrées invalides', () {
      expect(() => ClassId(''), throwsA(isA<ArgumentError>()));
      expect(() => ClassId('Gu ar dian'), throwsA(isA<ArgumentError>()));
      expect(() => ClassId('guárdian'), throwsA(isA<ArgumentError>()));
    });
  });
}
