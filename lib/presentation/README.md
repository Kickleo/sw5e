<!--
Fichier : lib/presentation/README.md
Rôle : Documenter la couche Présentation (ViewModels/BLoC).
Dépendances : Flutter_bloc et dépendances d'orchestration.
Exemple d'usage : Lire avant de créer un nouveau BLoC ou provider.
-->

# Presentation Layer

La couche **Presentation** héberge les ViewModels MVVM (BLoC, Cubit) qui convertissent les événements UI en états immuables.

```
+-------------------+
|        UI         |
+---------+---------+
          |
+---------v---------+
|    Presentation   |
+---------+---------+
          |
+---------v---------+
|      Domain       |
+-------------------+
```

## Contenu actuel
- `character_creation/blocs/` : ViewModels BLoC pour le module de création/gestion des personnages.
- `character_creation/states/` : Objets d'état immuables partagés par les blocs (ex. `QuickCreateState`).
- `providers/` *(à venir)* : Factories et helpers d'injection complémentaires au service locator.
- `mappers/` *(à venir)* : Conversion Domain → UI (formatage, traduction).

## Bonnes pratiques
1. Un BLoC = un fichier documenté (événements/états). Utiliser `bloc_test`.
2. Pas de widgets Flutter ici (seulement logique). Les dépendances sont injectées.
3. Utiliser des états immuables (`equatable` ou `freezed`).

