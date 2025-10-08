// lib/features/character_creation/domain/value_objects/maneuvers_known.dart
import 'package:equatable/equatable.dart';

/// VO ManeuversKnown : nombre de manœuvres connues (MVP : niveau 1)
/// - Entier >= 0
/// - Garde-fou haut par défaut: 20 (ajustable)
class ManeuversKnown extends Equatable {
  static const int min = 0;
  static const int maxGuard = 20;

  final int value;

  const ManeuversKnown._(this.value);

  factory ManeuversKnown(int input) {
    if (input < min) {
      throw ArgumentError('ManeuversKnown.invalidRange (< $min)');
    }
    if (input > maxGuard) {
      throw ArgumentError('ManeuversKnown.invalidRange (> $maxGuard)');
    }
    return ManeuversKnown._(input);
  }

  ManeuversKnown copyWith(int newValue) => ManeuversKnown(newValue);

  bool get isZero => value == 0;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => '$value maneuvers';
}
