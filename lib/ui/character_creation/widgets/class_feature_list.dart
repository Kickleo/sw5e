import 'package:flutter/material.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// Displays a list of class features with localized names, descriptions,
/// and effect texts sourced from catalog v2.
class ClassFeatureList extends StatelessWidget {
  const ClassFeatureList({
    super.key,
    required this.heading,
    required this.features,
    this.headingStyle,
  });

  /// Section heading displayed above the features.
  final String heading;

  /// Level one class features fetched from the catalog.
  final List<ClassFeature> features;

  /// Optional override for the heading style.
  final TextStyle? headingStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Widget> featureWidgets = _buildFeatureWidgets(context);
    if (featureWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          heading,
          style: headingStyle ?? theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        ...featureWidgets,
      ],
    );
  }

  List<Widget> _buildFeatureWidgets(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final List<Widget> widgets = <Widget>[];

    for (final ClassFeature feature in features) {
      final List<Widget> contents = <Widget>[];
      final String name = l10n.localizedCatalogLabel(feature.name).trim();
      if (name.isNotEmpty) {
        contents.add(
          Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      if (feature.description != null) {
        final String description =
            l10n.localizedCatalogLabel(feature.description!).trim();
        if (description.isNotEmpty) {
          contents.add(Text(description));
        }
      }

      final Iterable<String> effectTexts = feature.effects
          .map((CatalogFeatureEffect effect) => effect.text)
          .whereType<LocalizedText>()
          .map((LocalizedText text) => l10n.localizedCatalogLabel(text).trim())
          .where((String value) => value.isNotEmpty);

      for (final String text in effectTexts) {
        contents.add(Text(text));
      }

      if (contents.isEmpty) {
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _withVerticalSpacing(contents),
          ),
        ),
      );
    }

    return widgets;
  }

  List<Widget> _withVerticalSpacing(List<Widget> widgets) {
    if (widgets.length <= 1) {
      return widgets;
    }

    final List<Widget> spaced = <Widget>[];
    for (int index = 0; index < widgets.length; index++) {
      if (index > 0) {
        spaced.add(const SizedBox(height: 4));
      }
      spaced.add(widgets[index]);
    }
    return spaced;
  }
}
