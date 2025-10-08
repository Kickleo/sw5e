// lib/features/character_creation/domain/value_objects/class_id.dart
import 'package:equatable/equatable.dart';

/// Value Object : ClassId (slug ASCII, ex: "guardian")
/// - Normalise en minuscules + trim
/// - Valide le format slug: ^[a-z0-9-]{3,40}$
/// - L'existence dans le catalogue est vérifiée ailleurs (use case/service).
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
