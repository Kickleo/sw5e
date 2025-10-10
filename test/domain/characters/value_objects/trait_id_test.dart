/// ---------------------------------------------------------------------------
/// Fichier test : trait_id_test.dart
/// Rôle : Vérifier la normalisation du Value Object [TraitId].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/trait_id.dart';

void main() {
  group('TraitId', () {
    test('normalise en minuscules', () {
      expect(TraitId(' Shrewd ').value, equals('shrewd'));
    });

    test('rejette les formats invalides', () {
      expect(() => TraitId(''), throwsA(isA<ArgumentError>()));
      expect(() => TraitId('shrew d'), throwsA(isA<ArgumentError>()));
      expect(() => TraitId('shrëwd'), throwsA(isA<ArgumentError>()));
    });
  });
}
