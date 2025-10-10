<!--
Fichier : README.md
Rôle : Documentation racine présentant l'architecture, la configuration et les commandes.
Dépendances : docs/refactor/*, Makefile, .pre-commit-config.yaml.
Exemple d'usage : point d'entrée pour tout nouveau contributeur.
-->

# SW5E Manager

> Gestionnaire de personnages Star Wars 5e refactoré en MVVM (Model-View-ViewModel = séparation Vue/Modèle avec un ViewModel qui porte l’état & la logique UI) au-dessus d’une architecture en couches.

## Sommaire
1. [Vue d’ensemble](#vue-densemble)
2. [Architecture](#architecture)
3. [Prérequis & configuration](#prérequis--configuration)
4. [Commandes développeur](#commandes-développeur)
5. [Qualité & tests](#qualité--tests)
6. [Sécurité & secrets](#sécurité--secrets)
7. [Roadmap & suivi](#roadmap--suivi)

## Vue d’ensemble
- **But** : créer et gérer des personnages hors-ligne pour Star Wars 5e avec une UI Flutter mobile/web.
- **Objectif du refactor** : clarifier la structure (Domain/Data/Presentation/UI/Common), adopter BLoC (Business Logic Component = composant qui transforme des événements en états) et documenter chaque brique pour faciliter la maintenance.
- **Points clés** :
  - États immuables côté ViewModel, vues « dumb » qui ne font que du rendu.
  - Ports/adapters pour isoler la persistence hors-ligne actuelle et préparer une API future.
  - Politique d’erreurs partagée via `AppFailure` (AppFailure = encapsulation standardisée d'une erreur propagée à l'UI).

## Architecture
```
                          +--------------------+
                          |        UI          |
                          | (Widgets Flutter)  |
                          +---------+----------+
                                    |
                                    v
                          +--------------------+
                          |   Presentation     |
                          | (BLoC ViewModels)  |
                          +---------+----------+
                                    |
                                    v
                        +-----------+-----------+
                        |        Domain        |
                        | (Use cases, Entities)|
                        +-----------+-----------+
                                    |
                                    v
                        +-----------+-----------+
                        |          Data         |
                        | (DTO, Sources, Repo) |
                        +-----------+-----------+
                                    |
                                    v
                          +--------------------+
                          |       Common       |
                          | (Config, Logger,   |
                          |  Result, Errors)   |
                          +--------------------+
```
- **Domain** : expose les règles métier pures (entités, value objects, use cases) testées sans Flutter.
- **Data** : traduit le monde extérieur (AssetBundle, mémoire) en modèles métiers via des DTOs commentés.
- **Presentation** : ViewModels BLoC orchestrant les use cases, convertissant `AppResult` en états UI.
- **UI** : widgets Flutter responsables uniquement du rendu, branchés aux BLoCs via `BlocProvider` (voir `lib/ui/navigation` et `docs/ui/accessibility.md`).
- **Common** : utilitaires transverses (`AppConfig`, `ServiceLocator`, `AppLogger`, `AppFailure`).

Consultez `docs/refactor/code_map.md` pour la carte détaillée des fichiers et `docs/adr/` pour les décisions architecturales.

## Prérequis & configuration
1. **Flutter** ≥ 3.22 (canal stable recommandé).
2. **Dépendances CLI** : `melos` (facultatif), `pre-commit` (pour les hooks).
3. **Secrets/config** :
   - Copiez `.env.example` vers `.env` et adaptez les valeurs (aucun secret critique pour l’instant).
   - Chargement via `AppConfig` (AppConfig = wrapper qui charge `.env`) exécuté dans `main` avant l’injection des dépendances.
4. **Service Locator** : `lib/common/di/service_locator.dart` enregistre les singletons via `get_it`.

## Commandes développeur
Toutes les commandes sont encapsulées dans le `Makefile` (Makefile = script de commandes `make`).

| Commande | Rôle |
| --- | --- |
| `make format` | Formater `lib/` et `test/` avec `flutter format`.
| `make lint` | `flutter analyze` avec les règles `analysis_options.yaml`.
| `make test` | `flutter test --coverage` + vérification du seuil via `tool/check_coverage.dart`.
| `make build` | `flutter build apk --debug` pour vérifier l’assemblage Android.
| `make ci` | Chaîne format → lint → tests (utilisée en CI).

## Qualité & tests
- **Couverture** : cible ≥ 70 % (voir `coverage/lcov.info`).
- **Tests** :
  - Domaine : `test/domain/**` vérifie les invariants des entités/VO.
  - Données : `test/data/**` couvre les adapters via AssetBundle factice.
  - Présentation : `test/features/**/presentation/blocs` utilise `bloc_test` et `mocktail`.
  - UI : `test/ui/**` contient les golden tests (mettre à jour via `flutter test --update-goldens`).
- **CI** : workflow GitHub Actions [`CI`](.github/workflows/ci.yml) exécutant `make ci`, le contrôle de couverture (`tool/check_coverage.dart`) et la validation du catalogue.

## Sécurité & secrets
- `.env` n’est pas versionné (`.gitignore`).
- `AppConfig` offre une API typée pour éviter les accès directs aux variables d’environnement.
- Les erreurs sont centralisées dans `AppFailure` pour éviter la fuite d’informations sensibles à l’UI.
- Voir `docs/refactor/error_policy.md` pour les catégories et le mapping Domain → UI.

## Roadmap & suivi
- **Plan détaillé** : `docs/refactor/mvvm_plan.md` (avancement par phases, risques, tests).
- **Décisions** : `docs/adr/*.md` (motivation, options écartées, implications).
- **Checklist** : `docs/quality/checklist.md` (build, lint, tests, comportement). Utilisez-la avant chaque merge.
- **État actuel** : Code map et README de dossiers (`lib/*/README.md`) décrivent les responsabilités et points d’extension.

Pour toute nouvelle contribution, créez une ADR si la décision impacte plusieurs couches ou introduit une nouvelle dépendance.
