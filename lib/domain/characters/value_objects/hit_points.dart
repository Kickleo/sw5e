/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/hit_points.dart
/// Rôle : Encapsuler le total de points de vie.
/// Dépendances : `equatable` uniquement.
/// Exemple d'usage :
///   final hp = HitPoints(12);
/// ---------------------------------------------------------------------------
library;
import 'package:equatable/equatable.dart';

/// HitPoints = Value Object pour un total de points de vie.
///
/// * Pré-condition : entier >= 0.
/// * Post-condition : immuable; `copyWith` retourne une nouvelle instance.
/// * Erreurs : `ArgumentError` si négatif.
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
