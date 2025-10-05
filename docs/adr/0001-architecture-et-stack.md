# ADR 0001 — Architecture et stack de l’application RPG

**Statut**: Accepté  
**Date**: (aujourd’hui)

## Contexte
Application Flutter multi-appareils (mobile/tablette/desktop) pour gérer la création et l’évolution d’un personnage de JdR, son inventaire, pouvoirs, attaques, avec calculs automatiques et mode hors-ligne.

## Décisions
- **Architecture**: Clean Architecture (Domain / Data / Presentation).
- **Pattern UI**: MVVM avec **BLoC** (flutter_bloc) pour la logique de présentation.
- **Injection de dépendances**: **get_it**.
- **Réseau**: **Dio** + **Retrofit** (génération d’API clients).
- **Persistance locale**: **Drift** (SQLite), mode offline-first, migrations versionnées.
- **Moteur de règles**: module séparé `rules_engine`, pur/déterministe, versionné.
- **Qualité**: TDD prioritaire (tests Domain → BLoC → Data → Widgets), build_runner pour codegen, lints stricts.
- **UX multi-devices**: layouts responsives, accessibilité (clavier, contrastes, tailles), i18n.
- **CI**: analyse + génération + tests sur chaque PR.

## Alternatives considérées
- **State management**: Riverpod/Provider — retenu BLoC pour la clarté des transitions et l’écosystème de tests.
- **Persistance**: Isar/Hive — retenu Drift pour SQL, migrations et requêtes complexes.
- **Réseau**: http + json manuel — retenu Retrofit pour la productivité et la cohérence des DTO.

## Conséquences
- Dépendances génératrices (retrofit_generator, json_serializable, drift_dev) → nécessite build_runner et veille des versions.
- Discipline TDD et séparation stricte des couches pour garder la testabilité.
- Le module de règles doit rester indépendant de l’UI et de la DB.

## Prochaines étapes
1) Mettre à jour/valider `pubspec.yaml` selon ces choix.
2) Initialiser la DI (get_it) et la structure de features.
3) Rédiger les 3 premières user stories (MVP) avec critères d’acceptation.
