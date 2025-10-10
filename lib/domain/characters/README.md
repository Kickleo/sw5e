<!--
Fichier : lib/domain/characters/README.md
Rôle : Expliquer la structure du sous-domaine Characters.
Dépendances : Types métier du dossier et AppResult.
Exemple d'usage : Lire avant d'ajouter un nouveau cas d'usage ou VO personnage.
-->

# Characters Domain Module

Ce module regroupe toutes les règles métier liées aux personnages Star Wars 5e :

```
lib/domain/characters/
├── entities/        # Entités (ex. Character)
├── value_objects/   # Objets valeur validant les invariants (AbilityScore, SpeciesId...)
├── repositories/    # Interfaces (ports) consommées par le domaine
└── usecases/        # Cas d'usage orchestrant les règles (finalisation, lecture...)
```

## Principes
1. **Immutabilité** : toutes les entités et Value Objects sont immuables et documentés.
2. **Résultats typés** : les use cases renvoient `AppResult` pour expliciter succès/erreur.
3. **Ports/Adapters** : les repositories définissent les contrats implémentés dans la couche Data.

## Ajouts futurs
- Cas d'usage supplémentaires (édition, suppression, export).
- Modules frères (`catalog/`, `rules/`...) suivant la même convention.

