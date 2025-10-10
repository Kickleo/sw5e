/// ---------------------------------------------------------------------------
/// Fichier test : equipment_item_id_test.dart
/// Rôle : Valider les contraintes du Value Object [EquipmentItemId].
/// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/equipment_item_id.dart';

void main() {
  group('EquipmentItemId', () {
    test('normalise en slug ASCII', () {
      expect(EquipmentItemId(' Vibro-Ax ').value, equals('vibro-ax'));
    });

    test('rejette les formats invalides', () {
      expect(() => EquipmentItemId(''), throwsA(isA<ArgumentError>()));
      expect(() => EquipmentItemId('vibro ax'), throwsA(isA<ArgumentError>()));
      expect(() => EquipmentItemId('vïbro-ax'), throwsA(isA<ArgumentError>()));
    });
  });
}
