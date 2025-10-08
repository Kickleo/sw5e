// lib/features/character_creation/domain/value_objects/quantity.dart
import 'package:equatable/equatable.dart';

/// VO Quantity : quantité d'un item dans l'inventaire
/// - Entier >= 0
/// - Garde-fou haut (par défaut 9999) pour éviter les corruptions.
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
