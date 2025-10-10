/// ---------------------------------------------------------------------------
/// Fichier test : character_trait_test.dart
/// Rôle : Vérifier l'égalité par valeur de [CharacterTrait].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_trait.dart';
import 'package:sw5e_manager/domain/characters/value_objects/trait_id.dart';

void main() {
  group('CharacterTrait', () {
    test('compare les instances par valeur', () {
      final traitA = CharacterTrait(id: TraitId('keen-senses'));
      final traitB = CharacterTrait(id: TraitId('keen-senses'));

      expect(traitA, equals(traitB));
      expect(traitA.toString(), contains('keen-senses'));
    });
  });
}
