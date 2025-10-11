/// ---------------------------------------------------------------------------
/// Fichier : lib/ui/character_creation/widgets/character_section_divider.dart
/// Rôle : Widget utilitaire affichant une ligne de séparation cohérente pour
///        les sections de la création de personnages.
/// Dépendances : Flutter Material.
/// Exemple d'usage : `CharacterSectionDivider()` dans un `ListView.separated`.
/// ---------------------------------------------------------------------------
library;
import 'package:flutter/material.dart';

/// Séparateur horizontal standardisé pour les sections du module création.
class CharacterSectionDivider extends StatelessWidget {
  /// Crée un séparateur avec un espacement [spacing], une [thickness] et une
  /// [color] personnalisables.
  const CharacterSectionDivider({
    super.key,
    this.spacing = 12,
    this.thickness = 2,
    this.color = const Color(0xFF202124),
  });

  /// Espace vertical total occupé par le séparateur.
  final double spacing;

  /// Épaisseur réelle de la ligne tracée.
  final double thickness;

  /// Couleur de la ligne.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: spacing,
      child: Center(
        child: SizedBox(
          height: thickness,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(thickness / 2),
            ),
          ),
        ),
      ),
    );
  }
}
