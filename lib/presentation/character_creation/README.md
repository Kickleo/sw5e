<!--
Fichier : lib/presentation/character_creation/README.md
Rôle : Documenter le sous-module de présentation dédié à la création/gestion de personnages.
Dépendances : BLoC (`flutter_bloc`), `equatable`, `AppFailure`, service locator.
Exemple d'usage : Lire avant d'ajouter un nouveau bloc ou un état de présentation dans ce sous-module.
-->

# Presentation · Character Creation

Ce dossier regroupe les ViewModels MVVM (pattern BLoC) et les états immuables liés au flux de création et de gestion de personnages.

```
+--------------------------+
|     UI (pages Flutter)   |
+-------------+------------+
              |
+-------------v------------+
| Presentation · Character |
| Creation (BLoC/States)   |
+-------------+------------+
              |
+-------------v------------+
|      Domain · Characters |
+--------------------------+
```

## Structure
- `blocs/` : BLoC/Events/States orchestrant chaque écran (création rapide, sélecteurs, résumé, etc.).
- `states/` : Objets d'état partagés entre blocs (ex. `QuickCreateState`).

## Règles de contribution
1. Toute classe publique doit exposer une docstring explicitant invariants et erreurs.
2. Les blocs doivent mapper les erreurs domaine → `AppFailure` avant d'émettre un état.
3. Ajouter des tests `bloc_test` dans `test/presentation/character_creation` pour chaque scénario significatif.

