<!--
Fichier : docs/adr/003-error-handling-app-failure.md
Rôle : Expliquer l'adoption d'AppFailure comme contrat d'erreur transverse.
Dépendances : lib/common/errors/app_failure.dart, docs/refactor/error_policy.md.
Exemple d'usage : Justifier l'ajout d'une nouvelle catégorie d'erreur ou le mapping vers l'UI.
-->

# ADR 003 – Politique d'erreurs avec AppFailure

## Contexte
Les erreurs étaient gérées de manière incohérente (exceptions, chaînes brutes). La refonte impose une politique centralisée et documentée pour éviter la duplication et sécuriser les messages UI.

## Décision
Nous introduisons `AppFailure` comme enveloppe typée et immuable pour toute erreur propagée au-dessus du domaine. Les use cases retournent `AppResult` (`Result` typé succès/erreur) et les BLoCs transforment les erreurs en `AppFailure` avant de les exposer à l'UI.

## Conséquences
- **Positives** : cohérence des messages, journalisation enrichie, tests simplifiés grâce aux catégories/codes.
- **Négatives** : nécessité de mapper systématiquement les erreurs domaine → AppFailure.
- **Actions** : tenir `docs/refactor/error_policy.md` à jour, ajouter un test à chaque fois qu'une nouvelle catégorie/codification est introduite.
