<!--
Fichier : docs/refactor/code_map.md
Rôle : Fournir la cartographie des fichiers ajoutés/clé avec leurs rôles et dépendances.
Dépendances : Se base sur la structure actuelle du projet.
Exemple d'usage : Consulter ce document pour comprendre où ajouter une nouvelle pièce.
-->

# Code Map (Itération Phase 6 - Qualité & CI)

| Chemin | Rôle | Dépendances clés |
| --- | --- | --- |
| `.pre-commit-config.yaml` | Hooks locaux `make format/lint/test` | `pre-commit`, `Makefile` |
| `Makefile` | Commandes format/lint/test/ci (inclut le seuil couverture) | Flutter SDK, `tool/check_coverage.dart` |
| `.github/workflows/ci.yml` | Workflow GitHub Actions format/analyse/tests/couverture/catalogue | `Makefile`, `tool/check_coverage.dart`, `tool/catalog_validate.dart` |
| `README.md` | Guide racine (architecture, commandes, sécurité) | `docs/refactor/*`, `Makefile`, `.github/workflows/ci.yml` |
| `docs/adr/001-layered-architecture.md` | ADR sur la séparation en couches | `lib/common`, `lib/domain`, `lib/data`, `lib/features`, `lib/ui` |
| `docs/adr/002-state-management-bloc.md` | ADR adoption BLoC | `flutter_bloc`, `bloc_test` |
| `docs/adr/003-error-handling-app-failure.md` | ADR politique d'erreurs | `AppFailure`, `AppResult` |
| `docs/quality/checklist.md` | Checklist merge (build/lint/tests/doc) | `Makefile`, `docs/refactor/mvvm_plan.md` |
| `docs/ui/accessibility.md` | Règles d'accessibilité et composants dédiés | Flutter Material |
| `lib/main.dart` | Point d'entrée Flutter configurant config + logger | `AppConfig`, `ServiceLocator`, `ConsoleAppLogger` |
| `lib/app/README.md` | Documentation du shell applicatif (Sw5eApp, HomeNav) | `lib/app/app.dart`, `lib/app/home_nav.dart` |
| `lib/common/config/app_config.dart` | Chargement `.env` et accès typé | `flutter_dotenv` |
| `lib/common/di/service_locator.dart` | Service locator `get_it` pour DI | `get_it`, `AppConfig`, `AppLogger` |
| `lib/common/logging/app_logger.dart` | Interface de journalisation | Aucune |
| `lib/common/logging/console_app_logger.dart` | Implémentation console | `logger` |
| `lib/common/errors/app_failure.dart` | Typage des erreurs applicatives (`AppFailure`) | `DomainError`, `AppFailureCategory` |
| `lib/common/errors/README.md` | Politique d'erreurs et règles de mapping | `AppFailure` |
| `lib/common/result/app_result.dart` | Alias résultat commun + helpers `appOk/appErr` | `core/domain/result.dart` |
| `lib/common/README.md` | Guide de la couche Common | Aucune |
| `lib/di/character_creation_module.dart` | Enregistrement module création perso (ServiceLocator + providers legacy) | `ServiceLocator`, `get_it`, Riverpod |
| `lib/domain/README.md` | Guide de la couche Domain | Aucune |
| `lib/domain/characters/` | Sous-domaine Personnages (entités, VO, use cases, ports) | Value Objects + AppResult |
| `lib/domain/characters/usecases/load_quick_create_catalog.dart` | Contrat `LoadQuickCreateCatalog` (snapshot listes/équipements) | `AppResult`, `CatalogRepository` |
| `lib/domain/characters/usecases/load_quick_create_catalog_impl.dart` | Implémentation du snapshot catalogue | `CatalogRepository`, `DomainError` |
| `lib/domain/characters/services/catalog_lookup_service.dart` | Agrège les définitions catalogues (espèces, classes, options, pouvoirs) pour l'UI | `CatalogRepository`, `AppLogger` |
| `lib/domain/characters/usecases/load_species_details.dart` | Contrat pour récupérer traits d'espèce | `AppResult`, `CatalogRepository` |
| `lib/domain/characters/usecases/load_species_details_impl.dart` | Implémentation (résout les traits + ids manquants) | `CatalogRepository`, `DomainError` |
| `lib/domain/characters/usecases/load_class_details.dart` | Contrat pour charger la classe + compétences | `AppResult`, `CatalogRepository` |
| `lib/domain/characters/usecases/load_class_details_impl.dart` | Implémentation (tri compétences + définitions) | `CatalogRepository`, `DomainError` |
| `lib/data/README.md` | Guide de la couche Data | Aucune |
| `lib/data/catalog/README.md` | Diagramme module catalogue | AssetBundle |
| `lib/data/catalog_v2/dtos/catalog_v2_dtos.dart` | DTO + mapping JSON → domaine pour le catalogue v2 | `CatalogRepository` |
| `lib/data/catalog_v2/data_sources/asset_bundle_catalog_v2_data_source.dart` | Chargement JSON via AssetBundle (catalogue v2) | Flutter AssetBundle |
| `lib/data/catalog/repositories/asset_catalog_repository.dart` | Adapter CatalogRepository basé assets | DTO + data source |
| `lib/data/characters/repositories/in_memory_character_repository.dart` | Implémentation volatile de `CharacterRepository` | Entité `Character` |
| `lib/presentation/character_creation/blocs/class_picker_bloc.dart` | ViewModel BLoC du sélecteur de classe | `CatalogRepository`, `AppLogger`, `AppFailure` |
| `lib/presentation/character_creation/blocs/species_picker_bloc.dart` | ViewModel BLoC du sélecteur d'espèce | `CatalogRepository`, `AppLogger`, `AppFailure` |
| `lib/presentation/character_creation/blocs/saved_characters_bloc.dart` | ViewModel BLoC liste personnages sauvegardés | `ListSavedCharacters`, `AppResult`, `AppFailure` |
| `lib/presentation/character_creation/blocs/quick_create_bloc.dart` | ViewModel BLoC assistant de création rapide | `LoadQuickCreateCatalog`, `LoadSpeciesDetails`, `LoadClassDetails`, `FinalizeLevel1Character`, `AppLogger`, `AppFailure` |
| `lib/presentation/character_creation/blocs/character_summary_bloc.dart` | ViewModel BLoC résumé personnages (chargement/partage) | `ListSavedCharacters`, `AppLogger`, `AppFailure` |
| `lib/presentation/character_creation/states/quick_create_state.dart` | État immuable du wizard de création rapide | `ClassDef`, `TraitDef`, `AppFailure` |
| `lib/app/router/README.md` | Documentation de la configuration GoRouter | `lib/app/router/app_router.dart` |
| `lib/ui/navigation/README.md` | Guide de la navigation UI | GoRouter |
| `lib/ui/navigation/app_router.dart` | Construction du `GoRouter` (routes + erreurs) | `go_router`, `flutter_riverpod`, pages UI |
| `lib/ui/character_creation/pages/class_picker_page.dart` | Vue Flutter (instancie ClassPickerBloc via ServiceLocator + rendu liste/détails) | `flutter_bloc`, `ServiceLocator` |
| `lib/ui/character_creation/pages/species_picker.dart` | Vue Flutter (instancie SpeciesPickerBloc via ServiceLocator + rendu liste/détails) | `flutter_bloc`, `ServiceLocator` |
| `lib/ui/character_creation/pages/quick_create/quick_create_page.dart` | Vue Flutter binding QuickCreateBloc et étapes UI | `flutter_bloc`, `ServiceLocator`, Riverpod connectivité |
| `lib/ui/character_creation/pages/character_summary_page.dart` | Vue Flutter résumé branchée sur CharacterSummaryBloc + partage | `flutter_bloc`, `share_plus`, `ServiceLocator` |
| `lib/ui/character_creation/pages/saved_characters_page.dart` | Vue Flutter listant les personnages sauvegardés | `flutter_bloc`, `ServiceLocator` |
| `lib/ui/character_creation/widgets/README.md` | Guide des widgets partagés du module création | Flutter Material |
| `lib/ui/character_creation/widgets/catalog_details.dart` | Mise en forme des données catalogue (traits, options, pouvoirs) | Flutter Material |
| `lib/ui/character_creation/widgets/language_details.dart` | Carte détaillant les langues (description, script, locuteurs) | Flutter Material |
| `lib/ui/character_creation/widgets/species_ability_bonuses.dart` | Carte des bonus de caractéristiques d'espèce | Flutter Material |
| `lib/ui/character_creation/widgets/species_trait_details.dart` | Liste détaillée des traits d'espèce localisés | Flutter Material |
| `lib/ui/character_creation/widgets/character_section_divider.dart` | Séparateur accessible partagé | Flutter Material |
| `lib/presentation/README.md` | Guide de la couche Presentation | Aucune |
| `lib/ui/README.md` | Guide de la couche UI | Aucune |
| `test/data/catalog/*` | Tests d'intégration catalogue hors-ligne | `flutter_test`, adapter data |
| `tool/check_coverage.dart` | Script Dart imposant le seuil de couverture | `dart:io`, rapport LCOV |
| `test/data/characters/in_memory_character_repository_test.dart` | Tests unitaires repository mémoire | `flutter_test` |
| `test/presentation/character_creation/blocs/class_picker_bloc_test.dart` | Tests unitaires ClassPickerBloc | `bloc_test`, `mocktail` |
| `test/presentation/character_creation/blocs/species_picker_bloc_test.dart` | Tests unitaires SpeciesPickerBloc | `bloc_test`, `mocktail` |
| `test/presentation/character_creation/blocs/saved_characters_bloc_test.dart` | Tests unitaires SavedCharactersBloc | `bloc_test`, `mocktail` |
| `test/presentation/character_creation/blocs/quick_create_bloc_test.dart` | Tests unitaires QuickCreateBloc | `bloc_test`, `mocktail` |
| `test/presentation/character_creation/blocs/character_summary_bloc_test.dart` | Tests unitaires CharacterSummaryBloc | `bloc_test`, `mocktail` |
| `test/ui/character_creation/widgets/character_section_divider_golden_test.dart` | Golden test du séparateur partagé (génère la référence depuis un Base64 embarqué) | `flutter_test`, `matchesGoldenFile` |
| `test/domain/characters/entities/character_test.dart` | Tests entité Character et ses invariants | `flutter_test`, Value Objects |
| `test/domain/characters/usecases/finalize_level1_character_test.dart` | Scénario heureux FinalizeLevel1Character et persistance | `flutter_test`, `mocktail` |
| `test/domain/characters/usecases/list_saved_characters_test.dart` | Vérifie la récupération triée et les erreurs du listing | `flutter_test`, `mocktail` |
| `test/domain/characters/usecases/load_last_character_test.dart` | Contrôle le retour du dernier personnage ou null | `flutter_test`, `mocktail` |
| `test/domain/characters/usecases/load_class_details_impl_test.dart` | Couverture du chargement des détails de classe | `flutter_test`, `mocktail` |
| `test/domain/characters/usecases/load_quick_create_catalog_impl_test.dart` | Snapshot du catalogue rapide et validations | `flutter_test`, `mocktail` |
| `test/domain/characters/usecases/load_species_details_impl_test.dart` | Vérifie l'assemblage des détails d'espèce | `flutter_test`, `mocktail` |
| `test/domain/characters/value_objects/ability_score_test.dart` | Tests Value Object AbilityScore (bornes/modificateur) | `flutter_test` |
| `test/domain/characters/value_objects/character_name_test.dart` | Tests Value Object CharacterName (normalisation, erreurs) | `flutter_test` |
| `test/domain/characters/value_objects/quantity_test.dart` | Tests Value Object Quantity (bornes/helpers) | `flutter_test` |
| `test/domain/characters/value_objects/species_id_test.dart` | Vérifie la normalisation slug d'espèce | `flutter_test` |
| `test/domain/characters/value_objects/class_id_test.dart` | Vérifie la normalisation slug de classe | `flutter_test` |
| `test/domain/characters/value_objects/background_id_test.dart` | Vérifie la normalisation slug de background | `flutter_test` |
| `test/domain/characters/value_objects/level_test.dart` | Couvre les bornes du niveau de personnage | `flutter_test` |
| `test/domain/characters/value_objects/credits_test.dart` | Valide les montants de crédits | `flutter_test` |
| `test/domain/characters/value_objects/proficiency_bonus_test.dart` | Vérifie la table du bonus de maîtrise | `flutter_test` |
| `test/domain/characters/value_objects/hit_points_test.dart` | Gardes-fous des points de vie | `flutter_test` |
| `test/domain/characters/value_objects/defense_test.dart` | Gardes-fous de la défense | `flutter_test` |
| `test/domain/characters/value_objects/initiative_test.dart` | Gardes-fous de l'initiative | `flutter_test` |
| `test/domain/characters/value_objects/equipment_item_id_test.dart` | Slug d'objet d'équipement | `flutter_test` |
| `test/domain/characters/value_objects/skill_proficiency_test.dart` | Règles de maîtrise des compétences | `flutter_test` |
| `test/domain/characters/value_objects/encumbrance_test.dart` | Limites d'encombrement | `flutter_test` |
| `test/domain/characters/value_objects/maneuvers_known_test.dart` | Bornes du nombre de manœuvres | `flutter_test` |
| `test/domain/characters/value_objects/superiority_dice_test.dart` | Cohérence du pool de dés de supériorité | `flutter_test` |
| `test/domain/characters/value_objects/trait_id_test.dart` | Normalisation des identifiants de trait | `flutter_test` |
| `test/domain/characters/value_objects/character_id_test.dart` | Validation/génération d'identifiants de personnage | `flutter_test` |
| `test/domain/characters/value_objects/character_trait_test.dart` | Comparaison par valeur des traits | `flutter_test` |

> Cette carte sera enrichie à mesure que les couches sont migrées.
