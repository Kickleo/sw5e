<!--
Fichier : lib/data/catalog/README.md
Rôle : Documenter le module catalogue de la couche Data.
Dépendances : AssetBundle Flutter, DTO catalogue.
Exemple d'usage : Consulter ce fichier avant de modifier les adapters du catalogue.
-->

# Data › Catalog Module

```
+---------------------------+
|  AssetBundle (.json)      |
+-------------+-------------+
              |
+-------------v-------------+
| AssetBundleCatalogDataSource |
+-------------+-------------+
              |
+-------------v-------------+
| AssetCatalogRepository      |
+-------------+-------------+
              |
+-------------v-------------+
| CatalogRepository (Domain)  |
+-----------------------------+
```

## Composants
- **DTOs** (`dtos/catalog_dtos.dart`) : décrivent la structure JSON et assurent le mapping vers les objets domaine.
- **Data source** (`data_sources/asset_bundle_catalog_data_source.dart`) : lit les fichiers `assets/catalog/*.json`.
- **Repository** (`repositories/asset_catalog_repository.dart`) : met en cache les DTO convertis et expose l'interface domaine.

## Tests associés
- `test/data/catalog/asset_catalog_repository_test.dart`
- `test/data/catalog/asset_catalog_repository_traits_test.dart`

Ces tests garantissent que les assets restent compatibles avec le domaine.
