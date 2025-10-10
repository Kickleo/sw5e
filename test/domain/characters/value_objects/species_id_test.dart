/// ---------------------------------------------------------------------------
/// Fichier test : species_id_test.dart
/// Rôle : Vérifier la normalisation et les invariants du Value Object [SpeciesId].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/species_id.dart';

void main() {
  group('SpeciesId', () {
    test('normalise en minuscules et supprime les espaces', () {
      expect(SpeciesId(' Human ').value, equals('human'));
    });

    test('rejette les formats invalides', () {
      expect(() => SpeciesId(''), throwsA(isA<ArgumentError>()));
      expect(() => SpeciesId('hu'), throwsA(isA<ArgumentError>()));
      expect(() => SpeciesId('togrutá'), throwsA(isA<ArgumentError>()));
      expect(() => SpeciesId('to gruta'), throwsA(isA<ArgumentError>()));
    });

    test('égalité basée sur la valeur', () {
      expect(SpeciesId('human'), equals(SpeciesId(' human ')));
    });
  });
}
