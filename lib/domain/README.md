<!--
Fichier : lib/domain/README.md
Rôle : Présenter la couche Domaine et ses conventions.
Dépendances : Doit rester indépendante des couches Flutter/infra.
Exemple d'usage : Lire avant d'ajouter une entité ou un use case.
-->

# Domain Layer

La couche **Domain** contient les règles métier pures : entités, objets valeur et cas d'usage orchestrant la logique.

```
+-------------------+
|     UI / View     |
+---------+---------+
          |
+---------v---------+
|   Presentation    |
+---------+---------+
          |
+---------v---------+
|      Domain       |
+-------------------+
```

## Contenu prévu
- `characters/` : Dossier feature regroupant entités, VO, use cases et ports.
- (à venir) d'autres sous-domaines spécialisés.

## Sous-modules actuels
- `characters/` : règles métier liées aux personnages (entités, VOs, use cases, repositories).

## Règles clés
1. Aucun import de Flutter ni d'infrastructure.
2. Utiliser des types immuables/documentés.
3. Tester chaque règle métier de manière unitaire.

