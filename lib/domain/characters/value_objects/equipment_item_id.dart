/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/equipment_item_id.dart
/// Rôle : Valider un identifiant d'objet d'équipement.
/// Dépendances : `equatable` uniquement.
/// Exemple d'usage :
///   final id = EquipmentItemId('blaster-pistol');
/// ---------------------------------------------------------------------------
library;
import 'package:equatable/equatable.dart';

/// EquipmentItemId = Value Object garantissant un slug d'objet valide.
///
/// * Pré-condition : longueur entre 3 et 60, caractères slug ASCII.
/// * Post-condition : valeur normalisée en minuscules.
/// * Erreurs : `ArgumentError` si vide ou format invalide.
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
