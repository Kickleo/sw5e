/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/maneuvers_known.dart
/// Rôle : Modéliser le nombre de manoeuvres connues.
/// Dépendances : `equatable` uniquement.
/// Exemple d'usage :
///   final maneuvers = ManeuversKnown(2);
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';

/// ManeuversKnown = Value Object du nombre de manoeuvres apprises.
///
/// * Pré-condition : valeur >= 0.
/// * Post-condition : immuable.
/// * Erreurs : `ArgumentError` si négatif ou dépasse le garde-fou.
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
