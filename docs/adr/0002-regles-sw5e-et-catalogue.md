# ADR 0002 — Règles SW5e (snapshot) & Catalogue local

**Statut**: Accepté  
**Date**: (aujourd’hui)

## Contexte
Le MVP doit être reproductible : mêmes règles, mêmes tables, mêmes IDs. Les données doivent être disponibles hors-ligne.

## Décision
- **Snapshot des règles**: utiliser les URLs listées dans `docs/rules/sources.md` (snapshot 2025-10-06).  
- **Catalogue local packagé**: espèces, classes, backgrounds, équipement, formules de calcul (HP, Defense, Initiative, manœuvres, superiority dice).  
- **IDs/slug**: ASCII kebab-case (ex. `human`, `blaster-pistol`), stockés en minuscules.  
- **Versionnement**: `rules_version = "2025-10-06"` stocké avec chaque personnage.  
- **Schéma DB v1 (Drift)**: tables `species`, `classes`, `backgrounds`, `equipment`, `characters`, etc. (détail à venir dans ADR schéma v1).  
- **Politique de mise à jour**: toute MAJ de règles crée un **nouvel ADR** + **nouvelle version** du catalogue; migrations personnages **désactivées** au MVP (recréation si incompatibles).

## Alternatives
- Charger les règles à la volée en ligne → rejeté (hors-ligne requis, volatilité).  
- IDs libres (labels) → rejeté (non stable, i18n).

## Conséquences
- Un job de build génère/valide le catalogue local.  
- Les VO vérifient seulement les IDs/valeurs; les **calculs** restent dans le moteur/catalogue.  
- Migrations à définir pour v2+.

## Prochaines étapes
1) Définir le **format du catalogue** (JSON versionné) + validations.  
2) ADR schéma **Drift v1**.  
3) Pipeline CI : `analyze` + `build_runner` + tests.

---

## Conventions d’ID / slug

- **Format** : ASCII kebab-case (minuscules, chiffres et tirets).
- **Regex** : `^[a-z0-9-]{3,60}$` (espèces/classes 3–40 possible, équipement jusqu’à 60).
- **Génération** : minuscules → translittération des accents → suppression des apostrophes → remplace tous séparateurs par `-` → compacter les `-` → trim `-` début/fin.
- **Stabilité** : le **slug est canonique** et **indépendant** des traductions/libellés ; il **ne change pas** entre versions de règles, sauf renommage métier justifié (nouvel ID).
- **Unicité** : unique **par domaine** (species, classes, backgrounds, equipment, skills…).
- **Références** : les entités du personnage (SpeciesId, ClassId, EquipmentItemId, …) stockent **le slug**, pas le libellé (i18n côté catalogue/UI).
- **CI** : une vérification de **conformité (regex)** et **d’unicité** des slugs sera ajoutée au pipeline (job “catalog-validate”).
