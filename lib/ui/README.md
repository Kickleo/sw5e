<!--
Fichier : lib/ui/README.md
Rôle : Documenter la couche UI (Widgets Flutter).
Dépendances : Flutter, packages UI.
Exemple d'usage : Lire avant de créer ou modifier un widget.
-->

# UI Layer

La couche **UI** regroupe les widgets Flutter « dumb » responsables du rendu et du binding aux ViewModels.

```
+-------------------+
|       UI          |
+---------+---------+
          |
+---------v---------+
|    Presentation   |
+-------------------+
```

## Contenu actuel
- `character_creation/pages/` : Écrans Flutter du module création de personnage (QuickCreate, SpeciesPicker, etc.).
- `navigation/` : Configuration GoRouter centralisée.

## Contenu prévu
- `widgets/` : Composants réutilisables.

## Bonnes pratiques
1. Pas de logique métier dans les widgets (seulement du binding).
2. Les widgets complexes doivent avoir des tests de rendu (golden tests).
3. Documenter chaque widget public et illustrer via snippets.

