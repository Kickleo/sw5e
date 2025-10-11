<!--
Fichier : docs/refactor/mvvm_plan.md
Rôle : Décrire le plan de refactorisation MVVM par phases.
Dépendances : Synthèse basée sur l'audit initial du projet.
Exemple d'usage : S'appuyer sur ce plan pour prioriser et suivre les travaux de refonte.
-->

# Plan de refactorisation MVVM

> Objectif : refondre l'application en architecture MVVM structurée en cinq couches (domain / data / presentation / ui / common) tout en conservant le comportement existant.

## Statut d'avancement

- [x] **Phase 0 — Préparation et alignement** : audit initial consigné dans `code_map.md` et décisions clés formalisées via ADR 001-003.
- [x] **Phase 1 — Infrastructure et socle commun** : couches créées (`lib/common`, `lib/domain`, `lib/data`, `lib/presentation`, `lib/ui`), configuration `.env` (`AppConfig`), logger (`ConsoleAppLogger`) et scripts Makefile opérationnels.
- [x] **Phase 2 — Domaine (Domain Layer)** : entités/VO/use cases migrés sous `lib/domain/characters`, tests renforcés (`test/domain/characters/**/*`) et documentation mise à jour (`docs/domain/character_creation/*.md`).
- [x] **Phase 3 — Données (Data Layer)** : adapters assets/mémoire introduits (`lib/data/catalog`, `lib/data/characters`) avec tests d'intégration (`test/data/**/*`) et politique de secrets documentée dans le README racine.
- [x] **Phase 4 — Présentation (ViewModel / BLoC)** : blocs MVVM (`lib/presentation/character_creation/blocs`) + états documentés, injection via `ServiceLocator`, couverture `bloc_test` consolidée.
- [x] **Phase 5 — UI (Views Flutter)** : vues déplacées sous `lib/ui/character_creation`, navigation GoRouter centralisée (`lib/ui/navigation/app_router.dart`), accessibilité décrite (`docs/ui/accessibility.md`) et golden tests ajoutés.
- [x] **Phase 6 — Qualité, CI et documentation finale** : workflow GitHub Actions (`.github/workflows/ci.yml`), script de seuil de couverture (`tool/check_coverage.dart`), checklist qualité (`docs/quality/checklist.md`) et README finalisé.

## Actions restantes

- Valider localement la checklist de qualité (`docs/quality/checklist.md`) en exécutant les commandes `make format`, `make lint`, `make test` et `make build` sur un poste équipé du SDK Flutter.
- Tentative automatisée dans l'environnement de refactor : chaque commande `make` échoue car le binaire `flutter` est absent (`Error 127`). Relancer sur un poste disposant du SDK pour finaliser la validation.
- Documenter toute divergence observée lors des validations manuelles pour les intégrer dans une itération de maintenance.


## Phase 0 — Préparation et alignement
- **Audit détaillé** : cartographier fichiers actuels, repérer responsabilités, dettes et points critiques.
- **Glossaire métier** : lister les termes Star Wars 5e, définir noms normalisés pour harmoniser le code.
- **Outils qualité** : introduire `melos` ou `very_good_analysis` pour lint/format, configurer `pre-commit` avec format + analyse.
- **Livrables** : ADR sur choix BLoC (Business Logic Component = pattern de gestion d'état par flux d'événements) vs Riverpod, politique d'erreurs, mécanisme DI.

