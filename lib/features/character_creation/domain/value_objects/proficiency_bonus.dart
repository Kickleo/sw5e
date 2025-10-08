// lib/features/character_creation/domain/value_objects/proficiency_bonus.dart
import 'package:equatable/equatable.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/level.dart';

/// VO ProficiencyBonus : entier +2..+6 (MVP: Level 1 => +2)
class ProficiencyBonus extends Equatable {
  static const int min = 2;
  static const int max = 6;

  final int value;

  const ProficiencyBonus._(this.value);

  /// Crée un bonus explicite (si déjà calculé)
  factory ProficiencyBonus(int input) {
    if (input < min || input > max) {
      throw ArgumentError('ProficiencyBonus.invalidRange ($input not in $min..$max)');
    }
    return ProficiencyBonus._(input);
  }

  /// Fabrique depuis un Level (table standard 5e-like)
  factory ProficiencyBonus.fromLevel(Level level) {
    final l = level.value;
    final v = _valueForLevel(l);
    return ProficiencyBonus._(v);
  }

  static int _valueForLevel(int level) {
    if (level >= 1 && level <= 4) return 2;
    if (level >= 5 && level <= 8) return 3;
    if (level >= 9 && level <= 12) return 4;
    if (level >= 13 && level <= 16) return 5;
    if (level >= 17 && level <= 20) return 6;
    throw ArgumentError('Level out of bounds for proficiency bonus: $level');
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => '+$value';
}
