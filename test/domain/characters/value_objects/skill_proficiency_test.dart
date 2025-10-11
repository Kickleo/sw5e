/// ---------------------------------------------------------------------------
/// Fichier test : skill_proficiency_test.dart
/// Rôle : Vérifier les règles du Value Object [SkillProficiency].
/// ---------------------------------------------------------------------------
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:sw5e_manager/domain/characters/value_objects/skill_proficiency.dart';

void main() {
  group('SkillProficiency', () {
    test('crée une maîtrise valide avec sources uniques', () {
      final skill = SkillProficiency(
        skillId: 'stealth',
        state: ProficiencyState.proficient,
        sources: const [ProficiencySource.classSource],
      );

      expect(skill.skillId, equals('stealth'));
      expect(skill.sources, contains(ProficiencySource.classSource));
    });

    test('rejette un identifiant invalide', () {
      expect(
        () => SkillProficiency(
          skillId: 'ste alth',
          state: ProficiencyState.proficient,
          sources: const [ProficiencySource.classSource],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('requiert une source quand proficient', () {
      expect(
        () => SkillProficiency(
          skillId: 'stealth',
          state: ProficiencyState.proficient,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('interdit des sources quand non maîtrisé', () {
      expect(
        () => SkillProficiency(
          skillId: 'stealth',
          state: ProficiencyState.untrained,
          sources: const [ProficiencySource.background],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('refuse les doublons de sources', () {
      expect(
        () => SkillProficiency(
          skillId: 'stealth',
          state: ProficiencyState.proficient,
          sources: const [
            ProficiencySource.classSource,
            ProficiencySource.classSource,
          ],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
