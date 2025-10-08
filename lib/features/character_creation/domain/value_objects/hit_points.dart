// lib/features/character_creation/domain/value_objects/hit_points.dart
import 'package:equatable/equatable.dart';

/// VO HitPoints : PV max du personnage (valeur de référence, pas l'état courant)
/// MVP: valeur déjà calculée par le moteur (classe/dé de vie + mod CON + bonus).
class HitPoints extends Equatable {
  static const int min = 1;
  /// Garde-fou optionnel pour éviter données corrompues (ajuste si besoin)
  static const int maxGuard = 300;

  final int value;

  const HitPoints._(this.value);

  factory HitPoints(int input) {
    if (input < min) {
      throw ArgumentError('HitPoints.invalidRange (< $min)');
    }
    if (input > maxGuard) {
      throw ArgumentError('HitPoints.invalidRange (> $maxGuard)');
    }
    return HitPoints._(input);
  }

  HitPoints copyWith(int newValue) => HitPoints(newValue);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'HP($value)';
}