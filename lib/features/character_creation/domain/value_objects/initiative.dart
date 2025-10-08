// lib/features/character_creation/domain/value_objects/initiative.dart
import 'package:equatable/equatable.dart';

/// VO Initiative : bonus appliqué au jet d'initiative (peut être négatif)
/// MVP : valeur déjà calculée par le moteur ; ici on valide seulement.
class Initiative extends Equatable {
  static const int min = -10; // garde-fou
  static const int max = 20;  // garde-fou (ajuste si besoin)

  final int value;

  const Initiative._(this.value);

  factory Initiative(int input) {
    if (input < min || input > max) {
      throw ArgumentError('Initiative.invalidRange ($input not in $min..$max)');
    }
    return Initiative._(input);
  }

  Initiative copyWith(int newValue) => Initiative(newValue);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value >= 0 ? '+$value' : '$value';
}
