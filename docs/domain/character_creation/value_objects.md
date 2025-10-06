# Value Objects — Character Creation (MVP)

> Un Value Object (VO) est immuable, auto-validé à la création, égalité par valeur, sans identité.

## Checklist générale (à respecter pour chaque VO)
- [ ] Immuable
- [ ] Constructeur valide (rejette les états invalides)
- [ ] Égalité par valeur
- [ ] Messages d’erreur métier clairs
- [ ] Mapping vers primitives (JSON/DB) défini
- [ ] Tests de bords (min/max, formats, unités)

---

## Liste prioritaire des Value Objects (MVP)

1) CharacterName — nom valide (non vide, longueur max).
2) SpeciesId — identifiant typé d’espèce choisie.
3) ClassId — identifiant typé de classe choisie.
4) BackgroundId — identifiant typé de background choisi.
5) Level — niveau du personnage (MVP: 1, mais type prêt pour 1–20).
6) AbilityScore — valeur d’une caractéristique (bornes & achat).
7) SkillProficiency — maîtrise d’une compétence (oui/non + source).
8) ProficiencyBonus — bonus de maîtrise (dérivé du Level ; MVP: +2).
9) HitPoints — points de vie (formule niveau 1, arrondis).
10) Defense — valeur de défense (équivalent AC ; armures & modifs).
11) Initiative — valeur d’initiative (formule & arrondis).
12) Credits — monnaie ≥ 0 (unités & arrondis).
13) EquipmentItemId — identifiant typé d’objet d’équipement.
14) Quantity — quantité d’un objet (entier ≥ 0, limites).
15) Encumbrance — encombrement/poids utile (unités, bornes).
16) ManeuversKnown — nombre de manœuvres connues (si classe).
17) SuperiorityDice — pool de dés de supériorité (taille + face), si classe.

---

## 1) CharacterName
**Rôle** : Nom du personnage

