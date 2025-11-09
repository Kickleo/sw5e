import 'package:flutter/material.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

class CustomizationOptionDetailsList extends StatelessWidget {
  const CustomizationOptionDetailsList({
    super.key,
    required this.optionIds,
    required this.optionDefinitions,
  });

  final Iterable<String> optionIds;
  final Map<String, CustomizationOptionDef> optionDefinitions;

  static bool hasDisplayableContent(Iterable<String> optionIds) =>
      optionIds.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final List<Widget> children = <Widget>[];
    for (final String optionId in optionIds) {
      final CustomizationOptionDef? def = optionDefinitions[optionId];
      final String label;
      if (def != null) {
        final String localized = l10n.localizedCatalogLabel(def.name).trim();
        label = localized.isNotEmpty ? localized : _titleCase(optionId);
      } else {
        label = _titleCase(optionId);
      }
      if (label.isEmpty) {
        continue;
      }
      final List<String> effectLines = def?.effects
              .map(
                (CatalogFeatureEffect effect) => effect.text == null
                    ? ''
                    : l10n.localizedCatalogLabel(effect.text!).trim(),
              )
              .where((String value) => value.isNotEmpty)
              .toList() ??
          const <String>[];
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (effectLines.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: effectLines
                        .map(
                          (String line) => Text(
                            line,
                            style: theme.textTheme.bodySmall,
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class PowerDetailsList extends StatelessWidget {
  const PowerDetailsList({
    super.key,
    required this.powerIds,
    required this.powerDefinitions,
  });

  final Iterable<String> powerIds;
  final Map<String, PowerDef> powerDefinitions;

  static bool hasDisplayableContent(Iterable<String> powerIds) =>
      powerIds.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final List<Widget> children = <Widget>[];
    for (final String powerId in powerIds) {
      final PowerDef? def = powerDefinitions[powerId];
      final String label;
      if (def != null) {
        final String localized = l10n.localizedCatalogLabel(def.name).trim();
        label = localized.isNotEmpty ? localized : _titleCase(powerId);
      } else {
        label = _titleCase(powerId);
      }
      if (label.isEmpty) {
        continue;
      }
      final String description = def != null
          ? l10n.localizedCatalogLabel(def.description).trim()
          : '';
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    description,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

String _titleCase(String slug) {
  return slug
      .split(RegExp(r'[\-_.]'))
      .map((String part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
