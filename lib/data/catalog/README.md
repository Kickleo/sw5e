<!--
Fichier : lib/data/catalog/README.md
Rôle : Documenter le module catalogue de la couche Data.
Dépendances : AssetBundle Flutter, DTO catalogue.
Exemple d'usage : Consulter ce fichier avant de modifier les adapters du catalogue.
-->

# Data › Catalog Module

- Assets `assets/catalog_v2/` → `AssetBundleCatalogV2DataSource`
- `AssetCatalogRepository` s'appuie exclusivement sur la data source v2 et expose `CatalogRepository` au domaine.

## Composants
- **DTOs v2** (`../catalog_v2/dtos/catalog_v2_dtos.dart`) : structures spécifiques aux assets `assets/catalog_v2/*`.
- **Data source v2** (`../catalog_v2/data_sources/asset_bundle_catalog_v2_data_source.dart`) : lit les fichiers `assets/catalog_v2/*.json`.
- **Repository** (`repositories/asset_catalog_repository.dart`) : met en cache les DTO convertis et expose l'interface domaine à partir des données v2.
- Les options de personnalisation (feats, styles, etc.) sont désormais chargées depuis `assets/catalog_v2/customization_options.json` au même titre que les traits, espèces et classes.
- Les pouvoirs de Force et technologiques sont lus via `assets/catalog_v2/{force,tech}_powers.json` et exposés par `CatalogRepository`.

## Tests associés
- `test/data/catalog/asset_catalog_repository_test.dart`
- `test/data/catalog/asset_catalog_repository_traits_test.dart`

Ces tests garantissent que les assets restent compatibles avec le domaine.
