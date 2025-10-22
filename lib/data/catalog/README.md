<!--
Fichier : lib/data/catalog/README.md
Rôle : Documenter le module catalogue de la couche Data.
Dépendances : AssetBundle Flutter, DTO catalogue.
Exemple d'usage : Consulter ce fichier avant de modifier les adapters du catalogue.
-->

# Data › Catalog Module

- Assets `assets/catalog/` → `AssetBundleCatalogDataSource`
- Assets `assets/catalog_v2/` → `AssetBundleCatalogV2DataSource`
- `AssetCatalogRepository` agrège les deux data sources et expose `CatalogRepository` au domaine.

## Composants
- **DTOs historiques** (`dtos/catalog_dtos.dart`) : décrivent la structure JSON v1 et assurent le mapping vers les objets domaine.
- **DTOs v2** (`../catalog_v2/dtos/catalog_v2_dtos.dart`) : structures spécifiques aux assets `assets/catalog_v2/*`.
- **Data source v1** (`data_sources/asset_bundle_catalog_data_source.dart`) : lit les fichiers `assets/catalog/*.json`.
- **Data source v2** (`../catalog_v2/data_sources/asset_bundle_catalog_v2_data_source.dart`) : lit les fichiers `assets/catalog_v2/*.json`.
- **Repository** (`repositories/asset_catalog_repository.dart`) : met en cache les DTO convertis et expose l'interface domaine.

## Tests associés
- `test/data/catalog/asset_catalog_repository_test.dart`
- `test/data/catalog/asset_catalog_repository_traits_test.dart`

Ces tests garantissent que les assets restent compatibles avec le domaine.
