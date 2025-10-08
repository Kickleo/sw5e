// lib/features/character_creation/domain/value_objects/encumbrance.dart
import 'package:equatable/equatable.dart';

/// VO Encumbrance : poids/encombrement normalisé en **grammes**
/// - Entier >= 0
/// - Garde-fou haut par défaut: 1_000_000 g (1 000 kg) pour éviter les corruptions.
/// - Les conversions (lb/kg -> g) se font **en dehors** de ce VO.
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
