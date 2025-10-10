/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/proficiency_bonus.dart
/// Rôle : Représenter le bonus de maîtrise calculé.
/// Dépendances : `equatable` et `Level`.
/// Exemple d'usage :
///   final prof = ProficiencyBonus.fromLevel(Level(1));
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';
import 'package:sw5e_manager/domain/characters/value_objects/level.dart';

/// ProficiencyBonus = Value Object pour le bonus de maîtrise dérivé du niveau.
///
/// * Pré-condition : niveau valide (1..20).
/// * Post-condition : immuable; `fromLevel` applique la table officielle.
/// * Erreurs : `ArgumentError` si niveau hors bornes.
class ProficiencyBonus extends Equatable {
  static const int min = 2;
  static const int max = 6;

  final int value;

  const ProficiencyBonus._(this.value);

  /// Crée un bonus explicite (si déjà calculé)
  factory ProficiencyBonus(int input) {
    if (input < min || input > max) {
      throw ArgumentError('ProficiencyBonus.invalidRange ($input not in $min..$max)');
    }
    return ProficiencyBonus._(input);
  }

  /// Fabrique depuis un Level (table standard 5e-like)
  factory ProficiencyBonus.fromLevel(Level level) {
    final l = level.value;
    final v = _valueForLevel(l);
    return ProficiencyBonus._(v);
  }

  static int _valueForLevel(int level) {
    if (level >= 1 && level <= 4) return 2;
    if (level >= 5 && level <= 8) return 3;
    if (level >= 9 && level <= 12) return 4;
    if (level >= 13 && level <= 16) return 5;
    if (level >= 17 && level <= 20) return 6;
    throw ArgumentError('Level out of bounds for proficiency bonus: $level');
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => '+$value';
}
