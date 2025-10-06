# Sources des règles — Star Wars 5e (SW5e)

## 1) Sources canoniques (à compléter)
- **Règles de base / Player’s Handbook (PHB)** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/rules/phb
- **Étapes de création — Step-By-Step Characters** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/rules/phb/stepByStep
- **Espèces (Chapter 2)** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/rules/phb/species
- **Classes (Chapter 3)** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/rules/phb/classes
- **Backgrounds / Personnalité (Chapter 4)** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/rules/phb/backgrounds
- **Équipement (Chapter 5)** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/rules/phb/equipment
- **Customization Options / Feats (Chapter 6)** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/rules/phb/customization
- **Caractéristiques & Compétences (Chapter 7 — Using Ability Scores)** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/rules/phb/abilityScores
- **Manœuvres — Chapitre 13 (règles)** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/rules/phb/maneuvers
- **Manœuvres — Liste complète (référentiel)** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/characters/maneuvers
- **Combat (Chapter 9)** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/rules/phb/combat
- **Force- & Tech-casting (Chapter 10)** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/rules/phb/casting
- **Listes des pouvoirs — Force Powers** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/characters/forcePowers
- **Listes des pouvoirs — Tech Powers** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/characters/techPowers
- **Conditions (Appendix A)** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/rules/phb/conditions
- **Variant Rules recommandées (Appendix B)** — Version/commit : snapshot 2025-10-06 | Date : 2025-10-06 | Lien : https://sw5e.com/rules/phb/variantRules

> Note : indique la **version exacte** (numéro ou hash) pour garantir la reproductibilité.  
> Si plusieurs sites/repos existent, marque celui considéré **source de vérité**.

## 2) Règles de priorité en cas de conflit
1. Core ⟶ errata ⟶ modules ⟶ homebrew (désactivé au MVP).
2. Version figée au MVP : ___ (toute mise à jour future = nouvel ADR + migration).

## 3) Périmètre MVP (rappel)
- Niveau **1 uniquement** ; pas de montée de niveau.
- Équipement **de départ** ; échanges limités.
- Pouvoirs/attaques **de base** si requis par le niveau 1.
- Hors-ligne : toutes les tables **packagées localement**.

## 4) Glossaire & IDs (conventions)
- Identifiants typés : `SpeciesId`, `CareerId`, `EquipmentItemId`, etc.
- Formats d’ID (slug, uuid, code court) : ___
- Localisation (i18n) des noms/descr. : clés : ___

## 5) Plan d’extraction (pour créer les Value Objects)
- Tables à extraire en premier : **caractéristiques**, **espèces**, **carrières/archétypes**, **équipement de départ**, **formules PV/défense/initiative**.
- Pour chaque table : noter champs, contraintes, unités, arrondis.
- Lister les **invariants** que devront porter les VO.

## 6) Traçabilité
- ADR lié : **0001-architecture-et-stack**
- Prochain ADR : **0002-version-règles-SW5e-MVP** (à rédiger après remplissage de ce fichier).
