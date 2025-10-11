<!--
Fichier : lib/data/README.md
Rôle : Documenter la couche Data (adapters, sources, mapping).
Dépendances : Peut utiliser Flutter/Dart IO, packages externes.
Exemple d'usage : Lire avant d'ajouter un repository concret.
-->

# Data Layer

La couche **Data** implémente les ports du domaine via des adapters (assets, API, cache) et gère les transformations DTO ↔ domaine.

```
+-------------------+
|      Domain       |
+---------+---------+
          |
+---------v---------+
|       Data        |
+---------+---------+
          |
+---------v---------+
|  Sources externes |
+-------------------+
```

## Modules en place
- `catalog/dtos/` : DTO sérialisables (structures JSON) avec conversion vers le domaine.
- `catalog/data_sources/` : Source `AssetBundleCatalogDataSource` lisant les assets.
- `catalog/repositories/` : Adapter `AssetCatalogRepository` qui implémente `CatalogRepository`.
- `characters/repositories/` : Adapters `InMemoryCharacterRepository` (volatil)
  et `PersistentCharacterRepository` (fichier JSON local) implémentant
  `CharacterRepository`.

## Contenu prévu
- `repositories/` : Implémentations concrètes exposées au domaine.
- `datasources/` : Accès brut aux sources (assets, API...).
- `dto/` : Objets de transfert sérialisables.
- `mappers/` : Conversions centralisées DTO ↔ entités.

## Bonnes pratiques
1. Les erreurs brutes sont converties en erreurs domaine.
2. Chaque mapper doit avoir un test couvrant les cas critiques.
3. Prévoir le support hors-ligne et l'évolution vers API distantes.

