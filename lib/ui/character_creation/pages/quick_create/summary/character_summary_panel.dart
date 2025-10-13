part of '../quick_create_page.dart';

class _CharacterSummaryPanel extends StatelessWidget {
  const _CharacterSummaryPanel({required this.state});

  final QuickCreateState state;

  String _titleCase(String slug) => slug
      .split(RegExp(r'[-_]'))
      .map(
        (part) =>
            part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
      )
      .join(' ');

  String _localized(AppLocalizations l10n, LocalizedText? text) {
    if (text == null) {
      return l10n.summaryUnknown;
    }
    if (l10n.isFrench) {
      if (text.fr.isNotEmpty) {
        return text.fr;
      }
      if (text.en.isNotEmpty) {
        return text.en;
      }
    } else {
      if (text.en.isNotEmpty) {
        return text.en;
      }
      if (text.fr.isNotEmpty) {
        return text.fr;
      }
    }
    return l10n.summaryUnknown;
  }

  String _stepLabel(AppLocalizations l10n, QuickCreateStep step) {
    switch (step) {
      case QuickCreateStep.species:
        return l10n.summaryStepSpecies;
      case QuickCreateStep.abilities:
        return l10n.summaryStepAbilities;
      case QuickCreateStep.classes:
        return l10n.summaryStepClass;
      case QuickCreateStep.skills:
        return l10n.summaryStepSkills;
      case QuickCreateStep.equipment:
        return l10n.summaryStepEquipment;
      case QuickCreateStep.background:
        return l10n.summaryStepBackground;
    }
  }

