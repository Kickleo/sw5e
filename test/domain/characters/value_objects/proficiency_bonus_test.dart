/// ---------------------------------------------------------------------------
/// Fichier test : proficiency_bonus_test.dart
/// Rôle : Vérifier la table de calcul et les bornes de [ProficiencyBonus].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/level.dart';
import 'package:sw5e_manager/domain/characters/value_objects/proficiency_bonus.dart';

void main() {
  group('ProficiencyBonus', () {
    test('dérive correctement depuis un niveau', () {
      expect(ProficiencyBonus.fromLevel(Level(1)).value, equals(2));
      expect(ProficiencyBonus.fromLevel(Level(5)).value, equals(3));
      expect(ProficiencyBonus.fromLevel(Level(11)).value, equals(4));
      expect(ProficiencyBonus.fromLevel(Level(15)).value, equals(5));
      expect(ProficiencyBonus.fromLevel(Level(20)).value, equals(6));
    });

    test('rejette une valeur explicite hors plage', () {
      expect(() => ProficiencyBonus(1), throwsA(isA<ArgumentError>()));
      expect(() => ProficiencyBonus(7), throwsA(isA<ArgumentError>()));
    });

    test('toString ajoute un signe positif', () {
      expect(ProficiencyBonus(3).toString(), equals('+3'));
    });
  });
}
