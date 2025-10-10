<!--
Fichier : docs/quality/checklist.md
Rôle : Fournir la checklist de vérification build/lint/tests/comportement avant merge.
Dépendances : README, Makefile, docs/refactor/mvvm_plan.md.
Exemple d'usage : S'assurer que tout est validé lors d'une revue de code.
-->

# Checklist de vérification

_Note (exécution conteneur) : les commandes `make format`, `make lint`, `make test` et `make build` échouent ici faute de SDK Flutter (`flutter: No such file or directory`). Relancer sur une machine équipée du SDK pour cocher les cases correspondantes._

## 1. Build & configuration
- [ ] `.env` présent (copié depuis `.env.example`).
- [ ] `flutter pub get` exécuté (vérifier `pubspec.lock` à jour).
- [ ] `make build` (ou `flutter build <plateforme>` selon la cible) réussi.
- [ ] Workflow GitHub Actions `CI` vert sur la branche ou la Pull Request.

## 2. Qualité du code
- [ ] `make format` exécuté, aucun diff restant.
- [ ] `make lint` sans avertissement bloquant.
- [ ] Analyse des journaux `AppLogger` pour les nouvelles fonctionnalités (logs de niveau `warning`/`error`).

## 3. Tests & couverture
- [ ] `make test` (alias `flutter test --coverage`) vert et vérifié par `tool/check_coverage.dart`.
- [ ] Couverture ≥ 70 % (consulter `coverage/lcov.info` ou le rapport HTML généré via `genhtml`).
- [ ] Tests ajoutés pour toute logique métier ou BLoC modifiée.
- [ ] Golden tests (`test/ui/**`) exécutés ou mis à jour via `--update-goldens`.

## 4. Comportement fonctionnel
- [ ] Navigation principale (`HomeNav`, création rapide, liste, résumé) testée manuellement.
- [ ] Vues vérifiées en mode offline (catalogue chargé depuis assets).
- [ ] Messages d'erreur vérifiés en provoquant au moins un `AppFailure` par catégorie pertinente.

## 5. Documentation
- [ ] README principal mis à jour si l'usage change.
- [ ] Code Map (`docs/refactor/code_map.md`) enrichie.
- [ ] ADR ajoutée/modifiée si une décision architecturale évolue.
- [ ] Règles d'accessibilité (`docs/ui/accessibility.md`) revues si la navigation/UI évolue.

_Note : cochez chaque point lors de la préparation de la Pull Request. Les éléments non applicables doivent être justifiés dans la description._
