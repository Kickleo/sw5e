/// ---------------------------------------------------------------------------
/// Fichier : lib/ui/character_creation/pages/quick_create/steps/class_step.dart
/// Rôle : Widget affichant l'étape de sélection de classe dans l'assistant
///        de création rapide. Expose un sélecteur, un bouton d'accès aux
///        détails complets et un aperçu des informations de niveau 1.
/// Dépendances : Flutter Material, entité [ClassDef].
/// Exemple d'usage : voir QuickCreatePage.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// Widget réutilisable pour l'étape de sélection de classe.
class QuickCreateClassStep extends StatelessWidget {
  const QuickCreateClassStep({
    super.key,
    required this.classes,
    required this.selectedClass,
    required this.classDef,
    required this.isLoadingDetails,
    required this.onSelect,
    required this.onOpenPicker,
  });

  /// Liste des identifiants de classes disponibles.
  final List<String> classes;

  /// Identifiant actuellement sélectionné.
  final String? selectedClass;

  /// Définition détaillée de la classe sélectionnée (si chargée).
  final ClassDef? classDef;

  /// Indique si les détails sont en cours de chargement.
  final bool isLoadingDetails;

  /// Callback déclenché lorsqu'une classe est sélectionnée.
  final ValueChanged<String?> onSelect;

  /// Callback ouvrant la page de sélection avancée.
  final VoidCallback onOpenPicker;

  @override
  Widget build(BuildContext context) {
    final ClassDef? classDefinition = classDef;
    final ThemeData theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Classe',
                  border: OutlineInputBorder(),
                ),
                items: classes
                    .map(
                      (id) => DropdownMenuItem<String>(
                        value: id,
                        child: Text(_slugToTitleCase(id)),
                      ),
                    )
                    .toList(),
                onChanged: onSelect,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onOpenPicker,
              icon: const Icon(Icons.search),
              label: const Text('Détails'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoadingDetails)
          const Center(child: CircularProgressIndicator())
        else if (classDefinition == null)
          const Text('Aucune classe sélectionnée.')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _localizedClassName(classDefinition),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('Dé de vie : d${classDefinition.hitDie}'),
              const SizedBox(height: 12),
              Text(
                'Compétences : choisir '
                '${classDefinition.level1.proficiencies.skillsChoose} (étape suivante)',
              ),
              const SizedBox(height: 12),
              Text(
                'Équipement de départ :\n${_formatStartingEquipment(classDefinition)}',
              ),
            ],
          ),
      ],
    );
  }
}

String _localizedClassName(ClassDef classDef) {
  final String french = classDef.name.fr;
  if (french.isNotEmpty) {
    return french;
  }
  return classDef.name.en;
}

String _formatStartingEquipment(ClassDef classDef) {
  return classDef.level1.startingEquipment
      .map((line) => '• ${line.id} ×${line.qty}')
      .join('\n');
}

String _slugToTitleCase(String slug) {
  return slug
      .split(RegExp(r'[-_]'))
      .map(
        (part) =>
            part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
      )
      .join(' ');
}
