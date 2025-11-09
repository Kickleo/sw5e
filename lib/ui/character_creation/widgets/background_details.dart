import 'package:flutter/material.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

List<Widget> buildBackgroundDetails({
  required AppLocalizations l10n,
  required ThemeData theme,
  required BackgroundDef background,
  required Map<String, SkillDef> skillDefinitions,
  required Map<String, EquipmentDef> equipmentDefinitions,
}) {
  final List<Widget> children = <Widget>[];

  if (background.grantedSkills.isNotEmpty) {
    children
      ..add(
        Text(
          l10n.summaryBackgroundSkillsTitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      )
      ..add(const SizedBox(height: 4))
      ..addAll(
        background.grantedSkills.map(
          (String skill) => Text('• ${_skillLabel(l10n, skillDefinitions, skill)}'),
        ),
      )
      ..add(const SizedBox(height: 8));
  }

  if (background.languagesPick > 0) {
    children
      ..add(
        Text(
          l10n.summaryBackgroundLanguagesPick(background.languagesPick),
        ),
      )
      ..add(const SizedBox(height: 8));
  }

  if (background.toolProficiencies.isNotEmpty) {
    children
      ..add(
        Text(
          l10n.summaryBackgroundToolsTitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      )
      ..add(const SizedBox(height: 4))
      ..addAll(
        background.toolProficiencies.map(
          (String tool) =>
              Text('• ${_equipmentLabel(l10n, equipmentDefinitions, tool)}'),
        ),
      )
      ..add(const SizedBox(height: 8));
  }

  if (background.feature != null) {
    children
      ..add(
        Text(
          l10n.summaryBackgroundFeatureTitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      )
      ..add(const SizedBox(height: 4))
      ..add(
        Text(
          l10n.localizedCatalogLabel(background.feature!.name),
          style: theme.textTheme.bodyMedium,
        ),
      );

    for (final CatalogFeatureEffect effect in background.feature!.effects) {
      final String text = _effectText(l10n, effect);
      if (text.isEmpty) {
        continue;
      }
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(text),
        ),
      );
    }
    children.add(const SizedBox(height: 8));
  }

  if (background.personality != null) {
    children
      ..addAll(
        _personalitySection(
          l10n,
          theme,
          l10n.summaryBackgroundPersonalityTraits,
          background.personality!.traits,
        ),
      )
      ..addAll(
        _personalitySection(
          l10n,
          theme,
          l10n.summaryBackgroundPersonalityIdeals,
          background.personality!.ideals,
        ),
      )
      ..addAll(
        _personalitySection(
          l10n,
          theme,
          l10n.summaryBackgroundPersonalityBonds,
          background.personality!.bonds,
        ),
      )
      ..addAll(
        _personalitySection(
          l10n,
          theme,
          l10n.summaryBackgroundPersonalityFlaws,
          background.personality!.flaws,
        ),
      );
  }

  if (background.equipment.isNotEmpty) {
    children
      ..add(
        Text(
          l10n.summaryBackgroundEquipmentTitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      )
      ..add(const SizedBox(height: 4))
      ..addAll(
        background.equipment.map(
          (BackgroundEquipmentGrant grant) => Text(
            '• ${_equipmentLabel(l10n, equipmentDefinitions, grant.itemId)} ×${grant.quantity}',
          ),
        ),
      );
  }

  return children;
}

String _titleCase(String slug) {
  return slug
      .split(RegExp(r'[\-_.]'))
      .map(
        (String part) =>
            part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

String _skillLabel(
  AppLocalizations l10n,
  Map<String, SkillDef> skillDefinitions,
  String id,
) {
  final SkillDef? def = skillDefinitions[id];
  if (def != null) {
    final String value = l10n.localizedCatalogLabel(def.name).trim();
    if (value.isNotEmpty) {
      return value;
    }
  }
  return _titleCase(id);
}

String _equipmentLabel(
  AppLocalizations l10n,
  Map<String, EquipmentDef> equipmentDefinitions,
  String id,
) {
  final EquipmentDef? def = equipmentDefinitions[id];
  if (def != null) {
    final String value = l10n.localizedCatalogLabel(def.name).trim();
    if (value.isNotEmpty) {
      return value;
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

List<Widget> _personalitySection(
  AppLocalizations l10n,
  ThemeData theme,
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
    ...values.map(
      (LocalizedText text) => Text('• ${l10n.localizedCatalogLabel(text)}'),
    ),
    const SizedBox(height: 8),
  ];
}
