/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/defense.dart
/// Rôle : Porter la classe d'armure calculée.
/// Dépendances : `equatable` uniquement.
/// Exemple d'usage :
///   final defense = Defense(14);
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';

/// Defense = Value Object représentant la classe d'armure finale.
///
/// * Pré-condition : valeur entière >= 0.
/// * Post-condition : immuable et comparable par valeur.
/// * Erreurs : `ArgumentError` si négatif.
class Defense extends Equatable {
  static const int min = 5;   // garde-fou
  static const int max = 35;  // garde-fou (ajuste si besoin)

  final int value;

  const Defense._(this.value);

  factory Defense(int input) {
    if (input < min || input > max) {
      throw ArgumentError('Defense.invalidRange ($input not in $min..$max)');
    }
    return Defense._(input);
  }

  Defense copyWith(int newValue) => Defense(newValue);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Defense($value)';
}
