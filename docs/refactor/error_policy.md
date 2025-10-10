<!--
Fichier : docs/refactor/error_policy.md
Rôle : Documenter la politique d'erreurs MVVM (DomainError -> AppFailure -> UI).
Dépendances : AppFailure, DomainError, BLoC de présentation.
Exemple d'usage : Référencer ce document avant d'ajouter une nouvelle erreur.
-->

# Politique d'erreurs

```
DomainError / Exception
        |
        v
 AppFailure (category, code, message)
        |
        v
 BLoC -> UI (toDisplayMessage)
```

## Objectifs
- Rendre les erreurs **typées** pour les tests et la documentation.
- Dissocier le vocabulaire métier (`DomainError`) de la présentation (`AppFailure`).
- Fournir des messages utilisateur cohérents (`toDisplayMessage`) et des logs normalisés (`toLogMessage`).

## Pipeline
1. Les **use cases** renvoient `DomainError` via `AppResult`.
2. Les **BLoC** transforment systématiquement l'erreur en `AppFailure.fromDomain` (ou `AppFailure.fromException`).
3. Les **states** exposent `failure` + un getter `errorMessage` pour les vues.
4. Les **vues** affichent `failure.toDisplayMessage(includeCode: true)` et les tests vérifient `failure.code`.

## Catégories disponibles
- `validation` : entrées invalides / prérequis violés.
- `notFound` : ressource absente (`UnknownClass`, `UnknownSpecies`, ...).
- `storage` : chargements/déchargements d'assets ou de stockage.
- `unexpected` : défauts inattendus non catégorisés.

Chaque nouvelle erreur doit :
1. Définir un code unique (PascalCase) dans le use case ou l'adapter.
2. Ajouter le mapping adéquat dans `AppFailure.fromDomain`.
3. Documenter le message par défaut dans `AppFailure._defaultMessages` si nécessaire.

## Tests
- Vérifier `state.failure?.code` dans les tests de BLoC pour garantir la typologie.
- Continuer à valider le message utilisateur via `state.errorMessage` si pertinent.
