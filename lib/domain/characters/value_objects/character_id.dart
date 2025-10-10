/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/character_id.dart
/// Rôle : Garantir l'unicité et la validité syntaxique des identifiants
///        de personnages persistés.
/// Dépendances : `dart:math` pour la génération pseudo-aléatoire,
///        `equatable` pour comparer les instances.
/// Exemple d'usage :
///   final id = CharacterId.generate();
/// ---------------------------------------------------------------------------
library;
import 'dart:math';

import 'package:equatable/equatable.dart';

/// CharacterId = Value Object représentant un identifiant unique et propre.
///
/// * Pré-condition : pour `CharacterId(String)`, la chaîne doit contenir
///   uniquement lettres/chiffres ASCII, tirets bas ou tirets.
/// * Post-condition : la valeur est stockée trimée et non vide.
/// * Erreurs : `ArgumentError` si vide ou avec un caractère interdit.
class CharacterId extends Equatable {
  /// Valeur immuable (format slug interne).
  final String value;

  const CharacterId._(this.value);

  /// Crée un [CharacterId] à partir d'une chaîne existante.
  factory CharacterId(String raw) {
    final String normalized = raw.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('CharacterId.empty');
    }
    if (!_allowedChars.hasMatch(normalized)) {
      throw ArgumentError('CharacterId.invalidChars');
    }
    return CharacterId._(normalized);
  }

  /// Génère un identifiant unique basé sur le temps + une composante aléatoire.
  factory CharacterId.generate() {
    final String timestamp =
        DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final String random =
        _random.nextInt(1 << 20).toRadixString(16).padLeft(5, '0');
    return CharacterId._('c_${timestamp}_$random');
  }

  /// Autorise lettres/chiffres ASCII, tirets bas et tirets classiques.
  static final RegExp _allowedChars = RegExp(r'^[A-Za-z0-9_-]+$');

  static final Random _random = Random();

  @override
  List<Object?> get props => <Object?>[value];

  @override
  String toString() => value;
}
