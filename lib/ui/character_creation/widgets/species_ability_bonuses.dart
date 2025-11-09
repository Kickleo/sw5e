import 'package:flutter/material.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/localization/species_effect_localization.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// Displays the localized ability score increases granted by a species.
class SpeciesAbilityBonusesCard extends StatelessWidget {
  const SpeciesAbilityBonusesCard({required this.bonuses, super.key});

  /// List of bonuses to render.
  final List<SpeciesAbilityBonus> bonuses;

  /// Returns true when there is at least one bonus worth displaying.
  static bool hasDisplayableContent(List<SpeciesAbilityBonus> bonuses) =>
      bonuses.any((SpeciesAbilityBonus bonus) => bonus.amount != 0);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final SpeciesAbilityBonusFormatter formatter = SpeciesAbilityBonusFormatter(
      SpeciesEffectLocalizationCatalog.forLanguage(l10n.languageCode),
    );

    final List<String> lines = bonuses
        .map(formatter.format)
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList(growable: false);

    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: ListTile(
        leading: const Icon(Icons.auto_awesome),
        title: Text(l10n.speciesAbilityBonusesTitle),
        subtitle: Text(lines.join('\n')),
      ),
    );
  }
}
