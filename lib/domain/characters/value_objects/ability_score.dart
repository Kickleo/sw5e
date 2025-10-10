/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/ability_score.dart
/// Rôle : Encapsuler un score de caractéristique (1..20) et exposer son
///        modificateur dérivé selon les règles Star Wars 5e.
/// Dépendances : `equatable` pour les comparaisons, aucune dépendance métier
///        additionnelle.
/// Exemple d'usage :
///   final score = AbilityScore(15); // modificateur = +2
/// ---------------------------------------------------------------------------
library;
import 'package:equatable/equatable.dart';

/// AbilityScore = Value Object garantissant qu'un score est compris entre 1 et
/// 20 inclus. Toute instanciation hors bornes déclenche un [ArgumentError].
class AbilityScore extends Equatable {
  /// Limite inférieure autorisée par les règles.
  static const int min = 1;

  /// Limite supérieure autorisée par les règles.
  static const int max = 20;

  /// Valeur immuable du score.
  final int value;

  const AbilityScore._(this.value);

  /// Crée une nouvelle instance tout en validant la plage autorisée.
  ///
  /// * Pré-condition : `input` doit être entre [min] et [max].
  /// * Post-condition : une instance immuable est retournée.
  /// * Erreurs : `ArgumentError` si l'entrée sort des bornes.
  factory AbilityScore(int input) {
    if (input < min || input > max) {
      throw ArgumentError(
        'AbilityScore.invalidRange ($input not in $min..$max)',
      );
    }
    return AbilityScore._(input);
  }

  /// Modificateur dérivé : ⌊(score - 10) / 2⌋.
  int get modifier => ((value - 10) / 2).floor();

  /// Permet de dériver un nouvel [AbilityScore] avec une autre valeur valide.
  AbilityScore copyWith(int newValue) => AbilityScore(newValue);

  @override
  List<Object?> get props => <Object?>[value];

  @override
  String toString() => 'AbilityScore($value, mod=$modifier)';
}
