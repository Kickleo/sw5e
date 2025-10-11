/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/credits.dart
/// Rôle : Encapsuler un montant de crédits avec validation basique.
/// Dépendances : `equatable` uniquement.
/// Exemple d'usage :
///   final credits = Credits(150);
/// ---------------------------------------------------------------------------
library;
import 'package:equatable/equatable.dart';

/// Credits = Value Object pour un montant monétaire positif ou nul.
///
/// * Pré-condition : `value` >= 0.
/// * Post-condition : immuable; les opérations retournent de nouvelles instances.
/// * Erreurs : `ArgumentError` si valeur négative.
class Credits extends Equatable {
  static const int min = 0;
  static const int maxGuard = 1000000; // ajustable

  final int value;

  const Credits._(this.value);

  factory Credits(int input) {
    if (input < min) {
      throw ArgumentError('Credits.invalidRange (< $min)');
    }
    if (input > maxGuard) {
      throw ArgumentError('Credits.invalidRange (> $maxGuard)');
    }
    return Credits._(input);
  }

  Credits copyWith(int newValue) => Credits(newValue);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => '$value cr';
}
