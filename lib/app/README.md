<!--
Fichier : lib/app/README.md
Rôle : Décrire le module application (shell + navigation) de la refonte MVVM.
Dépendances : S'appuie sur la couche UI et le service de navigation.
Exemple d'usage : Consulter ce fichier pour ajouter un nouvel onglet ou une navigation globale.
-->

# Module `lib/app`

```
+-------------------+
| Sw5eApp (shell)   |
|  - ProviderScope  |
|  - MaterialApp    |
+---------+---------+
          |
          v
+-------------------+
| HomeNav (tabs)    |
|  - QuickCreate UI |
|  - Summary UI     |
+---------+---------+
          |
          v
+-------------------------+
| GoRouter configuration  |
| (lib/app/router)        |
+-------------------------+
```

## Rôle
- `Sw5eApp` configure `MaterialApp.router` et branche le provider `appRouterProvider`.
- `HomeNav` gère la navigation par onglets entre l'assistant de création rapide et le résumé des personnages.
- Le sous-dossier `router/` expose la configuration GoRouter centralisée réutilisée par toute la couche UI.

## Points clés
- L'application initialise ses dépendances dans `main.dart` avant d'instancier `Sw5eApp` (voir `AppConfig` et `ServiceLocator`).
- Toute nouvelle vue globale (ex. écran de paramètres) doit être ajoutée aux onglets de `HomeNav` ou au routeur dans `router/app_router.dart`.
- Les blocs BLoC sont résolus dans les pages UI et **pas** dans ce module pour conserver la séparation MVVM.

## Tests et qualité
- Les comportements de navigation sont couverts indirectement par les tests des pages UI et par les golden tests.
- La CI exécute `flutter analyze` pour garantir que `Sw5eApp` et `HomeNav` respectent les contraintes d'import (pas de dépendances inverses).

## Liens
- [Couche UI](../ui/README.md)
- [Navigation GoRouter](router/README.md)
- [Code Map](../../docs/refactor/code_map.md)
