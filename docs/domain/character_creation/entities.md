# Domain — Character Creation (Entities & Use Case)

## Agrégat racine : `Character`
**But** : représenter un personnage **niveau 1 prêt à jouer** (MVP).

> Tests automatisés : `test/domain/characters/entities/character_test.dart`
> vérifie les invariants critiques (niveau, caractéristiques complètes,
> inventaire sans quantité nulle).

### Champs (tous immuables)
- `name: CharacterName`
- `speciesId: SpeciesId`
- `classId: ClassId`
- `backgroundId: BackgroundId`
- `level: Level` **= 1 (MVP)**
- `abilities: Map<AbilityId, AbilityScore>`  
  - `AbilityId ∈ {STR, DEX, CON, INT, WIS, CHA}` — **exactement 6 entrées**
- `skills: Set<SkillProficiency>` (clé logique = `skillId`)
- `proficiencyBonus: ProficiencyBonus` (dérivé de `level`)
- `hitPoints: HitPoints`
- `defense: Defense`
- `initiative: Initiative`
- `credits: Credits` (restants après équipement de départ)
- `inventory: List<InventoryLine>`  
  - `InventoryLine = { itemId: EquipmentItemId, quantity: Quantity }`
- `encumbrance: Encumbrance` (somme normalisée en **grammes**)
- `maneuversKnown: ManeuversKnown` (peut être 0 au niveau 1)
- `superiorityDice: SuperiorityDice` (peut être `{count:0, die:null}`)

### Invariants d’agrégat
- `level == 1` (MVP).
- `abilities` contient **exactement** les 6 `AbilityId`.
- `skills` **sans doublon** par `skillId`.
- `inventory` : toutes les `quantity >= 0` ; pas de ligne avec `quantity == 0` dans l’**état final** (OK transitoire dans l’assistant).
- `encumbrance` cohérente avec `inventory` (calculée côté moteur/catalogue).
- `speciesId`, `classId`, `backgroundId`, `equipmentItemId` **existent** dans le **catalogue** du snapshot de règles figé.
- Valeurs dérivées (`proficiencyBonus`, `hitPoints`, `defense`, `initiative`, `maneuversKnown`, `superiorityDice`) **proviennent du moteur de règles** ; l’entité **ne recalcule pas**.

### Énumérations / types de référence
- `AbilityId = {STR, DEX, CON, INT, WIS, CHA}` (fixe, non i18n).
- `SkillId` = slug catalogue (non i18n).  
- Les **libellés** (traductions) viennent du **catalogue**, pas du domaine.

---

## Use Case UC-CC-001 — Finaliser un personnage niveau 1
**Nom** : `FinalizeLevel1Character`  
**But** : À partir des sélections de l’assistant, **valider** et **produire** un `Character` **prêt à jouer**.

### Entrée (Input DTO)
- `name: CharacterName`
- `speciesId: SpeciesId`
- `classId: ClassId`
- `backgroundId: BackgroundId`
- `baseAbilities: Map<AbilityId, AbilityScore>` (avant modifs d’espèce/background)
- `chosenSkills: Set<SkillId>` (issues des options autorisées)
- `chosenEquipment: List<{itemId: EquipmentItemId, quantity: Quantity}>`
- (optionnel) autres choix niveau 1 requis par certaines classes (hors MVP si non nécessaires)

### Sortie (Output)
- `Either<DomainError, Character>`

### Règles (résumées)
1. **Valider** les prérequis / budgets (points, compétences, équipement, poids) via le **catalogue** (snapshot).  
2. **Appliquer** les modificateurs d’espèce/background/classe pour obtenir les **scores finaux**.  
3. **Calculer** les dérivés : `proficiencyBonus`, `hitPoints`, `defense`, `initiative`, `maneuversKnown`, `superiorityDice`, `encumbrance`, `credits restants`.  
4. **Construire** l’entité `Character` **si tout est valide** ; sinon renvoyer un `DomainError` précis.

### Ports (interfaces domaine)
- `CatalogRepository` (lecture seule)
  - `getSpecies(speciesId)`, `getClass(classId)`, `getBackground(backgroundId)`
  - `getSkill(skillId)`, `getEquipment(itemId)`
  - Tables/formules de calcul niveau 1 (HP, Defense, Initiative, Maneuvers, SuperiorityDice, budget de départ, poids…)
- `CharacterRepository` (persistance locale)
  - `save(Character) -> Future<void>`
  - `loadLast() -> Future<Option<Character>>` (Story 2)

### Erreurs métier possibles (exemples)
- `InvalidPrerequisite` (choix incompatibles)  
- `PointsBudgetExceeded` (caracs/équipement)  
- `UnknownCatalogId` (ID absent du snapshot)  
- `InconsistentDerivedValue` (moteur renvoie une valeur incohérente)  
- `InvalidInventory` (quantités négatives, etc.)

### Tests à prévoir (haute-niveau)
- [ ] Avec des sélections valides niveau 1 → renvoie un `Character` complet.  
- [ ] Pré-requis non remplis → `InvalidPrerequisite`.  
- [ ] Budget équipement > crédits → `PointsBudgetExceeded`.  
- [ ] ID inconnus → `UnknownCatalogId`.  
- [ ] Incohérences de valeurs dérivées → `InconsistentDerivedValue`.

---

## Notes d’implémentation (Clean Arch)
- **Domain** : `Character` (entité), `FinalizeLevel1Character` (use case), `CatalogRepository` & `CharacterRepository` (interfaces).
- **Data** : impl. `CatalogRepository` (lecture des tables locales — ex. Drift/JSON packagé) et `CharacterRepository` (Drift).
- **Presentation** : BLoC/VM de l’assistant et de la fiche, orchestrant le use case.
