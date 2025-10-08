// lib/features/character_creation/domain/value_objects/ability_score.dart
import 'package:equatable/equatable.dart';

/// VO AbilityScore : entier 1..20 (MVP)
/// Modificateur dérivé : floor((score - 10) / 2)
class AbilityScore extends Equatable {
  static const int min = 1;
  static const int max = 20;

  final int value;

  const AbilityScore._(this.value);

  factory AbilityScore(int input) {
    if (input < min || input > max) {
      throw ArgumentError('AbilityScore.invalidRange ($input not in $min..$max)');
    }
    return AbilityScore._(input);
  }

  /// Modificateur standard D&D-like.
  int get modifier => ((value - 10) / 2).floor();

  /// Permet de créer une nouvelle instance avec une autre valeur (immutabilité).
  AbilityScore copyWith(int newValue) => AbilityScore(newValue);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'AbilityScore($value, mod=$modifier)';
}
