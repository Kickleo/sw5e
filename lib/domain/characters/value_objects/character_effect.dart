/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/character_effect.dart
/// Rôle : Décrire un effet accordé à un personnage dans un brouillon de
///        création (bonus passif, action utilisable, etc.).
/// Dépendances : `equatable` pour l'égalité par valeur.
/// ---------------------------------------------------------------------------
library;

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Catégorie d'un effet disponible pour le personnage en cours de création.
enum CharacterEffectCategory { passive, action, bonusAction }

/// Effet accordé au personnage (bonus, action utilisable, etc.).
@immutable
class CharacterEffect extends Equatable {
  const CharacterEffect({
    required this.source,
    required this.title,
    required this.description,
    required this.category,
  });

  /// Identifiant logique de la source (ex: `trait:nimble-escape`).
  final String source;

  /// Titre lisible pour l'effet.
  final String title;

  /// Description textuelle complète de l'effet.
  final String description;

  /// Catégorie indiquant comment l'effet est consommé.
  final CharacterEffectCategory category;

  @override
  List<Object?> get props => <Object?>[source, title, description, category];
}
