<!--
Fichier : lib/app/router/README.md
Rôle : Documenter la configuration GoRouter et son intégration avec Sw5eApp.
Dépendances : GoRouter, Riverpod, vues UI.
Exemple d'usage : Lire avant d'ajouter une nouvelle route ou de modifier la navigation globale.
-->

# `lib/app/router`

```
+--------------------+
| appRouterProvider  |<---------------------+
+---------+----------+                      |
          |                                 |
          v                                 |
   GoRouter builder ------------------------+
          |
          v
  +----------------------------+
  | Routes déclarées           |
  | - '/' -> HomePage          |
  | - '/create' -> HomeNav     |
  |   - species-picker         |
  |   - class-picker           |
  | - '/saved-characters'      |
  +----------------------------+
```

## Principes
- Le provider `appRouterProvider` construit un `GoRouter` **sans état global** ; la navigation dépend des pages instanciées dans la couche UI.
- Les routes enfants de `/` pointent vers les pages UI qui résolvent leurs BLoC via `ServiceLocator`, ce qui évite de mélanger navigation et logique de présentation.
- Toute route nécessitant des paramètres utilise `state.extra` avec des DTO simples (ex. identifiants String) afin de garder l'API stable.

## Extension
1. Ajouter un `GoRoute` dans `_buildAppRouter()` en respectant les conventions (chemin kebab-case, `routeName` statique sur la page).
2. Si la route a besoin de dépendances additionnelles, les instancier dans la page UI concernée, pas ici.
3. Mettre à jour la [Code Map](../../../docs/refactor/code_map.md) et la documentation UI si la navigation change.

## Tests
- Couvert indirectement par les tests des pages et par les golden tests (la CI échoue si des routes pointent vers des widgets invalides).
- En cas d'ajout de logique conditionnelle complexe, prévoir des tests de navigation via `go_router` et `flutter_test`.

## Références
- [Documentation GoRouter](https://pub.dev/packages/go_router)
- [Sw5eApp](../app.dart)
- [HomeNav](../home_nav.dart)
