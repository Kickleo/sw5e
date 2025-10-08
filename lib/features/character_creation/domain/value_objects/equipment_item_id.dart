// lib/features/character_creation/domain/value_objects/equipment_item_id.dart
import 'package:equatable/equatable.dart';

/// VO EquipmentItemId : identifiant d’un objet d’équipement (slug catalogue)
/// - Normalise : trim + minuscules
/// - Valide le format slug: ^[a-z0-9-]{3,60}$
/// - ⚠️ L’existence dans le catalogue est vérifiée ailleurs.
class EquipmentItemId extends Equatable {
  final String value;

  const EquipmentItemId._(this.value);

  factory EquipmentItemId(String input) {
    final raw = input.trim();
    if (raw.isEmpty) {
      throw ArgumentError('EquipmentItemId.nullOrEmpty');
    }
    final normalized = raw.toLowerCase();
    if (!_slug.hasMatch(normalized)) {
      throw ArgumentError('EquipmentItemId.invalidFormat');
    }
    return EquipmentItemId._(normalized);
  }

  static final RegExp _slug = RegExp(r'^[a-z0-9-]{3,60}$');

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
