// lib/features/character_creation/domain/value_objects/skill_proficiency.dart
import 'package:equatable/equatable.dart';

/// État de maîtrise (MVP : binaire)
enum ProficiencyState { untrained, proficient }

/// Source(s) d’une maîtrise
enum ProficiencySource { classSource, background, species, feat, other }

/// VO SkillProficiency : maîtrise d'une compétence identifiée par un slug.
/// - skillId : slug ASCII ^[a-z0-9-]{3,40}$
/// - state   : untrained | proficient
/// - sources : obligatoire si state = proficient ; aucun doublon
class SkillProficiency extends Equatable {
  final String skillId; // slug (ex: "perception")
  final ProficiencyState state;
  final Set<ProficiencySource> sources;

  const SkillProficiency._(this.skillId, this.state, this.sources);

  factory SkillProficiency({
    required String skillId,
    required ProficiencyState state,
    Iterable<ProficiencySource> sources = const [],
  }) {
    final id = skillId.trim().toLowerCase();
    if (!_slug.hasMatch(id)) {
      throw ArgumentError('SkillProficiency.invalidSkillId');
    }

    final list = List<ProficiencySource>.from(sources);
    final set = list.toSet();
    if (list.length != set.length) {
      throw ArgumentError('SkillProficiency.duplicateSources');
    }

    if (state == ProficiencyState.proficient && set.isEmpty) {
      throw ArgumentError('SkillProficiency.missingSource');
    }
    if (state == ProficiencyState.untrained && set.isNotEmpty) {
      // On impose aucune source quand non maîtrisé (évite les incohérences).
      throw ArgumentError('SkillProficiency.sourcesNotAllowedForUntrained');
    }

    return SkillProficiency._(id, state, set);
  }

  /// Copie immuable avec revalidation
  SkillProficiency copyWith({
    ProficiencyState? state,
    Iterable<ProficiencySource>? sources,
  }) =>
      SkillProficiency(
        skillId: skillId,
        state: state ?? this.state,
        sources: sources ?? this.sources,
      );

  static final RegExp _slug = RegExp(r'^[a-z0-9-]{3,40}$');

  @override
  List<Object?> get props {
    final sortedSources = sources.map((e) => e.name).toList()..sort();
    return [skillId, state, sortedSources];
  }

  @override
  String toString() =>
      'SkillProficiency(skillId:$skillId, state:$state, sources:$sources)';
}
