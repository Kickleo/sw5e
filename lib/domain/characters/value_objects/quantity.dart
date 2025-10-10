/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/quantity.dart
/// Rôle : Encapsuler une quantité positive d'objet.
/// Dépendances : `equatable` uniquement.
/// Exemple d'usage :
///   final qty = Quantity(3);
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';

/// Quantity = Value Object pour des quantités entières (>= 0).
///
/// * Pré-condition : valeur >= 0.
/// * Post-condition : expose des helpers immuables (`isZero`, `isPositive`).
/// * Erreurs : `ArgumentError` si négatif ou dépasse le garde-fou.
class Quantity extends Equatable {
  static const int min = 0;
  static const int maxGuard = 9999;

  final int value;

  const Quantity._(this.value);

  factory Quantity(int input) {
    if (input < min) {
      throw ArgumentError('Quantity.invalidRange (< $min)');
    }
    if (input > maxGuard) {
      throw ArgumentError('Quantity.invalidRange (> $maxGuard)');
    }
    return Quantity._(input);
  }

  Quantity copyWith(int newValue) => Quantity(newValue);

  bool get isZero => value == 0;
  bool get isPositive => value > 0;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'x$value';
}
