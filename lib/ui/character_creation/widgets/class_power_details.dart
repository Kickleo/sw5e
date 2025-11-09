import 'package:flutter/material.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

class ClassPowerDetails extends StatelessWidget {
  const ClassPowerDetails({super.key, required this.classDef});

  final ClassDef classDef;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<Widget> lines = <Widget>[];

    final String? powerSource = classDef.powerSource;
    if (powerSource != null && powerSource.trim().isNotEmpty) {
      lines.add(Text(l10n.classPowerSourceLine(powerSource)));
    }

    final ClassPowerList? powerList = classDef.powerList;
    if (powerList != null) {
      lines.add(Text(l10n.classPowerForceLine(powerList.forceAllowed)));
      lines.add(Text(l10n.classPowerTechLine(powerList.techAllowed)));
      final String progression =
          l10n.classPowerProgressionLine(powerList.spellcastingProgression);
      if (progression.isNotEmpty) {
        lines.add(Text(progression));
      }
    }

    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.classPowerSectionTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        ...lines,
      ],
    );
  }
}
