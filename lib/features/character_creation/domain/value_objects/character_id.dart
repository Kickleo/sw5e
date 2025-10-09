// lib/features/character_creation/domain/value_objects/character_id.dart
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Value Object : identifiant unique d'un personnage sauvegardé.
///
/// Invariants simples (MVP) :
/// - Chaîne non vide après trim.
/// - Caractères autorisés : lettres/chiffres ASCII + "-" et "_".
/// - Génération fournie par [CharacterId.generate].
class CharacterId extends Equatable {
  final String value;

  const CharacterId._(this.value);

  factory CharacterId(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('CharacterId.empty');
    }
    if (!_allowedChars.hasMatch(normalized)) {
      throw ArgumentError('CharacterId.invalidChars');
    }
    return CharacterId._(normalized);
  }

  factory CharacterId.generate() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final random = _random.nextInt(1 << 20).toRadixString(16).padLeft(5, '0');
    return CharacterId._('c_${timestamp}_$random');
  }

  static final RegExp _allowedChars = RegExp(r'^[A-Za-z0-9_\-]+$');
  static final Random _random = Random();

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
