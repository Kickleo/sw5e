/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/initiative.dart
/// Rôle : Stocker le modificateur d'initiative final.
/// Dépendances : `equatable` uniquement.
/// Exemple d'usage :
///   final init = Initiative(3);
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';

/// Initiative = Value Object portant le modificateur d'initiative final.
///
/// * Pré-condition : aucune (entier).
/// * Post-condition : immuable.
/// * Erreurs : `ArgumentError` si hors bornes gardes-fous.
class Initiative extends Equatable {
  static const int min = -10; // garde-fou
  static const int max = 20;  // garde-fou (ajuste si besoin)

  final int value;

  const Initiative._(this.value);

  factory Initiative(int input) {
    if (input < min || input > max) {
      throw ArgumentError('Initiative.invalidRange ($input not in $min..$max)');
    }
    return Initiative._(input);
  }

  Initiative copyWith(int newValue) => Initiative(newValue);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value >= 0 ? '+$value' : '$value';
}
