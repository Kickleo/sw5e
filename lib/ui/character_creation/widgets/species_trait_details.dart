import 'package:flutter/material.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// Displays localized species trait details using catalog v2 definitions.
class SpeciesTraitDetailsList extends StatelessWidget {
  SpeciesTraitDetailsList({
    super.key,
    required Iterable<String> traitIds,
    required Map<String, TraitDef> traitDefinitions,
    this.leadingIcon = Icons.auto_fix_high,
  }) : traits = _resolveTraitIds(traitIds, traitDefinitions);

  const SpeciesTraitDetailsList.fromDefinitions({
    super.key,
    required this.traits,
    this.leadingIcon = Icons.auto_fix_high,
  });

  /// Localized trait definitions to display.
  final List<TraitDef> traits;

  /// Optional icon rendered next to each trait.
  final IconData? leadingIcon;

  /// Returns `true` when there is at least one trait to render.
  static bool hasDisplayableContent(List<TraitDef> traits) =>
      traits.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (traits.isEmpty) {
      return const SizedBox.shrink();
    }

    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final List<Widget> cards = <Widget>[];

    for (int index = 0; index < traits.length; index += 1) {
      final TraitDef trait = traits[index];
      final String name = _resolveLabel(l10n, trait);
      final String? description = _resolveDescription(l10n, trait);

      cards.add(
        Card(
          margin: EdgeInsets.only(bottom: index == traits.length - 1 ? 0 : 8),
          child: ListTile(
            leading: leadingIcon != null ? Icon(leadingIcon) : null,
            title: Text(
              name,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: description == null ? null : Text(description),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: cards,
    );
  }

  static List<TraitDef> _resolveTraitIds(
    Iterable<String> traitIds,
    Map<String, TraitDef> traitDefinitions,
  ) {
    final Set<String> seen = <String>{};
    final List<TraitDef> resolved = <TraitDef>[];
    for (final String id in traitIds) {
      if (!seen.add(id)) {
        continue;
      }
      final TraitDef? def = traitDefinitions[id];
      if (def != null) {
        resolved.add(def);
      } else {
        final String label = _titleCase(id);
        resolved.add(
          TraitDef(
            id: id,
            name: LocalizedText(en: label, fr: label),
            description: const LocalizedText(),
          ),
        );
      }
    }
    return resolved;
  }

  static String _resolveLabel(AppLocalizations l10n, TraitDef trait) {
    final String label = l10n.localizedCatalogLabel(trait.name).trim();
    if (label.isNotEmpty) {
      return label;
    }
    return _titleCase(trait.id);
  }

  static String? _resolveDescription(AppLocalizations l10n, TraitDef trait) {
    final String description =
        l10n.localizedCatalogLabel(trait.description).trim();
    return description.isEmpty ? null : description;
  }

  static String _titleCase(String slug) {
    return slug
        .split(RegExp(r'[\-_.]'))
        .map(
          (String part) =>
              part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}