**Invariants**
- Longueur **1 à 50** caractères après **trim** (pas d’espaces en tête/fin).
- Autorisés : **lettres Unicode**, **chiffres** (pour des noms type *R2-D2*), **espace**, **tiret (-)**, **apostrophe (')** ou **apostrophe typographique (’)**, **point (.)**.
- **Interdits** : retours ligne, tabulations, caractères de contrôle, emojis/symboles non textuels.
- Normalisation recommandée : **Unicode NFC** ; **espaces multiples** internes normalisés en **un seul**.

**Erreurs à lever**
- `CharacterName.empty` si, après trim/normalisation, c’est vide.
- `CharacterName.tooLong` si > 50.
- `CharacterName.invalidChars` si caractères non autorisés.

**Mapping data (JSON/DB)**
- **JSON** : clé `name: string` (valeur **normalisée**).
- **DB (Drift)** : colonne `name TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 50)`.
  - Collation d’affichage : conserver la casse et les diacritiques.
  - Index éventuel pour recherche (plus tard).

**Cas limites**
- `"  "` → trim ⇒ vide → **invalid**.
- `"Obi-Wan Kenobi"` (tiret insécable / typographique) ⇒ **autorisé** si normalisé en `-`.
- `"R2-D2"` ⇒ **autorisé**.
- `"O’Malley"` (apostrophe typographique) ⇒ **autorisé**.
- Emojis (`"Jedi🔥"`) ⇒ **invalid** (char non autorisé).

**Tests à prévoir**
- [ ] Accepte : `Luke`, `R2-D2`, `O’Malley`, `Obi-Wan Kenobi`.
- [ ] Rejette : chaîne vide / espaces seuls / >50 chars / emoji / saut de ligne.
- [ ] Normalise : trim, espaces multiples → un espace, NFC.

---

## 2) SpeciesId
**Rôle** : Identifiant **typé** d’une espèce choisie (référence au catalogue local SW5e)

**Invariants**
- Valeur **non nulle**, **non vide**.
- Format **slug ASCII** : `^[a-z0-9-]{3,40}$` (kebab-case, pas d’espaces, pas d’accents).
- **Insensible à la casse** (normaliser en minuscules).
- Doit **exister** dans le **catalogue d’espèces** packagé pour la **version de règles** figée (snapshot).
- Indépendant de la langue (le **libellé** est hors VO, géré via i18n/catalogue).

**Erreurs à lever**
- `SpeciesId.invalidFormat` si la chaîne ne matche pas le slug.
- `SpeciesId.unknown` si l’ID n’est pas présent dans le catalogue d’espèces courant.
- `SpeciesId.nullOrEmpty` si vide après trim/normalisation.

**Mapping data (JSON/DB)**
- **JSON** : `{"speciesId": "human"}` (string **normalisée** en minuscules).
- **DB (Drift)** :
  - Colonne `species_id TEXT NOT NULL`.
  - Clé étrangère recommandée : `FOREIGN KEY (species_id) REFERENCES species(id)`.
  - Table `species(id TEXT PRIMARY KEY, ...meta)` gérée par le **catalogue** (data layer), pas par le domaine.

**Cas limites**
- Entrées avec majuscules (`"Human"`) → **normalisées** en `"human"`.
- Entrées avec diacritiques/espaces (`"togruta "` / `"togrutá"`) → **invalidFormat** (exiger ASCII + `-`).
- ID retiré/renommé entre versions de règles → **unknown** (le personnage reste invalide pour ce snapshot).
- La **traduction** (“Humain”, “Togruta”) n’affecte **pas** l’ID.

**Dépendances / dérivés**
- Contribue aux **prérequis** (classes, feats), **caractéristiques de base**, et choix d’**équipement de départ**.
- Lié aux **règles de calcul** (PV/def/traits) via le catalogue (pas dans le VO).

**Tests à prévoir**
- [ ] Accepte un slug valide présent dans le catalogue (ex. `human`).
- [ ] Rejette format invalide (`"Human"`, `"to gru ta"`, `"togrutá"`, `""`).
- [ ] Rejette `unknown` (slug valide mais absent du catalogue).
- [ ] Round-trip JSON/DB conserve `"human"` en minuscules.

---

## 3) ClassId
**Rôle** : Identifiant **typé** d’une classe choisie (référence au catalogue local SW5e)

**Invariants**
- Valeur **non nulle**, **non vide**.
- Format **slug ASCII** : `^[a-z0-9-]{3,40}$` (kebab-case, pas d’espaces/accents).
- **Insensible à la casse** (normaliser en minuscules).
- Doit **exister** dans le **catalogue des classes** packagé pour la **version de règles** figée (snapshot).

**Erreurs à lever**
- `ClassId.invalidFormat` si la chaîne ne matche pas le slug.
- `ClassId.unknown` si l’ID n’est pas présent dans le catalogue de classes.
- `ClassId.nullOrEmpty` si vide après trim/normalisation.

**Mapping data (JSON/DB)**
- **JSON** : `{"classId": "guardian"}` (string **normalisée** en minuscules).
- **DB (Drift)** :
  - Colonne `class_id TEXT NOT NULL`.
  - Clé étrangère recommandée : `FOREIGN KEY (class_id) REFERENCES classes(id)`.
  - Table `classes(id TEXT PRIMARY KEY, …meta)` gérée côté **catalogue** (data layer).

**Cas limites**
- Entrées avec majuscules (`"Guardian"`) → **normalisées** en `"guardian"`.
- Entrées avec diacritiques/espaces (`"guárdian"`, `" guardian "`) → **invalidFormat**.
- ID retiré/renommé entre versions → **unknown** (invalide pour ce snapshot).
- **Archetypes/subclasses** : hors de ce VO ; si requis plus tard, utiliser un **ArchetypeId** séparé.

**Dépendances / dérivés**
- Impacte **dés de vie/HP niveau 1**, **proficiencies de base**, compétences au choix, équipement de départ, et futurs calculs (hors MVP).
- Interagit avec `Level` et le moteur de règles pour les dérivés.

**Tests à prévoir**
- [ ] Accepte un slug valide présent (`guardian`).
- [ ] Rejette format invalide (`"Guardian"`, `"gu ar dian"`, `"guárdian"`, `""`).
- [ ] Rejette `unknown` (slug valide mais absent du catalogue).
- [ ] Round-trip JSON/DB conserve `"guardian"` en minuscules.

---

## 4) BackgroundId
**Rôle** : Identifiant **typé** d’un background choisi (référence au catalogue local SW5e)

**Invariants**
- Valeur **non nulle**, **non vide**.
- Format **slug ASCII** : `^[a-z0-9-]{3,50}$` (kebab-case, pas d’espaces/accents).
- **Insensible à la casse** (normaliser en minuscules).
- Doit **exister** dans le **catalogue des backgrounds** packagé pour la **version de règles** figée (snapshot).

**Erreurs à lever**
- `BackgroundId.invalidFormat` si la chaîne ne respecte pas le slug.
- `BackgroundId.unknown` si l’ID n’existe pas dans le catalogue courant.
- `BackgroundId.nullOrEmpty` si vide après trim/normalisation.

**Mapping data (JSON/DB)**
- **JSON** : `{"backgroundId": "outlaw"}` (string **normalisée** en minuscules).
- **DB (Drift)** :
  - Colonne `background_id TEXT NOT NULL`.
  - Clé étrangère recommandée : `FOREIGN KEY (background_id) REFERENCES backgrounds(id)`.
  - Table `backgrounds(id TEXT PRIMARY KEY, …meta)` gérée côté **catalogue** (data layer).

**Cas limites**
- `"Outlaw"` → **normalisé** en `"outlaw"`.
- `"out law"`, `"outláw"`, `""` → **invalidFormat** / **nullOrEmpty**.
- ID renommé entre versions → **unknown** pour ce snapshot (personnage invalide tant que non migré).

**Dépendances / dérivés**
- Peut octroyer des **proficiencies** (compétences/outils/langues), **équipement de départ**, voire un **feat** selon SW5e.  
- Le **moteur de règles** résout ces effets à partir du **catalogue**, pas dans le VO.

**Tests à prévoir**
- [ ] Accepte un slug valide présent (`outlaw`).
- [ ] Rejette format invalide / vide / inconnu.
- [ ] Round-trip JSON/DB conserve `"outlaw"` en minuscules.

---

## 5) Level
**Rôle** : Niveau de personnage

**Invariants**
- Entier **compris entre 1 et 20** (inclus).  
- **MVP** : doit être **1** (l’UI ne permet pas d’autre valeur ; le VO reste prêt pour 1–20).  
- Pas de décimaux, pas de valeurs négatives, pas de `null`.

**Erreurs à lever**
- `Level.invalidRange` si la valeur < 1 ou > 20.
- `Level.notAnInteger` si la donnée d’entrée n’est pas un entier strict.

**Mapping data (JSON/DB)**
- **JSON** : clé `level: number` (ex. `1`).  
- **DB (Drift)** : colonne `level INTEGER NOT NULL CHECK(level BETWEEN 1 AND 20)`.  
- Migration : si une sauvegarde legacy contient `0` ou `null`, **rejeter** (MVP) et forcer recréation.

**Cas limites**
- **Min** : 1 (valeur par défaut au MVP).  
- **Max** : 20 (future progression).  
- Valeurs invalides (0, -1, 21, `1.0`, `"1"`) → rejet immédiat avec l’erreur adéquate.  
- Sérialisation/désérialisation : toute perte de type (ex. `1.0`) doit être normalisée côté parsing **avant** création du VO ou rejetée.

**Dépendances / dérivés**
- **ProficiencyBonus** dérive de `Level` (MVP : +2 pour `Level=1`).  
- D’éventuels caps de manœuvres/pouvoirs/slots évolueront avec `Level` (hors MVP).

**Tests à prévoir**
- [ ] Accepte 1 ; rejette 0 et 21.  
- [ ] Rejette non-entiers (`1.5`, `"1"` si non parsé).  
- [ ] Sérialisation/DB : round-trip `1` ↔ `1`.

---

## 6) AbilityScore
**Rôle** : Valeur chiffrée d’une caractéristique (ex. Force, Dextérité, Constitution, Intelligence, Sagesse, Charisme)

**Invariants**
- Entier **compris entre 1 et 20** (inclus).  
- **MVP** (niveau 1) : le **cap effectif** est 20 après application des bonus d’espèce/background.  
- Pas de décimaux, pas de négatifs, pas de `null`.  
- Les **règles d’attribution** (array/point-buy/bonus d’espèce) sont **hors VO** et gérées par l’assistant & le moteur de règles.

**Erreurs à lever**
- `AbilityScore.invalidRange` si < 1 ou > 20.  
- `AbilityScore.notAnInteger` si l’entrée n’est pas un entier strict.

**Mapping data (JSON/DB)**
- **JSON** : `{"score": 12}` (nombre entier).  
- **DB (Drift)** : colonne `score INTEGER NOT NULL CHECK (score BETWEEN 1 AND 20)`.  
- Les **noms d’aptitudes** (STR/DEX/CON/INT/WIS/CHA) sont portés par le **catalogue/enum** (ex. `AbilityId`) et **ne font pas partie** de ce VO.

**Cas limites**
- Valeurs limites : 1 (min), 20 (max au MVP).  
- Entrées comme `12.0`, `"12"` : doivent être **parsées** avant la création du VO, sinon rejetées.  
- Bonus temporaires/supranaturels au-delà de 20 : **hors périmètre MVP** (rejeter >20).

**Dépendances / dérivés**
- **AbilityModifier** (dérivé standard) : `floor((score - 10) / 2)` ; ex. 8 → −1, 10 → 0, 12 → +1, 20 → +5.  
- Impacte les jets, la Défense, l’Initiative et d’autres calculs via le moteur de règles.  
- Se combine à un **identifiant d’aptitude** (ex. `AbilityId.STR`) pour former une paire (id, score).

**Tests à prévoir**
- [ ] Accepte 1 et 20 ; rejette 0 et 21.  
- [ ] Rejette non-entiers (`12.3`, `"12"` si non parsé).  
- [ ] Vérifie les modificateurs dérivés : 8→−1, 10→0, 12→+1, 20→+5.  
- [ ] Round-trip JSON/DB conserve la valeur entière.

---

## 7) SkillProficiency
**Rôle** : Maîtrise d’une compétence donnée (état binaire au MVP) avec traçabilité de la/les source(s)

**Invariants**
- Porte **une seule compétence** identifiée par `SkillId` (slug ASCII `^[a-z0-9-]{3,40}$`, existant dans le catalogue).
- **MVP** : état ∈ {`untrained`, `proficient`} (pas d’« expertise » au MVP).
- Si état = `proficient`, alors **au moins une source** ∈ {`class`, `background`, `species`, `feat`, `other`} (ensemble **sans doublons**).
- Immuable (toute modification = nouvel objet).
- Indépendant de la langue (le libellé vient du catalogue, pas du VO).

**Erreurs à lever**
- `SkillProficiency.invalidSkillId` si `SkillId` ne respecte pas le slug ou n’existe pas.
- `SkillProficiency.invalidState` si état ∉ {`untrained`,`proficient`}.
- `SkillProficiency.missingSource` si `proficient` sans source.
- `SkillProficiency.duplicateSources` si sources dupliquées.

**Mapping data (JSON/DB)**
- **JSON** (par entrée) :
    { "skillId": "perception", "state": "proficient", "sources": ["background"] }
- **DB (Drift)** : table d’association personnage ↔ compétences  
  - `character_id TEXT NOT NULL` (FK)  
  - `skill_id TEXT NOT NULL` (FK → `skills.id`)  
  - `state TEXT NOT NULL CHECK (state IN ('untrained','proficient'))`  
  - `sources TEXT NOT NULL` (JSON array normalisée) **ou** table de sources séparée  
  - Clé composée `(character_id, skill_id)`

**Cas limites**
- `skillId` avec majuscules/espaces/diacritiques → **invalidSkillId** (exiger slug ASCII).
- `proficient` mais `sources = []` → **missingSource**.
- `sources = ["class","class"]` → **duplicateSources** (normaliser en set).
- État « expertise » (double maîtrise) : **hors MVP** (rejeter si reçu).

**Dépendances / dérivés**
- Le **ProficiencyBonus** s’applique aux jets des compétences maîtrisées.
- Les sources proviennent de `speciesId`, `classId`, `backgroundId`, `feat` (résolus via le catalogue).

**Tests à prévoir**
- [ ] Accepte : (`perception`, `proficient`, `["background"]`).
- [ ] Rejette : skill inexistant/slug invalide ; état invalide ; `proficient` sans source ; sources dupliquées.
- [ ] Round-trip JSON/DB conserve `skillId`, `state` et l’ensemble `sources` (ordre non significatif).

---

## 8) ProficiencyBonus
**Rôle** : Bonus de maîtrise global du personnage (s’applique aux jets maîtrisés)

**Invariants**
- Entier **compris entre +2 et +6**.
- **MVP (Level = 1)** : **+2**.
- Dérivé de `Level` selon la table standard :
  - Niveaux **1–4** → **+2**
  - **5–8** → **+3**
  - **9–12** → **+4**
  - **13–16** → **+5**
  - **17–20** → **+6**
- Pas de décimaux, pas de valeurs négatives, pas de `null`.

**Erreurs à lever**
- `ProficiencyBonus.invalidRange` si la valeur n’est pas dans [2..6].
- `ProficiencyBonus.inconsistentWithLevel` si une fabrique qui prend `Level` reçoit une valeur non cohérente (ex. Level 1 → valeur ≠ 2).
- `ProficiencyBonus.notAnInteger` si l’entrée n’est pas un entier strict.

**Mapping data (JSON/DB)**
- **Recommandation** : **ne pas persister** séparément si `Level` est stocké (le bonus est recalculable).
- Si persistance requise :
  - **JSON** : `{"proficiencyBonus": 2}`
  - **DB (Drift)** : `proficiency_bonus INTEGER NOT NULL CHECK (proficiency_bonus BETWEEN 2 AND 6)`
  - Validator au chargement : vérifier la cohérence avec `Level` et **recalculer** si besoin.

**Cas limites**
- **Level = 1** ⇒ **+2** (MVP).
- Valeurs hors bornes (`1`, `7`, `0`, `-2`) → **invalidRange**.
- Incohérence `Level=1` & `proficiencyBonus=3` → **inconsistentWithLevel** (si on stocke).

**Dépendances / dérivés**
- Dérive de `Level`.
- Utilisé par `SkillProficiency` (jets maîtrisés), jets d’armes/outils maîtrisés, DD de certaines capacités.

**Tests à prévoir**
- [ ] Fabrique `fromLevel(1)` retourne **+2**.
- [ ] Valide la table 1–20 → {2,3,4,5,6} selon les paliers.
- [ ] Rejette 1 et 7 (invalidRange).
- [ ] (Si persistance) détecte et corrige une incohérence avec `Level`.

---

## 9) HitPoints
**Rôle** : Points de vie **maximum** du personnage (valeur de référence ; les PV courants relèvent de l’état de jeu, pas du VO de création)

**Invariants**
- Entier **≥ 1** (jamais 0 ou négatif).
- **MVP (niveau 1)** : valeur issue du moteur de règles (classe/die de vie + mod. de Constitution + éventuels modificateurs de traits), mais **le VO ne recalcule pas** : il **valide et transporte** une valeur déjà calculée.
- Pas de décimaux, pas de `null`.
- Optionnel : borne supérieure raisonnable (ex. **≤ 300**) pour éviter les corruptions (à ajuster si besoin).

**Erreurs à lever**
- `HitPoints.invalidRange` si < 1 (ou > max autorisé si borne haute activée).
- `HitPoints.notAnInteger` si l’entrée n’est pas un entier strict.

**Mapping data (JSON/DB)**
- **JSON** : `{"hitPoints": 12}` (entier).
- **DB (Drift)** : colonne `hit_points INTEGER NOT NULL CHECK (hit_points >= 1)`.
  - Recommandation : stocker **uniquement** les PV **max** ici côté personnage créé ; les PV **courants/temporairement modifiés** appartiennent à un autre contexte (jeu, non MVP).

**Cas limites**
- Constitution négative qui ferait descendre en-dessous de 1 au niveau 1 : la **valeur fournie par le moteur** doit **respecter min = 1** (règle de base). Si on reçoit `0` ⇒ **invalidRange**.
- Valeurs très élevées (erreur de calcul/catalogue) ⇒ rejet si borne haute activée.
- Sérialisation/désérialisation : pas de conversion flottante (`12.0` rejeté si non parsé).

**Dépendances / dérivés**
- **Dérive** de : `ClassId` (dé de vie), modificateur de **Constitution**, et éventuels traits/équipement/feats applicables au **niveau 1**.
- Ne dépend **pas directement** de `Level` au MVP (figé à 1), mais sera recalculé par la progression plus tard.

**Tests à prévoir**
- [ ] Accepte une valeur valide ≥ 1 (ex. 10, 12).
- [ ] Rejette 0 et négatifs (invalidRange).
- [ ] Rejette non-entiers (`"12"`, `12.5` si non parsé).
- [ ] Round-trip JSON/DB conserve l’entier attendu.

---

## 10) Defense
**Rôle** : Valeur de défense (équivalent « Armor Class ») affichée sur la fiche

**Invariants**
- Entier **strictement positif**.
- **MVP** : le moteur de règles calcule la valeur (non recalculée par ce VO).  
- Recommandation de borne de sécurité : **entre 5 et 35** (évite des corruptions de données).  
- Pas de décimaux, pas de `null`.

**Erreurs à lever**
- `Defense.invalidRange` si la valeur < 5 (ou > 35 si borne activée).
- `Defense.notAnInteger` si l’entrée n’est pas un entier strict.

**Mapping data (JSON/DB)**
- **JSON** : `{"defense": 15}`
- **DB (Drift)** : `defense INTEGER NOT NULL CHECK (defense >= 5 AND defense <= 35)`

**Cas limites**
- Formule « sans armure » qui tomberait sous 10 à cause d’un mod négatif : le **moteur** doit déjà **appliquer la règle** (plancher/bonus) — si on reçoit `<5` ⇒ **invalidRange**.
- Valeurs anormalement hautes (ex. >35) ⇒ rejet (soupçon d’erreur de calcul ou de données).
- Sérialisation : rejeter `15.0` ou `"15"` si non parsé en entier avant création.

**Dépendances / dérivés**
- Dépend de l’**armure/équipement**, du **modificateur d’aptitude** pertinent, d’un **bouclier**, et de traits/feats/classe **applicables au niveau 1** (calculés par le moteur).

**Tests à prévoir**
- [ ] Accepte des valeurs plausibles (ex. 10, 12, 15).
- [ ] Rejette 0, 4, et 36 (invalidRange).
- [ ] Rejette non-entiers (`"15"`, `15.5` si non parsé).
- [ ] Round-trip JSON/DB conserve l’entier attendu.

---

## 11) Initiative
**Rôle** : Bonus d’initiative du personnage (le **modificateur** ajouté au d20, pas le jet lui-même)

**Invariants**
- Entier (peut être **négatif**, nul ou positif).
- **MVP** : valeur **calculée par le moteur** (souvent = mod. de Dextérité + bonus divers) ; le VO **valide/porte** la valeur.
- Garde-fou recommandé : **entre −10 et +20** (évite corruptions) — ajustable si besoin.
- Pas de décimaux, pas de `null`.

**Erreurs à lever**
- `Initiative.invalidRange` si la valeur est hors des bornes retenues.
- `Initiative.notAnInteger` si l’entrée n’est pas un entier strict.

**Mapping data (JSON/DB)**
- **JSON** : `{ "initiative": 2 }` (entier ; peut être négatif).
- **DB (Drift)** : `initiative INTEGER NOT NULL CHECK (initiative BETWEEN -10 AND 20)`

**Cas limites**
- Mod. DEX négatif (ex. −1) ⇒ **autorisé**.
- Bonus situationnels non persistés au MVP (objets temporaires, effets) : **hors périmètre** — seule la **valeur de base** calculée est stockée.
- Rejeter `2.0` / `"2"` si non parsé avant création.

**Dépendances / dérivés**
- Dépend du **modificateur de Dextérité** (AbilityScore→modifier) + éventuels traits/feats/équipement applicables **au niveau 1** (calcul côté moteur).

**Tests à prévoir**
- [ ] Accepte des valeurs plausibles : −1, 0, +2, +5.
- [ ] Rejette hors bornes (ex. −11, +21) → `invalidRange`.
- [ ] Rejette non-entiers (`"2"`, `1.5`) → `notAnInteger`.
- [ ] Round-trip JSON/DB conserve l’entier (y compris négatif).

---

## 12) Credits
**Rôle** : Monnaie disponible pour l’équipement de départ et les achats (unité : crédit)

**Invariants**
- Entier **≥ 0** (zéro autorisé).
- **Pas de décimaux** (les prix SW5e sont exprimés en crédits entiers au MVP).
- Garde-fou recommandé : **≤ 1_000_000** pour éviter les corruptions (ajustable).
- Immuable, non `null`.

**Erreurs à lever**
- `Credits.invalidRange` si < 0 (ou > borne haute si activée).
- `Credits.notAnInteger` si l’entrée n’est pas un entier strict.

**Mapping data (JSON/DB)**
- **JSON** : `{ "credits": 150 }`
- **DB (Drift)** : `credits INTEGER NOT NULL CHECK (credits >= 0)`  
  - Option : ajouter `AND credits <= 1000000` si tu fixes une borne.

**Cas limites**
- Valeurs négatives (`-1`) → **invalidRange**.
- Très grandes valeurs → rejet si > borne.
- Entrées `150.0` / `"150"` → doivent être **parsées** avant création, sinon rejetées.

**Dépendances / dérivés**
- Contrôle des **achats** d’équipement de départ (budget), **rendu** ou **reste** après achats.
- Le moteur de règles et l’assistant gèrent les prix, remises, échanges.

**Tests à prévoir**
- [ ] Accepte `0`, `1`, `150`.
- [ ] Rejette `-1` (invalidRange).
- [ ] Rejette non-entiers (`"150"`, `12.5`) → `notAnInteger`.
- [ ] Round-trip JSON/DB conserve l’entier attendu.

---

## 13) EquipmentItemId
**Rôle** : Identifiant **typé** d’un objet d’équipement (référence au catalogue local SW5e)

**Invariants**
- Valeur **non nulle**, **non vide**.
- Format **slug ASCII** : `^[a-z0-9-]{3,60}$` (kebab-case, pas d’espaces/accents).
- **Insensible à la casse** (normaliser en **minuscules**).
- Doit **exister** dans le **catalogue d’équipement** packagé pour la **version de règles (snapshot)**.
- Ne contient **pas** la traduction (libellé i18n géré côté catalogue/UI).

**Erreurs à lever**
- `EquipmentItemId.invalidFormat` si la chaîne ne respecte pas le slug.
- `EquipmentItemId.unknown` si l’ID n’existe pas dans le catalogue courant.
- `EquipmentItemId.nullOrEmpty` si vide après trim/normalisation.

**Mapping data (JSON/DB)**
- **JSON** : `{ "equipmentItemId": "vibroblade" }`
- **DB (Drift)** :
  - Colonne `equipment_item_id TEXT NOT NULL`
  - **FK** recommandée : `FOREIGN KEY (equipment_item_id) REFERENCES equipment(id)`
  - Table `equipment(id TEXT PRIMARY KEY, type TEXT, weight REAL/INTEGER, cost INTEGER, …)` maintenue par la **data layer** (catalogue), pas par le domaine.

**Cas limites**
- Majuscules/espaces/diacritiques (`"VibroBlade"`, `" vibro blade "`, `"vibróblade"`) → **invalidFormat** (exiger ASCII + `-`).
- ID renommé/supprimé entre versions de règles → **unknown** pour ce snapshot (le build devient invalide tant que n

---

## 14) Quantity
**Rôle** : Quantité d’un objet d’équipement (ligne d’inventaire ou sélection dans l’assistant)

**Invariants**
- Entier **≥ 0** (zéro autorisé pour représenter un choix non retenu en cours d’assistant).
- Recommandation de borne haute : **≤ 9 999** (évite les corruptions / overflows).
- Pas de décimaux, pas de `null`.

**Erreurs à lever**
- `Quantity.invalidRange` si < 0 (ou > 9 999 si borne activée).
- `Quantity.notAnInteger` si l’entrée n’est pas un entier strict.

**Mapping data (JSON/DB)**
- **JSON** : `{ "quantity": 3 }`
- **DB (Drift)** : `quantity INTEGER NOT NULL CHECK (quantity >= 0 AND quantity <= 9999)`

**Cas limites**
- `0` : **autorisé** pour l’étape de configuration ; idéalement **non persisté** en inventaire final (filtré par la couche data/ UI).
- Très grandes valeurs (p. ex. `100 000`) → rejet (borne).
- Entrées `"3"` / `3.0` → doivent être **parsées** avant création, sinon rejetées.

**Dépendances / dérivés**
- S’emploie avec `EquipmentItemId` pour former une ligne d’inventaire.
- Contribue aux calculs d’**encumbrance** et de **coût total** (faits par le moteur/catalogue).

**Tests à prévoir**
- [ ] Accepte `0`, `1`, `7`.
- [ ] Rejette `-1` et `10 000` (invalidRange).
- [ ] Rejette non-entiers (`"2"`, `1.5`) → `notAnInteger`.
- [ ] Round-trip JSON/DB conserve l’entier attendu.

---

## 15) Encumbrance
**Rôle** : Poids/encombrement **normalisé** porté (valeur chiffrée unique utilisée par le moteur pour vérifier les limites)

**Invariants**
- Unité **normalisée** : **grammes** (entier).  
  > On évite les flottants : toutes les conversions (depuis lb/kg) sont faites **avant** la création du VO.
- Valeur **≥ 0** (zéro autorisé).  
- Garde-fou recommandé : **≤ 1_000_000 g** (1 000 kg) pour éviter les corruptions (ajuster si besoin).
- Immuable, pas de `null`.

**Erreurs à lever**
- `Encumbrance.invalidRange` si < 0 (ou > borne haute si activée).
- `Encumbrance.notAnInteger` si l’entrée n’est pas un entier strict (ex. `12.5` g).

**Conversions (hors VO, côté moteur/catalogue/UI)**
- **lb → g** : `round(lb * 453.59237)`  
- **kg → g** : `round(kg * 1000)`  
- Arrondir au **gramme le plus proche** avant création du VO.

**Mapping data (JSON/DB)**
- **JSON** : `{ "encumbrance_g": 3250 }`  (toujours en **grammes**)
- **DB (Drift)** : `encumbrance_g INTEGER NOT NULL CHECK (encumbrance_g >= 0 AND encumbrance_g <= 1000000)`

**Cas limites**
- Valeurs non entières en entrée (ex. résultat de conversion) → **arrondir** avant de créer le VO ; si non arrondi, **notAnInteger**.
- Sommes de poids de plusieurs items : faire l’addition **en grammes** pour éviter les erreurs d’arrondi.
- Valeurs très élevées (ex. > 1_000_000 g) → **invalidRange** (soupçon de corruption/calcul erroné).

**Dépendances / dérivés**
- Utilisé par le moteur pour valider **capacité de port**, **malus d’encombrement**, et certains choix d’équipement.
- Dérive de la somme `Σ (poids_unitaire_g × quantity)` des items équipés/portés (calcul **hors VO**).

**Tests à prévoir**
- [ ] Accepte `0`, `500`, `3250`.
- [ ] Rejette `-1` et `1_000_001` → `invalidRange`.
- [ ] Rejette non-entiers (`12.5`) → `notAnInteger`.
- [ ] Conversions : `1 lb` → `454 g` (arrondi), `2.5 kg` → `2500 g`.
- [ ] Addition de plusieurs items : somme exacte en grammes.

---

## 16) ManeuversKnown
**Rôle** : Nombre de manœuvres **connues** au niveau actuel (MVP : niveau 1)

**Invariants**
- Entier **≥ 0** (zéro si la classe/archétype n’en accorde pas au niveau 1).
- Borne haute de sécurité recommandée : **≤ 20** (ajuster si besoin).
- **Calculé par le moteur** à partir de `ClassId` (+ archetype s’il y a lieu) et du **snapshot de règles** ; le VO ne recalcule pas.

**Erreurs à lever**
- `ManeuversKnown.invalidRange` si < 0 (ou > borne haute si activée).
- `ManeuversKnown.notAnInteger` si l’entrée n’est pas un entier strict.

**Mapping data (JSON/DB)**
- **JSON** : `{ "maneuversKnown": 0 }`
- **DB (Drift)** : `maneuvers_known INTEGER NOT NULL CHECK (maneuvers_known >= 0 AND maneuvers_known <= 20)`

**Cas limites**
- Classe sans manœuvres au niveau 1 → **0**.
- Changements de règles/version : la valeur doit provenir du **catalogue** correspondant au snapshot ; si incohérence détectée, **rejeter** la valeur et recalculer côté moteur.

**Dépendances / dérivés**
- Dépend de `ClassId` (+ archetype) et du **tableau de progression** des manœuvres.
- Distinct de la **liste** des manœuvres apprises (qui serait une collection de `ManeuverId` — **hors MVP** si on ne gère que le **nombre**).

**Tests à prévoir**
- [ ] Accepte `0` et petites valeurs plausibles (ex. `3` si règles l’accordent au niveau 1).
- [ ] Rejette `-1` et valeurs > 20 → `invalidRange`.
- [ ] Rejette non-entiers (`"2"`, `1.5`) → `notAnInteger`.
- [ ] Round-trip JSON/DB cons

---

## 17) SuperiorityDice
**Rôle** : Pool de dés de supériorité pour utiliser des manœuvres (taille du pool + face du dé)

**Invariants**
- `count` (taille du pool) : entier **≥ 0**.  
  - **0** autorisé si la classe/archétype n’en fournit pas au niveau 1.
  - Borne haute de sécurité recommandée : **≤ 12** (ajuster si besoin).
- `die` (face du dé) : valeur **dans un ensemble autorisé** (ex. {4,6,8,10,12}).  
  - **Si `count` > 0** ⇒ `die` **doit** être présent et **valide**.  
  - **Si `count` = 0** ⇒ `die` peut être `null` (ou absent).
- **MVP** : la combinaison (`count`, `die`) est **calculée par le moteur** à partir de `ClassId` (+ archetype) et du **snapshot de règles** ; le VO **ne recalcule pas**.
- Immuable ; pas de `null` pour `count`.

**Erreurs à lever**
- `SuperiorityDice.invalidCount` si `count` < 0 (ou > borne haute si activée).
- `SuperiorityDice.invalidDie` si `die` n’appartient pas à l’ensemble autorisé.
- `SuperiorityDice.missingDie` si `count` > 0 mais `die` manquant.
- `SuperiorityDice.dieWithoutCount` si `die` est fourni alors que `count` = 0 (optionnel selon design).

**Mapping data (JSON/DB)**
- **JSON** :  
  - Avec dés : `{ "superiorityDice": { "count": 3, "die": 8 } }`  // ⇒ 3d8  
  - Sans dés : `{ "superiorityDice": { "count": 0 } }`
- **DB (Drift)** : colonnes sur la table `characters` (ou table dédiée)  
  - `superiority_dice_count INTEGER NOT NULL CHECK (superiority_dice_count >= 0 AND superiority_dice_count <= 12)`  
  - `superiority_die INTEGER NULL CHECK (superiority_die IN (4,6,8,10,12))`  
  - **Contrôle applicatif** : si `superiority_dice_count > 0` alors `superiority_die IS NOT NULL`.

**Cas limites**
- Classe sans manœuvres au niveau 1 : `count = 0`, `die = null`.  
- Règles modifiées entre versions : la valeur doit venir du **catalogue** du snapshot courant ; incohérence ⇒ rejet côté moteur avant création du VO.  
- Valeurs flottantes (`3.0`), chaînes (`"8"`) ⇒ **parsage** requis **avant** création, sinon rejet.

**Dépendances / dérivés**
- Dépend de `ClassId` (+ archetype) et du tableau de progression des **manœuvres**.  
- Distinct de `ManeuversKnown` (nombre de manœuvres apprises).

**Tests à prévoir**
- [ ] Accepte `{count: 0}` et `{count: 3, die: 8}`.  
- [ ] Rejette `count < 0`, `count > 12`.  
- [ ] Rejette `die` hors {4,6,8,10,12}.  
- [ ] Rejette `count > 0` avec `die` manquant.  
- [ ] Round-trip JSON/DB conserve `{count, die}` (avec `die = null` quand `count = 0`).

---





Vieil exemple
## 13) HitPoints (PV)
**Rôle** : Points de vie  
**Invariants** :  
**Erreurs à lever** :  
**Mapping data (JSON/DB)** :  
**Cas limites** :