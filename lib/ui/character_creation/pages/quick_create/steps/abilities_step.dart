part of '../quick_create_page.dart';

class _AbilitiesStep extends HookWidget {
  const _AbilitiesStep({
    required this.mode,
    required this.assignments,
    required this.pool,
    required this.abilityLabel,
    required this.abilityDefinitions,
    required this.onModeChanged,
    required this.onReroll,
    required this.onAssign,
  });

  final AbilityGenerationMode mode;
  final Map<String, int?> assignments;
  final List<int> pool;
  final String Function(String ability) abilityLabel;
  final Map<String, AbilityDef> abilityDefinitions;
  final ValueChanged<AbilityGenerationMode> onModeChanged;
  final VoidCallback onReroll;
  final void Function(String ability, int? value) onAssign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final abilityOrder = QuickCreateState.abilityOrder;

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
        decoration: InputDecoration(
          labelText: l10n.abilityScoreLabel,
          border: const OutlineInputBorder(),
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
      if (score == null) return l10n.modifierLabel(null);
      final modifier = AbilityScore(score).modifier;
      return l10n.modifierLabel(modifier);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.abilitiesHeader,
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
                RadioListTile<AbilityGenerationMode>(
                  value: AbilityGenerationMode.standardArray,
                  title: Text(l10n.abilityGenerationStandardArray),
                  subtitle: Text(l10n.abilityGenerationStandardArrayDesc),
                ),
                const Divider(height: 0),
                RadioListTile<AbilityGenerationMode>(
                  value: AbilityGenerationMode.roll,
                  title: Text(l10n.abilityGenerationRoll),
                  subtitle: Text(l10n.abilityGenerationRollDesc),
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
                        label: Text(l10n.rerollDice),
                      ),
                    ),
                  ),
                const Divider(height: 0),
                RadioListTile<AbilityGenerationMode>(
                  value: AbilityGenerationMode.manual,
                  title: Text(l10n.abilityGenerationManual),
                  subtitle: Text(l10n.abilityGenerationManualDesc),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (mode != AbilityGenerationMode.manual) ...[
          Text(l10n.availableScores, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (sortedPoolEntries.isEmpty)
            Text(l10n.noGeneratedScores)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in sortedPoolEntries)
                  Chip(
                    label: Text(
                      l10n.abilityScoreChip(entry.key, entry.value),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 16),
        ] else ...[
          Text(l10n.manualScoreHint),
          const SizedBox(height: 16),
        ],
        ...abilityOrder.map((ability) {
          final label = abilityLabel(ability);
          final abbr = l10n.abilityAbbreviation(ability);
          final currentValue = assignments[ability];
          final AbilityDef? definition = abilityDefinitions[ability];
          String? description;
          if (definition?.description != null) {
            final String resolved =
                l10n.localizedCatalogLabel(definition!.description!).trim();
            if (resolved.isNotEmpty) {
              description = resolved;
            }
          }
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
                  if (description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Text(l10n.abilityTip),
      ],
    );
  }
}
