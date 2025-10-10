<!--
Fichier : lib/ui/character_creation/README.md
Rôle : Documenter le sous-module UI dédié à la création de personnages.
Dépendances : S'appuie sur les ViewModels BLoC exposés dans `lib/presentation/character_creation`.
Exemple d'usage : Lire avant d'ajouter un nouvel écran du module de création.
-->

# UI · Character Creation

Ce sous-module regroupe les écrans Flutter du flux de création/gestion de personnages.

```
+-----------------------+
|   UI (character)      |
+-----------+-----------+
            |
+-----------v-----------+
| Presentation (BLoC)   |
+-----------------------+
```

## Structure actuelle
- `pages/` : écrans complets connectés aux blocs (`QuickCreatePage`, `SpeciesPickerPage`, etc.).
- `widgets/` : composants partagés (ex. séparateurs accessibles) utilisés par plusieurs pages.

## Règles
1. Les pages restent « dumb » : aucune logique métier, uniquement du rendu et du binding.
2. Toute nouvelle page doit documenter son usage, ses dépendances et fournir un exemple dans l'en-tête.
3. Couvrir les widgets critiques via des golden tests pour détecter toute régression de rendu.

