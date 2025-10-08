// lib/features/character_creation/domain/value_objects/credits.dart
import 'package:equatable/equatable.dart';

/// VO Credits : monnaie disponible (crédits)
/// MVP : entier >= 0, pas de décimaux. Garde-fou haut optionnel.
class Credits extends Equatable {
  static const int min = 0;
  static const int maxGuard = 1000000; // ajustable

  final int value;

  const Credits._(this.value);

  factory Credits(int input) {
    if (input < min) {
      throw ArgumentError('Credits.invalidRange (< $min)');
    }
    if (input > maxGuard) {
      throw ArgumentError('Credits.invalidRange (> $maxGuard)');
    }
    return Credits._(input);
  }

  Credits copyWith(int newValue) => Credits(newValue);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => '$value cr';
}
