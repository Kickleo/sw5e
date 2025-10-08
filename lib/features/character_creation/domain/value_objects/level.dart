// lib/features/character_creation/domain/value_objects/level.dart
import 'package:equatable/equatable.dart';

/// VO Level : entier de 1 à 20 (MVP: on utilisera 1)
class Level extends Equatable {
  static const int min = 1;
  static const int max = 20;

  final int value;

  const Level._(this.value);

  /// Crée un Level valide ou lève ArgumentError.
  factory Level(int input) {
    if (input < min || input > max) {
      throw ArgumentError('Level.invalidRange ($input not in $min..$max)');
    }
    return Level._(input);
  }

  /// Raccourci pratique pour le MVP.
  static const Level one = Level._(1);

  bool get isMvp => value == 1;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Level($value)';
}
