// lib/features/character_creation/domain/value_objects/superiority_dice.dart
import 'package:equatable/equatable.dart';

/// VO SuperiorityDice : pool de dés de supériorité
/// - count >= 0 (0 autorisé)
/// - si count > 0 => die ∈ {4,6,8,10,12} obligatoire
/// - si count == 0 => die doit être null
class SuperiorityDice extends Equatable {
  static const int minCount = 0;
  static const int maxGuard = 12; // garde-fou
  static const Set<int> allowedFaces = {4, 6, 8, 10, 12};

  final int count;
  final int? die;

  const SuperiorityDice._(this.count, this.die);

  factory SuperiorityDice({required int count, int? die}) {
    if (count < minCount || count > maxGuard) {
      throw ArgumentError('SuperiorityDice.invalidCount ($count not in $minCount..$maxGuard)');
    }
    if (count == 0) {
      if (die != null) {
        throw ArgumentError('SuperiorityDice.dieWithoutCount');
      }
      return const SuperiorityDice._(0, null);
    }
    // count > 0
    if (die == null) {
      throw ArgumentError('SuperiorityDice.missingDie');
    }
    if (!allowedFaces.contains(die)) {
      throw ArgumentError('SuperiorityDice.invalidDie ($die not in $allowedFaces)');
    }
    return SuperiorityDice._(count, die);
  }

  /// Copie immuable avec revalidation.
  SuperiorityDice copyWith({int? count, int? die}) =>
      SuperiorityDice(count: count ?? this.count, die: die ?? this.die);

  bool get isEmpty => count == 0;

  @override
  List<Object?> get props => [count, die];

  @override
  String toString() => isEmpty ? '0d' : '${count}d$die';
}
