/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/character_trait.dart
/// Rôle : Représenter un trait de personnage et sa source.
/// Dépendances : `equatable` et `TraitId`.
/// Exemple d'usage :
///   final trait = CharacterTrait(id: TraitId('nimble-escape'), source: 'species');
/// ---------------------------------------------------------------------------
library;
import 'package:equatable/equatable.dart';
import 'package:sw5e_manager/domain/characters/value_objects/trait_id.dart';

/// CharacterTrait = Value Object décrivant un trait accordé au personnage.
///
/// * Pré-condition : `id` doit être un [TraitId] valide.
/// * Post-condition : immuable, comparable par valeur.
/// * Erreurs : aucune (le `TraitId` valide est exigé à la construction).
class CharacterTrait extends Equatable {
  final TraitId id;

  const CharacterTrait({required this.id});

  @override
  List<Object?> get props => [id];

  @override
  String toString() => 'Trait(${id.value})';
}