  String _formatWeight(int grams) {
    if (grams.abs() >= 1000) {
      return '${(grams / 1000).toStringAsFixed(1)} kg';
    }
    return '$grams g';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final classDef = state.selectedClassDef;
    final abilityCards = QuickCreateState.abilityOrder.map((ability) {
      final score = state.abilityAssignments[ability];
      final modifier = score != null ? AbilityScore(score).modifier : null;
      final label = QuickCreateState.abilityLabels[ability] ?? ability.toUpperCase();
      final abbreviation =
          l10n.abilityAbbreviation(ability.toLowerCase());
      final modifierLabel = l10n.modifierLabel(modifier);
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$label ($abbreviation)',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(score?.toString() ?? '—',
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(modifierLabel),
            ],
          ),
        ),
      );
    }).toList();

    final chosenSkills = state.chosenSkills.toList()..sort();
    final purchasedEquipment = state.chosenEquipment.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final startingEquipment = <Widget>[];
    if (state.useStartingEquipment && classDef != null) {
      startingEquipment
        ..add(Text(l10n.summaryStartingEquipmentTitle,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)))
        ..add(const SizedBox(height: 4));
      for (final line in classDef.level1.startingEquipment) {
        final equipmentDef = state.equipmentDefinitions[line.id];
        final label = equipmentDef != null
            ? _localized(l10n, equipmentDef.name)
            : _titleCase(line.id);
        startingEquipment.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(l10n.startingEquipmentLine(label, line.qty)),
          ),
        );
      }
      startingEquipment.add(const SizedBox(height: 12));
    }

    final purchasedEquipmentWidgets = purchasedEquipment.map((entry) {
      final def = state.equipmentDefinitions[entry.key];
      final label = def != null
          ? _localized(l10n, def.name)
          : _titleCase(entry.key);
      final cost = def?.cost ?? 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          l10n.summaryPurchaseLine(label, entry.value, cost * entry.value),
        ),
      );
    }).toList();

    final totalWeight = state.totalInventoryWeightG;
    final capacity = state.carryingCapacityLimitG;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            l10n.summaryTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _SummarySection(
            title: l10n.summaryProgression,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: QuickCreateStep.values.map((step) {
                  final completed = state.stepIndex >= step.index;
                  final baseContainer =
                      theme.colorScheme.surfaceContainerHighest;
                  final highlight = theme.colorScheme.primary;
                  // Les étapes terminées bénéficient d'un léger voile de
                  // couleur primaire pour signaler la progression, tandis que
                  // les étapes restantes conservent un fond atténué.
                  final chipColor = completed
                      ? Color.alphaBlend(
                          highlight.withValues(alpha: 0.12),
                          baseContainer,
                        )
                      : baseContainer.withValues(alpha: 0.6);
                  final iconColor =
                      completed ? highlight : theme.colorScheme.outline;
                  final icon =
                      completed ? Icons.check_circle : Icons.radio_button_unchecked;
                  return Chip(
                    backgroundColor: chipColor,
                    avatar: Icon(icon, size: 18, color: iconColor),
                    label: Text(_stepLabel(l10n, step)),
                  );
                }).toList(),
              ),
            ],
          ),
          _SummarySection(
            title: l10n.summaryIdentity,
            children: [
              _SummaryRow(
                label: l10n.summaryName,
                value: state.characterName.isEmpty
                    ? l10n.summaryNotProvided
                    : state.characterName,
              ),
              _SummaryRow(
                label: l10n.summarySpeciesLabel,
                value: state.selectedSpecies != null
                    ? _titleCase(state.selectedSpecies!)
                    : l10n.summaryNotSelected(feminine: true),
              ),
              _SummaryRow(
                label: l10n.summaryClassLabel,
                value: state.selectedClass != null
                    ? _titleCase(state.selectedClass!)
                    : l10n.summaryNotSelected(feminine: true),
              ),
              _SummaryRow(
                label: l10n.summaryBackgroundLabel,
                value: state.selectedBackground != null
                    ? _titleCase(state.selectedBackground!)
                    : l10n.summaryNotSelected(),
              ),
            ],
          ),
          _SummarySection(
            title: l10n.summaryClassFeatures,
            children: [
              if (classDef == null)
                Text(l10n.summaryNoClassSelected)
              else ...[
                _SummaryRow(
                  label: l10n.summaryHitDie,
                  value: 'd${classDef.hitDie}',
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.summaryClassSkillChoice(
                    classDef.level1.proficiencies.skillsChoose,
                    classDef.level1.proficiencies.skillsFrom.length,
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                if (classDef.level1.startingEquipmentOptions.isEmpty)
                  Text(l10n.summaryNoEquipmentOptions)
                else ...[
                  Text(
                    l10n.summaryEquipmentOptionsTitle,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  ...classDef.level1.startingEquipmentOptions.map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${l10n.localizedCatalogLabel(option)}',
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
          _SummarySection(
            title: l10n.summarySpecies,
            children: [
              if (state.selectedSpeciesTraits.isEmpty &&
                  state.selectedSpeciesEffects.isEmpty)
                Text(l10n.summaryNoSpeciesTraits)
              else ...[
                for (final trait in state.selectedSpeciesTraits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _localized(l10n, trait.name),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(trait.description),
                      ],
                    ),
                  ),
                for (final effect in state.selectedSpeciesEffects)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          effect.title,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(effect.description),
                      ],
                    ),
                  ),
              ],
            ],
          ),
          _SummarySection(
            title: l10n.summaryAbilities,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: abilityCards,
              ),
            ],
          ),
          _SummarySection(
            title: l10n.summarySkills,
            children: [
              if (chosenSkills.isEmpty)
                Text(l10n.summarySkillsNone)
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.summarySkillsSelection(
                        chosenSkills.length,
                        state.skillChoicesRequired,
                      ),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    ...chosenSkills.map((skillId) {
                      final def = state.skillDefinitions[skillId];
                      final ability = def != null
                          ? l10n.abilityAbbreviation(def.ability)
                          : '—';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          l10n.summarySkillLine(
                            _titleCase(skillId),
                            ability,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
            ],
          ),
          _SummarySection(
            title: l10n.summaryEquipment,
            children: [
              if (startingEquipment.isEmpty && purchasedEquipmentWidgets.isEmpty)
                Text(l10n.summaryEquipmentNone)
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...startingEquipment,
                    ...purchasedEquipmentWidgets,
                  ],
                ),
            ],
          ),
          _SummarySection(
            title: l10n.summaryCarryingAndFinance,
            children: [
              _SummaryRow(
                label: l10n.summaryStartingCredits,
                value: '${state.availableCredits}',
              ),
              _SummaryRow(
                label: l10n.summaryCurrentCost,
                value: '${state.totalPurchasedEquipmentCost}',
              ),
              _SummaryRow(
                label: l10n.summaryRemainingCredits,
                value: '${state.remainingCredits}',
              ),
              _SummaryRow(
                label: l10n.summaryTotalWeight,
                value: totalWeight != null
                    ? _formatWeight(totalWeight)
                    : l10n.summaryUnknownWeight,
              ),
              _SummaryRow(
                label: l10n.summaryCarryCapacity,
                value: capacity != null
                    ? _formatWeight(capacity)
                    : l10n.summaryUnknownCapacity,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
