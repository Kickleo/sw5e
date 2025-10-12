part of '../quick_create_page.dart';

class _SkillStep extends StatelessWidget {
  const _SkillStep({
    required this.availableSkills,
    required this.skillDefinitions,
    required this.chosenSkills,
    required this.requiredCount,
    required this.onToggle,
  });

  final List<String> availableSkills;
  final Map<String, SkillDef> skillDefinitions;
  final Set<String> chosenSkills;
  final int requiredCount;
  final ValueChanged<String> onToggle;

  String _titleCase(String slug) => slug
      .split(RegExp(r'[-_]'))
      .map(
        (part) =>
            part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
      )
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (requiredCount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.skillStepNoAdditionalChoices,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (availableSkills.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.skillStepNoSkills,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final sortedSkills = List<String>.from(availableSkills);
    sortedSkills.sort();
    final canSelectMore = chosenSkills.length < requiredCount;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.skillStepHeader(requiredCount, chosenSkills.length),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...sortedSkills.map((skillId) {
          final skillDef = skillDefinitions[skillId];
          final selected = chosenSkills.contains(skillId);
          final canToggle = selected || canSelectMore;
          final ability = skillDef?.ability ?? '';
          final subtitle = ability.isEmpty
              ? null
              : Text(l10n.skillStepAbilitySubtitle(ability));
          return Card(
            child: CheckboxListTile(
              value: selected,
              onChanged: canToggle ? (_) => onToggle(skillId) : null,
              title: Text(_titleCase(skillId)),
              subtitle: subtitle,
            ),
          );
        }),
        if (!canSelectMore)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              l10n.skillStepLimitReached,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
