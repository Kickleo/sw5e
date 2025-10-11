<!--
Fichier : docs/adr/002-state-management-bloc.md
Rôle : Capturer la décision d'utiliser BLoC pour le binding View ↔ ViewModel.
Dépendances : Vues Flutter, flutter_bloc, tests bloc_test.
Exemple d'usage : Référence lors de la création d'un nouveau ViewModel ou pour challenger l'usage d'un autre outil.
-->

# ADR 002 – Gestion d'état avec BLoC

## Contexte
Le code initial utilisait Riverpod avec des `StateNotifier` volumineux, difficiles à tester et à injecter dans les vues. L'objectif MVVM impose un ViewModel testable isolant la vue.

## Décision
Nous adoptons `flutter_bloc` pour implémenter les ViewModels MVVM. Chaque écran possède un BLoC dédié exposant des événements immuables et des états sérialisables. Les vues se limitent à `BlocBuilder`/`BlocListener` et à l'envoi d'événements.

## Conséquences
- **Positives** : meilleures pratiques de tests (`bloc_test`), séparation claire entre logique et rendu, réutilisation possible en web/mobile.
- **Négatives** : nécessite plus de boilerplate (events/states) et une discipline sur la taille des BLoCs.
- **Actions** : fournir systématiquement des tests `bloc_test` pour chaque BLoC et documenter les événements/états dans le fichier correspondant.
