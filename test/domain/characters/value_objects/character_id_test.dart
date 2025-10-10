/// ---------------------------------------------------------------------------
/// Fichier test : character_id_test.dart
/// Rôle : Vérifier la validation et la génération de [CharacterId].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_id.dart';

void main() {
  group('CharacterId', () {
    test('normalise et conserve une valeur valide', () {
      expect(CharacterId('abc-123').value, equals('abc-123'));
    });

    test('rejette les valeurs invalides', () {
      expect(() => CharacterId(''), throwsA(isA<ArgumentError>()));
      expect(() => CharacterId('id invalid'), throwsA(isA<ArgumentError>()));
    });

    test('génère des identifiants pseudo-uniques', () {
      final id1 = CharacterId.generate();
      final id2 = CharacterId.generate();

      expect(id1.value, isNotEmpty);
      expect(id2.value, isNot(equals(id1.value)));
    });
  });
}
