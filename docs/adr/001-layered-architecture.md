<!--
Fichier : docs/adr/001-layered-architecture.md
Rôle : Documenter la décision d'adopter une architecture en couches Domain/Data/Presentation/UI/Common.
Dépendances : Se réfère au plan MVVM et aux dossiers lib/common, lib/domain, lib/data, lib/features, lib/ui.
Exemple d'usage : Justifier la séparation lors de nouvelles contributions ou revues de code.
-->

# ADR 001 – Architecture en couches MVVM

## Contexte
Le projet héritait d'un mélange de logique UI/domaine et de repositories sans séparation nette. Les nouvelles exigences imposent MVVM et une documentation forte, tout en préparant la bascule d'une persistence hors-ligne vers des sources distantes.

## Décision
Nous structurons le code en cinq couches : Common (outils transverses), Domain (règles métier), Data (adapters/DTO), Presentation (BLoC ViewModels) et UI (Widgets). Chaque couche ne dépend que de celles situées en dessous, sauf Common qui reste transverse. Les ViewModels (BLoC = composant qui transforme des événements en états) matérialisent le ViewModel MVVM.

## Conséquences
- **Positives** : responsabilités explicites, tests ciblés sans Flutter pour Domain/Data, facilité d'onboarding via READMEs par dossier.
- **Négatives** : davantage de fichiers/boilerplate pour les mappings, nécessité de maintenir la Code Map à jour.
- **Actions** : Mise à jour continue de `docs/refactor/code_map.md` et des READMEs si de nouveaux modules apparaissent.
