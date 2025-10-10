/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/character_name.dart
/// Rôle : Normaliser et sécuriser la saisie du nom de personnage côté domaine.
/// Dépendances : `equatable` pour exposer des comparaisons par valeur.
/// Exemple d'usage :
///   final name = CharacterName("  Obi-Wan Kenobi " );
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';

/// CharacterName = Value Object encapsulant les contraintes de nommage.
///
/// * Pré-condition : l'entrée ne doit pas être vide après normalisation.
/// * Post-condition : texte trimé, espaces multiples réduits, apostrophes
///   typographiques remplacées par des apostrophes simples.
/// * Erreurs : `ArgumentError` si vide, trop long (>50) ou contenant un
///   caractère non autorisé.
class CharacterName extends Equatable {
  /// Valeur normalisée du nom.
  final String value;

  const CharacterName._(this.value);

  /// Crée une instance à partir d'un texte brut.
  factory CharacterName(String input) {
    final String normalized = _normalize(input);

    if (normalized.isEmpty) {
      throw ArgumentError('CharacterName.empty');
    }
    if (normalized.length > 50) {
      throw ArgumentError('CharacterName.tooLong');
    }
    if (!_allowedChars.hasMatch(normalized)) {
      throw ArgumentError('CharacterName.invalidChars');
    }
    return CharacterName._(normalized);
  }

  /// Trim + collapse espaces + remplacement des apostrophes typographiques.
  static String _normalize(String raw) {
    String out = raw.trim();
    out = out.replaceAll('’', "'");
    out = out.replaceAll(RegExp(r'[\r\n\t]'), ' ');
    out = out.replaceAll(RegExp(r'\s+'), ' ');
    return out;
  }

  /// Autorise lettres/chiffres ASCII, espace, tiret, apostrophe et point.
  static final RegExp _allowedChars = RegExp(r"^[A-Za-z0-9 .'\-]+$");

  @override
  List<Object?> get props => <Object?>[value];

  @override
  String toString() => value;
}