## Phase 1 — Infrastructure et socle commun
- **Structure dossiers** : créer `/lib/common`, `/lib/domain`, `/lib/data`, `/lib/presentation`, `/lib/ui` avec README et diagrammes ASCII.
- **Résultats typés** : implémenter un type `AppResult` (Result = enveloppe succès/erreur) commun et politique d'erreurs documentée.
- **Configuration** : intégrer `flutter_dotenv` (gestion `.env` = fichier texte de variables d'environnement) + wrapper sécurisé.
- **Journalisation** : ajouter `logger` avec interface `AppLogger` et adapter console.
- **Livrables** : Code Map initial, scripts Makefile (`make lint/test/format/ci`).

## Phase 2 — Domaine (Domain Layer)
- **Migration entités** : déplacer entités/VO existants en `domain/entities`, documenter pré/post-conditions.
- **Use cases** : introduire interfaces `LoadCatalogUseCase`, etc., orchestrées via `Future`/`Stream` contrôlés.
- **Tests unitaires** : couvrir règles métier (ex. validation d'AbilityScore), viser ≥85% pour ce module.
- **Livrables** : README domaine, diagramme ASCII entités, exemples d'usage.

## Phase 3 — Données (Data Layer)
- **Repositories** : définir interfaces côté domaine (`CatalogRepository`, `CharacterRepository`).
- **Adapters** : implémenter adapter assets (`AssetCatalogDataSource`), introduire DTO via `json_serializable`.
- **Cache et mapping** : centraliser mapping DTO↔domain, ajouter tests intégration sur repository (lecture assets).
- **Livrables** : README data, diagramme flux données, politique de gestion de secrets.

## Phase 4 — Présentation (ViewModel / BLoC)
- **Adopter BLoC** : chaque fonctionnalité → `Bloc` (ex. `QuickCreateBloc`) + `State`/`Event` immuables (`freezed`).
- **Logique** : déplacer logique UI (validation, navigation) dans blocs, vue ne gère que binding.
- **Injection** : configurer `get_it` (service locator = registre d'instances) ou `riverpod` en mode provider simple pour instancier blocs.
- **Tests** : utiliser `bloc_test` pour scénarios, mocker repositories via `mocktail`.
- **Livrables** : README présentation, diagramme cycle de vie bloc, exemples test.

## Phase 5 — UI (Views Flutter)
- **Refactor pages** : découper pages en widgets « dumb » (Widget = composant UI Flutter) connectés à `BlocBuilder`/`BlocListener`.
- **Navigation** : isoler routes dans `ui/navigation`, documenter transitions.
- **Accessibilité et UX** : vérifier focus, support web/mobile.
- **Livrables** : README UI, capture écrans, démonstration binding.

## Phase 6 — Qualité, CI et documentation finale
- **Tests globaux** : exécuter `flutter test` complet, rapport couverture >70%.
- **CI** : workflow GitHub Actions avec cache pub, étapes format/analyze/test/cobertura.
- **Documentation** : mettre à jour README racine, ADRs, Code Map exhaustive, Roadmap itérations futures.
- **Checklist finale** : comportement inchangé, performance OK, logs corrects, configuration documentée.

## Checklist de vérification continue
1. **Build** : `flutter build apk --debug` (ou web) sans erreur.
2. **Lint** : `flutter analyze` + `dart format --output=none --set-exit-if-changed`.
3. **Tests** : `flutter test --coverage`.
4. **Comportement** : validation manuelle du wizard de création (toutes étapes, sauvegarde, chargement).

## Risques identifiés
- **Régression fonctionnelle** : migration en couches peut introduire des divergences → atténuée via tests snapshot + golden.
- **Complexité accrue** : introduction BLoC + DI peut être déroutante → atténuée via documentation et exemples.
- **Dette documentaire** : volume de commentaires élevé → automatiser via templates et lint doc.

## Notes de justification (globales)
- BLoC choisit un pattern évènementiel clair pour MVVM en Flutter et sépare vues/logique.
- Découpage en couches facilite substitution future (API distante) sans toucher domaine.
- Outils qualité/CI assurent maintenabilité et onboarding simple.

## Tests à ajouter (vision)
- Domain : tests unitaires sur entités et use cases.
- Data : tests d'intégration sur repositories et data sources.
- Présentation : `bloc_test` pour scénarios utilisateur critiques (création rapide, sauvegarde).
- UI : golden tests pour composants clés.

## Roadmap technique (3 itérations)
1. **Itération 1** : Phases 0-2 (socle, domaine) + ADRs clés.
2. **Itération 2** : Phases 3-4 (données + blocs) + tests associés.
3. **Itération 3** : Phase 5-6 (UI finale, CI, documentation complète, couverture ≥70%).

