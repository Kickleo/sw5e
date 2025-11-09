part of '../quick_create_page.dart';

class _BackgroundStep extends StatelessWidget {
  const _BackgroundStep({
    required this.backgrounds,
    required this.backgroundLabels,
    required this.selectedBackground,
    required this.backgroundDef,
    required this.backgroundSkillDefinitions,
    required this.backgroundEquipmentDefinitions,
    required this.equipmentDefinitions,
    required this.nameController,
    required this.onBackgroundChanged,
  });

  final List<String> backgrounds;
  final Map<String, LocalizedText> backgroundLabels;
  final String? selectedBackground;
  final BackgroundDef? backgroundDef;
  final Map<String, SkillDef> backgroundSkillDefinitions;
  final Map<String, EquipmentDef> backgroundEquipmentDefinitions;
  final Map<String, EquipmentDef> equipmentDefinitions;
  final TextEditingController nameController;
  final ValueChanged<String?> onBackgroundChanged;

  String _titleCase(String slug) => slug
      .split(RegExp(r'[\-_.]'))
      .map(
        (part) =>
            part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
      )
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.quickCreateNameLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedBackground,
          decoration: InputDecoration(
            labelText: l10n.quickCreateBackgroundLabel,
            border: const OutlineInputBorder(),
          ),
          items: backgrounds
              .map(
                (id) => DropdownMenuItem(
                  value: id,
                  child: Text(_labelFor(l10n, id)),
                ),
              )
              .toList(),
          onChanged: onBackgroundChanged,
        ),
        ..._buildDetails(theme, l10n),
        const SizedBox(height: 24),
        Text(l10n.quickCreateEquipmentReminder),
      ],
    );
  }

  List<Widget> _buildDetails(ThemeData theme, AppLocalizations l10n) {
    final BackgroundDef? def = backgroundDef;
    if (def == null) {
      return <Widget>[const SizedBox(height: 16)];
    }

    final List<Widget> children = <Widget>[const SizedBox(height: 24)];

    final List<String> skillLabels = def.grantedSkills
        .map((String id) => _skillLabel(l10n, id))
        .where((String label) => label.isNotEmpty)
        .toList();
    if (skillLabels.isNotEmpty) {
      children
        ..add(Text(
          l10n.quickCreateBackgroundSkillsTitle,
          style: theme.textTheme.titleMedium,
        ))
        ..add(const SizedBox(height: 8))
        ..addAll(skillLabels.map((String label) => Text('• $label')))
        ..add(const SizedBox(height: 16));
    }

    if (def.languagesPick > 0) {
      children
        ..add(Text(
          l10n.quickCreateBackgroundLanguagesPick(def.languagesPick),
          style: theme.textTheme.bodyMedium,
        ))
        ..add(const SizedBox(height: 16));
    }

    if (def.toolProficiencies.isNotEmpty) {
      children
        ..add(Text(
          l10n.quickCreateBackgroundToolsTitle,
          style: theme.textTheme.titleMedium,
        ))
        ..add(const SizedBox(height: 8))
        ..addAll(
          def.toolProficiencies
              .map((String tool) => Text('• ${_equipmentLabel(l10n, tool)}')),
        )
        ..add(const SizedBox(height: 16));
    }

    if (def.feature != null) {
      final BackgroundFeature feature = def.feature!;
      children
        ..add(Text(
          l10n.quickCreateBackgroundFeatureTitle,
          style: theme.textTheme.titleMedium,
        ))
        ..add(const SizedBox(height: 8))
        ..add(Text(
          l10n.localizedCatalogLabel(feature.name),
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ));
      for (final CatalogFeatureEffect effect in feature.effects) {
        final String description = _effectText(l10n, effect);
        if (description.isEmpty) {
          continue;
        }
        children.add(Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description),
        ));
      }
      children.add(const SizedBox(height: 16));
    }

    if (def.personality != null) {
      final BackgroundPersonality personality = def.personality!;
      children.addAll(
        _buildPersonalitySection(
          theme,
          l10n.quickCreateBackgroundPersonalityTraitsTitle,
          personality.traits,
          l10n,
        ),
      );
      children.addAll(
        _buildPersonalitySection(
          theme,
          l10n.quickCreateBackgroundPersonalityIdealsTitle,
          personality.ideals,
          l10n,
        ),
      );
      children.addAll(
        _buildPersonalitySection(
          theme,
          l10n.quickCreateBackgroundPersonalityBondsTitle,
          personality.bonds,
          l10n,
        ),
      );
      children.addAll(
        _buildPersonalitySection(
          theme,
          l10n.quickCreateBackgroundPersonalityFlawsTitle,
          personality.flaws,
          l10n,
        ),
      );
    }

    if (def.equipment.isNotEmpty) {
      children
        ..add(const SizedBox(height: 16))
        ..add(Text(
          l10n.quickCreateBackgroundEquipmentTitle,
          style: theme.textTheme.titleMedium,
        ))
        ..add(const SizedBox(height: 8));
      for (final BackgroundEquipmentGrant grant in def.equipment) {
        final String label = _equipmentLabel(l10n, grant.itemId);
        children.add(Text('• $label ×${grant.quantity}'));
      }
    }

    return children;
  }

  Iterable<Widget> _buildPersonalitySection(
    ThemeData theme,
    String title,
    List<LocalizedText> values,
    AppLocalizations l10n,
  ) {
    if (values.isEmpty) {
      return const <Widget>[];
    }
    final List<Widget> widgets = <Widget>[
      const SizedBox(height: 16),
      Text(
        title,
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
    ];
    widgets.addAll(
      values.map(
        (LocalizedText value) => Text('• ${l10n.localizedCatalogLabel(value)}'),
      ),
    );
    return widgets;
  }

  String _labelFor(AppLocalizations l10n, String id) {
    final LocalizedText? text = backgroundLabels[id];
    if (text != null) {
      final String label = l10n.localizedCatalogLabel(text).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }

  String _skillLabel(AppLocalizations l10n, String id) {
    final SkillDef? def = backgroundSkillDefinitions[id];
    if (def != null) {
      final String label = l10n.localizedCatalogLabel(def.name).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }

  String _equipmentLabel(AppLocalizations l10n, String id) {
    final EquipmentDef? def =
        backgroundEquipmentDefinitions[id] ?? equipmentDefinitions[id];
    if (def != null) {
      final String label = l10n.localizedCatalogLabel(def.name).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }

String _effectText(AppLocalizations l10n, CatalogFeatureEffect effect) {
  if (effect.text == null) {
    return '';
  }
  return l10n.localizedCatalogLabel(effect.text!).trim();
}
}
