import 'package:flutter/material.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// Displays multi-class requirements for a class using localized ability names.
class ClassMulticlassingDetails extends StatelessWidget {
  const ClassMulticlassingDetails({
    super.key,
    required this.classDef,
    required this.abilityDefinitions,
    this.headingStyle,
  });

  /// Class definition providing the multi-classing metadata.
  final ClassDef classDef;

  /// Cached ability definitions used to resolve localized labels.
  final Map<String, AbilityDef> abilityDefinitions;

  /// Optional style override for the heading text.
  final TextStyle? headingStyle;

  bool get _hasRequirements =>
      classDef.multiclassing?.hasAbilityRequirements ?? false;

  @override
  Widget build(BuildContext context) {
    if (!_hasRequirements) {
      return const SizedBox.shrink();
    }

    final AppLocalizations l10n = context.l10n;
    final List<_RequirementEntry> entries = _buildRequirementEntries(l10n);
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final TextStyle? titleStyle =
        headingStyle ?? Theme.of(context).textTheme.titleMedium;
    final String joined = entries
        .map((entry) =>
            l10n.classMulticlassRequirementValue(entry.label, entry.score))
        .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.classMulticlassRequirementsTitle, style: titleStyle),
        const SizedBox(height: 4),
        Text(joined),
      ],
    );
  }

  List<_RequirementEntry> _buildRequirementEntries(AppLocalizations l10n) {
    final ClassMulticlassing? multiclassing = classDef.multiclassing;
    if (multiclassing == null || !multiclassing.hasAbilityRequirements) {
      return const <_RequirementEntry>[];
    }
    final List<MapEntry<String, int>> rawEntries =
        multiclassing.abilityRequirements.entries.toList()
          ..sort((MapEntry<String, int> a, MapEntry<String, int> b) =>
              a.key.compareTo(b.key));
    final List<_RequirementEntry> normalized = <_RequirementEntry>[];
    for (final MapEntry<String, int> entry in rawEntries) {
      final AbilityDef? ability = abilityDefinitions[entry.key];
      String label;
      if (ability != null) {
        final String localized = l10n.localizedCatalogLabel(ability.name).trim();
        if (localized.isNotEmpty) {
          label = localized;
        } else if (ability.abbreviation.trim().isNotEmpty) {
          label = ability.abbreviation.trim();
        } else {
          label = entry.key.toUpperCase();
        }
      } else {
        label = entry.key.toUpperCase();
      }
      if (label.isEmpty) {
        continue;
      }
      normalized.add(_RequirementEntry(label: label, score: entry.value));
    }
    return normalized;
  }
}

class _RequirementEntry {
  const _RequirementEntry({required this.label, required this.score});

  final String label;
  final int score;
}
