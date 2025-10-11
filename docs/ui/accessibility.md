<!--
Fichier : docs/ui/accessibility.md
Rôle : Décrire les règles d'accessibilité UI retenues pendant la refonte.
Dépendances : Flutter Material, recommandations WCAG.
Exemple d'usage : Consulter avant de modifier la structure des écrans.
-->

# Accessibilité UI

Cette note synthétise les règles à appliquer pour garantir une expérience accessible dans l'application.

## Lignes directrices
1. **Focus visibles** : tout élément interactif doit avoir un indicateur visuel de focus clavier ou lecteur d'écran.
2. **Contrastes** : utiliser des couleurs ≥ 4.5:1 pour le texte et ≥ 3:1 pour les éléments non textuels.
3. **Semantics** : baliser les zones critiques (`Semantics`, `Tooltip`) afin que les lecteurs d'écran annoncent un contexte clair.
4. **Navigation** : maintenir un ordre logique dans la hiérarchie des widgets ; éviter les `Stack` sans étiquettes.

## Composants dédiés
- `CharacterSectionDivider` : séparateur à haut contraste (0xFF202124 sur fond clair) utilisé dans les listes pour délimiter les sections et offrir un repère visuel aux utilisateurs à basse vision.

## Tests recommandés
- `flutter test` avec `SemanticsTester` pour vérifier les libellés.
- Golden tests pour éviter les régressions de contraste ou d'espacement.

## À venir
- Cartographier les raccourcis clavier une fois la navigation entièrement stabilisée.
