/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/level.dart
/// Rôle : Valider le niveau de personnage (>=1).
/// Dépendances : `equatable` uniquement.
/// Exemple d'usage :
///   final level = Level(1);
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';

/// Level = Value Object contrôlant le niveau d'un personnage.
///
/// * Pré-condition : valeur entre 1 et 20.
/// * Post-condition : immuable.
/// * Erreurs : `ArgumentError` si valeur hors bornes.
class Level extends Equatable {
  static const int min = 1;
  static const int max = 20;

  final int value;

  const Level._(this.value);

  /// Crée un Level valide ou lève ArgumentError.
  factory Level(int input) {
    if (input < min || input > max) {
      throw ArgumentError('Level.invalidRange ($input not in $min..$max)');
    }
    return Level._(input);
  }

  /// Raccourci pratique pour le MVP.
  static const Level one = Level._(1);

  bool get isMvp => value == 1;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Level($value)';
}
