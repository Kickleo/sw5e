// lib/features/character_creation/domain/value_objects/character_trait.dart
import 'package:equatable/equatable.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/trait_id.dart';

/// Un trait possédé par le personnage.
/// Dans notre design actuel, tous les traits viennent **exclusivement de l'espèce**.
class CharacterTrait extends Equatable {
  final TraitId id;

  const CharacterTrait({required this.id});

  @override
  List<Object?> get props => [id];

  @override
  String toString() => 'Trait(${id.value})';
}
