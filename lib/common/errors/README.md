<!--
Fichier : lib/common/errors/README.md
Rôle : Documenter la politique d'erreurs et la structure AppFailure.
Dépendances : AppFailure, DomainError.
Exemple d'usage : Lire avant d'ajouter une nouvelle catégorie d'erreur.
-->

# Errors

Ce module expose l'unification **AppFailure** (AppFailure = structure qui
regroupe code, catégorie et message pour une erreur) utilisée par les BLoC et
les vues.

## Vue d'ensemble

```
+-------------+        +--------------------+
| DomainError | -----> | AppFailure.from... |
+-------------+        +--------------------+
        |                        |
        v                        v
  Use cases             Presentation / UI
```

## Règles
1. Toujours créer les erreurs via `AppFailure.validation/notFound/...` pour
   expliciter la catégorie.
2. `AppFailure.fromDomain` doit connaître toutes les erreurs `DomainError`
   existantes : ajouter un `case` lors de l'introduction d'un nouveau code.
3. Les vues consomment `toDisplayMessage()` (message user-friendly) tandis que
   les logs utilisent `toLogMessage()`.

## Messages par défaut
- Validation : « Entrée invalide. »
- Not Found : « Ressource introuvable. »
- Storage : « Erreur de stockage. »
- Unexpected : « Erreur inattendue. »

Chaque code documenté ajoute un message plus précis dans
`AppFailure._defaultMessages`.
