/// ---------------------------------------------------------------------------
/// Fichier test : character_name_test.dart
/// Rôle : Couvrir la normalisation et la validation du Value Object
///        [CharacterName].
/// ---------------------------------------------------------------------------
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_name.dart';

void main() {
  group('CharacterName', () {
    test('normalise espaces et apostrophes typographiques', () {
      final CharacterName name = CharacterName("  O’Malley   Kenobi  ");

      expect(name.value, equals("O'Malley Kenobi"));
      expect(name.toString(), equals("O'Malley Kenobi"));
    });

    test('accepte des valeurs valides', () {
      expect(CharacterName('Luke'), isA<CharacterName>());
      expect(CharacterName('R2-D2').value, equals('R2-D2'));
      expect(CharacterName('Obi-Wan Kenobi').value, equals('Obi-Wan Kenobi'));
    });

    test('rejette les entrées invalides', () {
      expect(() => CharacterName('   '), throwsA(isA<ArgumentError>()));
      expect(() => CharacterName('a' * 51), throwsA(isA<ArgumentError>()));
      expect(() => CharacterName('Jedi🔥'), throwsA(isA<ArgumentError>()));
    });
  });
}
