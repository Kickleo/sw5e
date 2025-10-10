/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/encumbrance.dart
/// Rôle : Suivre les charges et l'état d'encombrement.
/// Dépendances : `equatable` uniquement.
/// Exemple d'usage :
///   final encumbrance = Encumbrance(current: 20, max: 60);
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';

/// Encumbrance = Value Object décrivant le poids porté par rapport au maximum.
///
/// * Pré-condition : charges >= 0 et `current` <= `max`.
/// * Post-condition : statut dérivé exposé via un getter.
/// * Erreurs : `ArgumentError` si contraintes violées.
class Encumbrance extends Equatable {
  static const int min = 0;
  static const int maxGuard = 1_000_000;

  final int grams;

  const Encumbrance._(this.grams);

  factory Encumbrance(int grams) {
    if (grams < min) {
      throw ArgumentError('Encumbrance.invalidRange (< $min)');
    }
    if (grams > maxGuard) {
      throw ArgumentError('Encumbrance.invalidRange (> $maxGuard)');
    }
    return Encumbrance._(grams);
  }

  Encumbrance copyWith(int newGrams) => Encumbrance(newGrams);

  bool get isZero => grams == 0;

  @override
  List<Object?> get props => [grams];

  @override
  String toString() => '${grams}g';
}
