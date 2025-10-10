<!--
Fichier : lib/ui/navigation/README.md
Rôle : Présenter la navigation GoRouter de la couche UI.
Dépendances : Flutter, GoRouter, widgets UI.
Exemple d'usage : Lire avant d'ajouter une route ou de modifier la navigation.
-->

# Navigation UI

Ce dossier centralise la configuration de **GoRouter** (GoRouter = gestionnaire de navigation déclaratif pour Flutter) côté UI afin que toutes les routes restent proches des vues qu'elles affichent.

```
+-------------------+
|  ui/navigation    |
+---------+---------+
          |
+---------v---------+
|    UI Pages       |
+-------------------+
```

## Contenu
- `app_router.dart` : constructeur du `GoRouter` principal avec routes imbriquées.

## Bonnes pratiques
1. Déclarer les routes ici uniquement, et référencer les `routeName` exposés par les pages pour éviter les chaînes magiques.
2. Documenter chaque nouvelle route dans la Code Map (`docs/refactor/code_map.md`).
3. Ajouter des tests de navigation (widget tests) pour les flux critiques.
