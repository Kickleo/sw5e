// lib/features/character_creation/domain/value_objects/background_id.dart
import 'package:equatable/equatable.dart';

/// Value Object : BackgroundId (slug ASCII, ex: "outlaw")
/// - Normalise en minuscules + trim
/// - Valide le format slug: ^[a-z0-9-]{3,50}$
/// - L'existence dans le catalogue est vérifiée ailleurs (use case/service).
class BackgroundId extends Equatable {
  final String value;

  const BackgroundId._(this.value);

  factory BackgroundId(String input) {
    final raw = input.trim();
    if (raw.isEmpty) {
      throw ArgumentError('BackgroundId.nullOrEmpty');
    }
    final normalized = raw.toLowerCase();
    if (!_slug.hasMatch(normalized)) {
      throw ArgumentError('BackgroundId.invalidFormat');
    }
    return BackgroundId._(normalized);
  }

  static final RegExp _slug = RegExp(r'^[a-z0-9-]{3,50}$');

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
