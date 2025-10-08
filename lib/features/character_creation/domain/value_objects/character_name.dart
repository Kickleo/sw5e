// lib/features/character_creation/domain/value_objects/character_name.dart
import 'package:equatable/equatable.dart';

/// Value Object : CharacterName
/// Invariants (MVP) :
/// - Longueur 1..50 après normalisation (trim + espaces multiples -> 1)
/// - Caractères autorisés (implémentation MVP, volontairement stricte) :
///   ASCII lettres/chiffres, espace, tiret (-), apostrophe droite (') ou typographique (’), point (.).
///   👉 On pourra élargir plus tard aux lettres Unicode si besoin.
/// - Pas de retours ligne / tabulations / emojis / caractères de contrôle.
class CharacterName extends Equatable {
  final String value;

  const CharacterName._(this.value);

  factory CharacterName(String input) {
    final normalized = _normalize(input);

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

  /// Trim + collapse espaces + remplace l’apostrophe typographique par la simple.
  static String _normalize(String s) {
    var out = s.trim();
    // Remplace les apostrophes typographiques par des apostrophes simples
    out = out.replaceAll('’', '\'');
    // Supprime retours ligne / tabulations
    out = out.replaceAll(RegExp(r'[\r\n\t]'), ' ');
    // Réduit les espaces multiples
    out = out.replaceAll(RegExp(r'\s+'), ' ');
    return out;
  }

  // Regex autorisée : lettres/chiffres ASCII, espace, tiret, apostrophe, point.
  static final RegExp _allowedChars = RegExp(r"^[A-Za-z0-9 .'\-]+$");

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
