// lib/features/character_creation/domain/value_objects/defense.dart
import 'package:equatable/equatable.dart';

/// VO Defense : valeur de défense (équivalent AC)
/// MVP : valeur déjà calculée par le moteur; ici on valide seulement.
class Defense extends Equatable {
  static const int min = 5;   // garde-fou
  static const int max = 35;  // garde-fou (ajuste si besoin)

  final int value;

  const Defense._(this.value);

  factory Defense(int input) {
    if (input < min || input > max) {
      throw ArgumentError('Defense.invalidRange ($input not in $min..$max)');
    }
    return Defense._(input);
  }

  Defense copyWith(int newValue) => Defense(newValue);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Defense($value)';
}
