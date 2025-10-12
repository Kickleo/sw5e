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

  String _localized(LocalizedText? text) {
    if (text == null) {
      return 'Inconnu';
    }
    if (text.fr.isNotEmpty) {
      return text.fr;
    }
    if (text.en.isNotEmpty) {
      return text.en;
    }
    return 'Inconnu';
  }

  String _stepLabel(QuickCreateStep step) {
    switch (step) {
      case QuickCreateStep.species:
        return 'Espèce';
      case QuickCreateStep.abilities:
        return 'Caractéristiques';
      case QuickCreateStep.classes:
        return 'Classe';
      case QuickCreateStep.skills:
        return 'Compétences';
      case QuickCreateStep.equipment:
        return 'Équipement';
      case QuickCreateStep.background:
        return 'Historique';
    }
  }

  String _formatWeight(int grams) {
    if (grams.abs() >= 1000) {
      return '${(grams / 1000).toStringAsFixed(1)} kg';
    }
    return '$grams g';
  }

  String _abilityAbbreviation(String ability) {
    return QuickCreateState.abilityAbbreviations[ability] ?? ability.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classDef = state.selectedClassDef;
    final abilityCards = QuickCreateState.abilityOrder.map((ability) {
      final score = state.abilityAssignments[ability];
      final modifier = score != null ? AbilityScore(score).modifier : null;
      final label = QuickCreateState.abilityLabels[ability] ?? ability.toUpperCase();
      final abbreviation = _abilityAbbreviation(ability);
      final modifierLabel = modifier == null
          ? 'Mod —'
          : 'Mod ${modifier >= 0 ? '+' : ''}$modifier';
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
        ..add(Text('Équipement de départ',
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)))
        ..add(const SizedBox(height: 4));
      for (final line in classDef.level1.startingEquipment) {
        final equipmentDef = state.equipmentDefinitions[line.id];
        final label = equipmentDef != null
            ? _localized(equipmentDef.name)
            : _titleCase(line.id);
        startingEquipment.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• $label ×${line.qty}'),
          ),
        );
      }
      startingEquipment.add(const SizedBox(height: 12));
    }

    final purchasedEquipmentWidgets = purchasedEquipment.map((entry) {
      final def = state.equipmentDefinitions[entry.key];
      final label = def != null ? _localized(def.name) : _titleCase(entry.key);
      final cost = def?.cost ?? 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text('• $label ×${entry.value} (${cost * entry.value}cr)'),
      );
    }).toList();

    final totalWeight = state.totalInventoryWeightG;
    final capacity = state.carryingCapacityLimitG;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            'Résumé du personnage',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _SummarySection(
            title: 'Progression',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: QuickCreateStep.values.map((step) {
                  final completed = state.stepIndex >= step.index;
                  final baseContainer =
                      theme.colorScheme.surfaceContainerHighest;
                  final chipColor = completed
                      ? baseContainer
                      : baseContainer.withValues(alpha: 0.6);
                  return Chip(
                    backgroundColor: chipColor,
                    avatar: Icon(
                      completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: completed ? Colors.green : theme.colorScheme.outline,
                    ),
                    label: Text(_stepLabel(step)),
                  );
                }).toList(),
              ),
            ],
          ),
          _SummarySection(
            title: 'Identité',
            children: [
              _SummaryRow(
                label: 'Nom',
                value: state.characterName.isEmpty
                    ? 'Non renseigné'
                    : state.characterName,
              ),
              _SummaryRow(
                label: 'Espèce',
                value: state.selectedSpecies != null
                    ? _titleCase(state.selectedSpecies!)
                    : 'Non sélectionnée',
              ),
              _SummaryRow(
                label: 'Classe',
                value: state.selectedClass != null
                    ? _titleCase(state.selectedClass!)
                    : 'Non sélectionnée',
              ),
              _SummaryRow(
                label: 'Historique',
                value: state.selectedBackground != null
                    ? _titleCase(state.selectedBackground!)
                    : 'Non sélectionné',
              ),
            ],
          ),
          _SummarySection(
            title: 'Caractéristiques de classe',
            children: [
              if (classDef == null)
                const Text('Aucune classe sélectionnée pour l’instant.')
              else ...[
                _SummaryRow(
                  label: 'Dé de vie',
                  value: 'd${classDef.hitDie}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Compétences à choisir : '
                  '${classDef.level1.proficiencies.skillsChoose} parmi '
                  '${classDef.level1.proficiencies.skillsFrom.length}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                if (classDef.level1.startingEquipmentOptions.isEmpty)
                  const Text('Cette classe ne propose pas d’options d’équipement.')
                else ...[
                  Text(
                    'Options d’équipement de départ :',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  ...classDef.level1.startingEquipmentOptions.map(
                    (optionId) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• ${_titleCase(optionId)}'),
                    ),
                  ),
                ],
              ],
            ],
          ),
          _SummarySection(
            title: 'Espèce',
            children: [
              if (state.selectedSpeciesTraits.isEmpty &&
                  state.selectedSpeciesEffects.isEmpty)
                const Text('Aucun trait d’espèce sélectionné.')
              else ...[
                for (final trait in state.selectedSpeciesTraits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _localized(trait.name),
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
            title: 'Caractéristiques',
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: abilityCards,
              ),
            ],
          ),
          _SummarySection(
            title: 'Compétences',
            children: [
              if (chosenSkills.isEmpty)
                const Text('Aucune compétence choisie pour le moment.')
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sélection (${chosenSkills.length}/${state.skillChoicesRequired})',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    ...chosenSkills.map((skillId) {
                      final def = state.skillDefinitions[skillId];
                      final ability =
                          def != null ? _abilityAbbreviation(def.ability) : '—';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• ${_titleCase(skillId)} ($ability)'),
                      );
                    }),
                  ],
                ),
            ],
          ),
          _SummarySection(
            title: 'Équipement',
            children: [
              if (startingEquipment.isEmpty && purchasedEquipmentWidgets.isEmpty)
                const Text('Aucun équipement sélectionné.')
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
            title: 'Capacité de charge & finances',
            children: [
              _SummaryRow(
                label: 'Crédits de départ',
                value: '${state.availableCredits}',
              ),
              _SummaryRow(
                label: 'Coût actuel',
                value: '${state.totalPurchasedEquipmentCost}',
              ),
              _SummaryRow(
                label: 'Crédits restants',
                value: '${state.remainingCredits}',
              ),
              _SummaryRow(
                label: 'Poids total',
                value: totalWeight != null
                    ? _formatWeight(totalWeight)
                    : 'Indéterminé',
              ),
              _SummaryRow(
                label: 'Charge maximale',
                value: capacity != null
                    ? _formatWeight(capacity)
                    : 'Indéterminée',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
