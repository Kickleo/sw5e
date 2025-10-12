part of '../quick_create_page.dart';

class _AbilitiesStep extends HookWidget {
  const _AbilitiesStep({
    required this.mode,
    required this.assignments,
    required this.pool,
    required this.onModeChanged,
    required this.onReroll,
    required this.onAssign,
  });

  final AbilityGenerationMode mode;
  final Map<String, int?> assignments;
  final List<int> pool;
  final ValueChanged<AbilityGenerationMode> onModeChanged;
  final VoidCallback onReroll;
  final void Function(String ability, int? value) onAssign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final abilityOrder = QuickCreateState.abilityOrder;
    final abilityLabels = QuickCreateState.abilityLabels;
    final abilityAbbreviations = QuickCreateState.abilityAbbreviations;

    final poolCounts = <int, int>{};
    for (final value in pool) {
      poolCounts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }
    final sortedPoolEntries = poolCounts.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final assignedCounts = <int, int>{};
    for (final entry in assignments.entries) {
      final value = entry.value;
      if (value == null) continue;
      assignedCounts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }

    Widget buildControl(String ability) {
      final currentValue = assignments[ability];
      if (mode == AbilityGenerationMode.manual) {
        return _ManualAbilityField(
          key: ValueKey('manual-$ability'),
          initialValue: currentValue,
          onChanged: (value) => onAssign(ability, value),
        );
      }

      final optionValues = <int>{};
      for (final entry in poolCounts.entries) {
        final value = entry.key;
        final available = entry.value;
        var used = assignedCounts[value] ?? 0;
        if (currentValue == value && used > 0) {
          used -= 1;
        }
        if (used < available) {
          optionValues.add(value);
        }
      }
      if (currentValue != null) {
        optionValues.add(currentValue);
      }
      final sortedOptions = optionValues.toList()
        ..sort((a, b) => b.compareTo(a));

      return DropdownButtonFormField<int?>(
        key: ValueKey('dropdown-$ability-${mode.name}'),
        initialValue: currentValue,
        decoration: const InputDecoration(
          labelText: 'Score',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('—')),
          ...sortedOptions.map(
            (value) => DropdownMenuItem<int?>(
              value: value,
              child: Text(value.toString()),
            ),
          ),
        ],
        onChanged: (value) => onAssign(ability, value),
      );
    }

    String modifierText(int? score) {
      if (score == null) return 'Mod —';
      final modifier = AbilityScore(score).modifier;
      final sign = modifier >= 0 ? '+' : '';
      return 'Mod $sign$modifier';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Attribuez vos caractéristiques',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: RadioGroup<AbilityGenerationMode>(
            groupValue: mode,
            onChanged: (value) {
              if (value != null) onModeChanged(value);
            },
            child: Column(
              children: [
                const RadioListTile<AbilityGenerationMode>(
                  value: AbilityGenerationMode.standardArray,
                  title: Text('Tableau standard'),
                  subtitle: Text(
                    'Utiliser les scores fixes 15, 14, 13, 12, 10 et 8.',
                  ),
                ),
                const Divider(height: 0),
                const RadioListTile<AbilityGenerationMode>(
                  value: AbilityGenerationMode.roll,
                  title: Text('Lancer les dés'),
                  subtitle: Text(
                    'Lancez 4d6, conservez les 3 meilleurs et assignez les 6 scores obtenus.',
                  ),
                ),
                if (mode == AbilityGenerationMode.roll)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 12,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: onReroll,
                        icon: const Icon(Icons.casino),
                        label: const Text('Lancer les dés'),
                      ),
                    ),
                  ),
                const Divider(height: 0),
                const RadioListTile<AbilityGenerationMode>(
                  value: AbilityGenerationMode.manual,
                  title: Text('Saisie manuelle'),
                  subtitle: Text(
                    'Entrez vous-même les scores obtenus ailleurs et assignez-les.',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (mode != AbilityGenerationMode.manual) ...[
          Text('Scores disponibles', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (sortedPoolEntries.isEmpty)
            const Text('Aucun score généré pour le moment.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in sortedPoolEntries)
                  Chip(
                    label: Text(
                      entry.value > 1
                          ? '${entry.key} ×${entry.value}'
                          : entry.key.toString(),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 16),
        ] else ...[
          const Text('Chaque champ accepte une valeur entre 1 et 20.'),
          const SizedBox(height: 16),
        ],
        ...abilityOrder.map((ability) {
          final label = abilityLabels[ability] ?? ability.toUpperCase();
          final abbr = abilityAbbreviations[ability] ?? ability.toUpperCase();
          final currentValue = assignments[ability];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$label ($abbr)',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        modifierText(currentValue),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  buildControl(ability),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        const Text(
          'Astuce : pour calculer le modificateur, soustrayez 10 du score et divisez par 2 (arrondi à l’inférieur).',
        ),
      ],
    );
  }
}
