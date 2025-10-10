/// ---------------------------------------------------------------------------
/// Fichier : lib/domain/characters/value_objects/class_id.dart
/// Rôle : Valider l'identifiant de classe (slug ASCII).
/// Dépendances : `equatable` uniquement.
/// Exemple d'usage :
///   final id = ClassId(' Guardian ');
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';

/// ClassId = Value Object garantissant un identifiant de classe valide.
///
/// * Pré-condition : chaîne non vide respectant le format slug ASCII.
/// * Post-condition : valeur trimée et passée en minuscules.
/// * Erreurs : `ArgumentError` si vide ou format invalide.
class ClassId extends Equatable {
  final String value;

  const ClassId._(this.value);

  factory ClassId(String input) {
    final raw = input.trim();
    if (raw.isEmpty) {
      throw ArgumentError('ClassId.nullOrEmpty');
    }
    final normalized = raw.toLowerCase();
    if (!_slug.hasMatch(normalized)) {
      throw ArgumentError('ClassId.invalidFormat');
    }
    return ClassId._(normalized);
    }

  static final RegExp _slug = RegExp(r'^[a-z0-9-]{3,40}$');

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
