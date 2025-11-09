part of '../quick_create_page.dart';

class _CharacterSummaryPanel extends StatelessWidget {
  const _CharacterSummaryPanel({required this.state});

  final QuickCreateState state;

  String _titleCase(String slug) => slug
      .split(RegExp(r'[\-_.]'))
      .map(
        (part) =>
            part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
      )
      .join(' ');

  String _localized(AppLocalizations l10n, LocalizedText? text) {
    if (text == null) {
      return l10n.summaryUnknown;
    }
    final String? resolved = text.maybeResolve(
      l10n.languageCode,
      fallbackLanguageCode: 'en',
    );
    if (resolved != null && resolved.trim().isNotEmpty) {
      return resolved.trim();
    }
    final String fallback = text.resolve('en');
    if (fallback.trim().isNotEmpty) {
      return fallback.trim();
    }
    return l10n.summaryUnknown;
  }

  String _backgroundSkillLabel(AppLocalizations l10n, String id) {
    final SkillDef? def = state.backgroundSkillDefinitions[id];
    if (def != null) {
      final String label = l10n.localizedCatalogLabel(def.name).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }

  String _backgroundEquipmentLabel(AppLocalizations l10n, String id) {
    final EquipmentDef? def =
        state.backgroundEquipmentDefinitions[id] ?? state.equipmentDefinitions[id];
    if (def != null) {
      final String label = l10n.localizedCatalogLabel(def.name).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }

  List<Widget> _backgroundPersonalitySection(
    ThemeData theme,
    AppLocalizations l10n,
    String title,
    List<LocalizedText> values,
  ) {
    if (values.isEmpty) {
      return const <Widget>[];
    }
    return <Widget>[
      Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      ...values.map((LocalizedText value) => Text('• ${_localized(l10n, value)}')),
      const SizedBox(height: 8),
    ];
  }

  String _featureEffectText(
    AppLocalizations l10n,
    CatalogFeatureEffect effect,
  ) {
    if (effect.text == null) {
      return '';
    }
    return l10n.localizedCatalogLabel(effect.text!).trim();
  }

  List<String> _equipmentMetadata(
    AppLocalizations l10n,
    EquipmentDef? def,
  ) {
    if (def == null) {
      return const <String>[];
    }
    return l10n.equipmentMetadataLines(def);
  }

  Widget _buildEquipmentLine(
    ThemeData theme,
    String primaryLine,
    List<String> metadata,
  ) {
    if (metadata.isEmpty) {
      return Text(primaryLine);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(primaryLine),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: metadata
                .map(
                  (line) => Text(
                    line,
                    style: theme.textTheme.bodySmall,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
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
      final label = state.resolveAbilityLabel(
        ability,
        locale: l10n.languageCode,
        fallbackLocale: 'en',
      );
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
        final List<String> metadata =
            _equipmentMetadata(l10n, equipmentDef);
        startingEquipment.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildEquipmentLine(
              theme,
              l10n.startingEquipmentLine(label, line.qty),
              metadata,
            ),
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
        child: _buildEquipmentLine(
          theme,
          l10n.summaryPurchaseLine(label, entry.value, cost * entry.value),
          _equipmentMetadata(l10n, def),
        ),
      );
    }).toList();

    final totalWeight = state.totalInventoryWeightG;
    final capacity = state.carryingCapacityLimitG;

    final List<String> customizationOptionIds =
        state.selectedCustomizationOptions.toList()..sort();
    final bool showCustomizationOptions =
        CustomizationOptionDetailsList.hasDisplayableContent(
      customizationOptionIds,
    );
    final Widget customizationDetails = CustomizationOptionDetailsList(
      optionIds: customizationOptionIds,
      optionDefinitions: state.customizationOptionDefinitions,
    );

    final List<String> forcePowerIds =
        state.selectedForcePowers.toList()..sort();
    final bool showForcePowers =
        PowerDetailsList.hasDisplayableContent(forcePowerIds);
    final Widget forcePowerDetails = PowerDetailsList(
      powerIds: forcePowerIds,
      powerDefinitions: state.forcePowerDefinitions,
    );

    final List<String> techPowerIds =
        state.selectedTechPowers.toList()..sort();
    final bool showTechPowers =
        PowerDetailsList.hasDisplayableContent(techPowerIds);
    final Widget techPowerDetails = PowerDetailsList(
      powerIds: techPowerIds,
      powerDefinitions: state.techPowerDefinitions,
    );

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
                    ? _selectionLabel(
                        l10n,
                        state.selectedSpecies!,
                        state.speciesLabels[state.selectedSpecies!],
                      )
                    : l10n.summaryNotSelected(feminine: true),
              ),
              ...(() {
                final SpeciesDef? speciesDef = state.selectedSpeciesDef;
                if (speciesDef == null) {
                  return const <Widget>[];
                }
                final List<SpeciesAbilityBonus> abilityBonuses =
                    speciesDef.abilityBonuses;
                if (!SpeciesAbilityBonusesCard
                    .hasDisplayableContent(abilityBonuses)) {
                  return const <Widget>[];
                }
                final SpeciesAbilityBonusFormatter formatter =
                    SpeciesAbilityBonusFormatter(
                  SpeciesEffectLocalizationCatalog.forLanguage(
                    l10n.languageCode,
                  ),
                );
                final List<String> bonusLabels = abilityBonuses
                    .map(formatter.format)
                    .map((String value) => value.trim())
                    .where((String value) => value.isNotEmpty)
                    .toList();
                if (bonusLabels.isEmpty) {
                  return const <Widget>[];
                }
                return <Widget>[
                  _SummaryRow(
                    label: l10n.speciesAbilityBonusesTitle,
                    value: bonusLabels.join(', '),
                  ),
                ];
              })(),
              ...(() {
                final List<String> labels = <String>[];
                final Set<String> normalized = <String>{};
                for (final LanguageDef language in state.selectedSpeciesLanguages) {
                  final String label =
                      l10n.localizedCatalogLabel(language.name).trim();
                  if (label.isEmpty) {
                    continue;
                  }
                  final String key = label.toLowerCase();
                  if (!normalized.add(key)) {
                    continue;
                  }
                  labels.add(label);
                }

                if (labels.isNotEmpty) {
                  return <Widget>[
                    _SummaryRow(
                      label: l10n.languagesTitle,
                      value: labels.join(', '),
                    ),
                  ];
                }

                final SpeciesDef? species = state.selectedSpeciesDef;
                if (species != null && species.languageIds.isNotEmpty) {
                  final Set<String> languageLabels = <String>{};
                  for (final String languageId in species.languageIds) {
                    final LanguageDef? language =
                        state.languageDefinitions[languageId];
                    if (language != null) {
                      final String resolved =
                          l10n.localizedCatalogLabel(language.name).trim();
                      if (resolved.isNotEmpty) {
                        languageLabels.add(resolved);
                        continue;
                      }
                    }
                    if (languageId.isNotEmpty) {
                      languageLabels.add(_titleCase(languageId));
                    }
                  }
                  if (languageLabels.isNotEmpty) {
                    return <Widget>[
                      _SummaryRow(
                        label: l10n.languagesTitle,
                        value: languageLabels.join(', '),
                      ),
                    ];
                  }
                }

                final LocalizedText? fallback = state.selectedSpeciesDef?.languages;
                if (fallback != null) {
                  final String value =
                      l10n.localizedCatalogLabel(fallback).trim();
                  if (value.isNotEmpty) {
                    return <Widget>[
                      _SummaryRow(
                        label: l10n.languagesTitle,
                        value: value,
                      ),
                    ];
                  }
                }

                return const <Widget>[];
              })(),
              _SummaryRow(
                label: l10n.summaryClassLabel,
                value: state.selectedClass != null
                    ? _selectionLabel(
                        l10n,
                        state.selectedClass!,
                        state.classLabels[state.selectedClass!],
                      )
                    : l10n.summaryNotSelected(feminine: true),
              ),
              _SummaryRow(
                label: l10n.summaryBackgroundLabel,
                value: state.selectedBackground != null
                    ? _selectionLabel(
                        l10n,
                        state.selectedBackground!,
                        state.backgroundLabels[state.selectedBackground!],
                      )
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
                if (classDef.multiclassing?.hasAbilityRequirements ?? false)
                  ...[
                    ClassMulticlassingDetails(
                      classDef: classDef,
                      abilityDefinitions: state.abilityDefinitions,
                      headingStyle: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                  ],
                if (_hasPowerInfo(classDef)) ...[
                  ClassPowerDetails(classDef: classDef),
                  const SizedBox(height: 8),
                ],
                if (classDef.level1.classFeatures.isNotEmpty) ...[
                  ClassFeatureList(
                    heading: l10n.summaryClassLevel1FeaturesTitle,
                    headingStyle: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  features: classDef.level1.classFeatures,
                ),
                const SizedBox(height: 8),
              ],
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
          if (showCustomizationOptions)
            _SummarySection(
              title: l10n.characterCustomizationOptionsTitle,
              children: [customizationDetails],
            ),
          if (showForcePowers)
            _SummarySection(
              title: l10n.characterForcePowersTitle,
              children: [forcePowerDetails],
            ),
          if (showTechPowers)
            _SummarySection(
              title: l10n.characterTechPowersTitle,
              children: [techPowerDetails],
            ),
          _SummarySection(
            title: l10n.summaryBackgroundDetails,
            children: [
              if (state.selectedBackgroundDef == null)
                Text(l10n.summaryNoBackgroundSelected)
              else ...[
                if (state.selectedBackgroundDef!.grantedSkills.isNotEmpty) ...[
                  Text(
                    l10n.summaryBackgroundSkillsTitle,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  ...state.selectedBackgroundDef!.grantedSkills.map(
                    (skillId) => Text('• ${_backgroundSkillLabel(l10n, skillId)}'),
                  ),
                  const SizedBox(height: 8),
                ],
                if (state.selectedBackgroundDef!.languagesPick > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      l10n.summaryBackgroundLanguagesPick(
                        state.selectedBackgroundDef!.languagesPick,
                      ),
                    ),
                  ),
                if (state.selectedBackgroundDef!.toolProficiencies.isNotEmpty)
                  ...[
                    Text(
                      l10n.summaryBackgroundToolsTitle,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    ...state.selectedBackgroundDef!.toolProficiencies.map(
                      (tool) =>
                          Text('• ${_backgroundEquipmentLabel(l10n, tool)}'),
                    ),
                    const SizedBox(height: 8),
                  ],
                if (state.selectedBackgroundDef!.feature != null) ...[
                  Text(
                    l10n.summaryBackgroundFeatureTitle,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _localized(l10n, state.selectedBackgroundDef!.feature!.name),
                    style: theme.textTheme.bodyMedium,
                  ),
                  ...state.selectedBackgroundDef!.feature!.effects.map((effect) {
                    final String text = _featureEffectText(l10n, effect);
                    if (text.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(text),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
                if (state.selectedBackgroundDef!.personality != null) ...[
                  ..._backgroundPersonalitySection(
                    theme,
                    l10n,
                    l10n.summaryBackgroundPersonalityTraits,
                    state.selectedBackgroundDef!.personality!.traits,
                  ),
                  ..._backgroundPersonalitySection(
                    theme,
                    l10n,
                    l10n.summaryBackgroundPersonalityIdeals,
                    state.selectedBackgroundDef!.personality!.ideals,
                  ),
                  ..._backgroundPersonalitySection(
                    theme,
                    l10n,
                    l10n.summaryBackgroundPersonalityBonds,
                    state.selectedBackgroundDef!.personality!.bonds,
                  ),
                  ..._backgroundPersonalitySection(
                    theme,
                    l10n,
                    l10n.summaryBackgroundPersonalityFlaws,
                    state.selectedBackgroundDef!.personality!.flaws,
                  ),
                ],
                if (state.selectedBackgroundDef!.equipment.isNotEmpty) ...[
                  Text(
                    l10n.summaryBackgroundEquipmentTitle,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  ...state.selectedBackgroundDef!.equipment.map((grant) {
                    final EquipmentDef? def =
                        state.backgroundEquipmentDefinitions[grant.itemId] ??
                            state.equipmentDefinitions[grant.itemId];
                    final String resolved = def != null
                        ? l10n.localizedCatalogLabel(def.name).trim()
                        : '';
                    final String label = resolved.isNotEmpty
                        ? resolved
                        : _backgroundEquipmentLabel(l10n, grant.itemId);
                    final List<String> metadata =
                        _equipmentMetadata(l10n, def);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _buildEquipmentLine(
                        theme,
                        '• $label ×${grant.quantity}',
                        metadata,
                      ),
                    );
                  }),
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
                if (state.selectedSpeciesTraits.isNotEmpty) ...[
                  SpeciesTraitDetailsList.fromDefinitions(
                    traits: state.selectedSpeciesTraits,
                  ),
                  if (state.selectedSpeciesEffects.isNotEmpty)
                    const SizedBox(height: 8),
                ],
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

  String _selectionLabel(
    AppLocalizations l10n,
    String id,
    LocalizedText? text,
  ) {
    if (text != null) {
      final String label = l10n.localizedCatalogLabel(text).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }

  bool _hasPowerInfo(ClassDef? def) {
    if (def == null) {
      return false;
    }
    if (def.powerSource != null && def.powerSource!.trim().isNotEmpty) {
      return true;
    }
    return def.powerList != null;
  }
}
