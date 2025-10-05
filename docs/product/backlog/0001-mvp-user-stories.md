# Backlog — MVP (User Stories)

## Contexte MVP
- **Objectif principal** : Au MVP, l’application doit permettre à un joueur de créer un personnage de niveau 1 prêt à jouer (caractéristiques, compétences, équipement de base) afin de jouer une partie de JDR Star Wars autour d’une table, sur téléphone (Android/iOS), y compris hors ligne et sans connaissance préalable du système de jeu.

- **Périmètre inclus** :
    - Créer un personnage de niveau 1 via un assistant pas-à-pas (choix d’espèce, carrière/archétype, compétences de base).
    - Calculer automatiquement les valeurs dérivées (PV, défense, initiative, portées/charges simples) selon les choix.
    - Proposer un équipement de départ conforme aux règles et permettre quelques ajustements (échanges simples).
    - Sauvegarder/charger localement (hors ligne) un personnage — un seul personnage suffit pour le MVP.
    - Afficher une fiche personnage “prête à jouer” claire et responsive (mobile/desktop).
    - Gérer les validations de base (prérequis, points à répartir, champs obligatoires) avec messages compréhensibles.

- **Hors périmètre** (plus tard) :
    - Multi-personnages (plus d’un perso) et gestion de profils.
    - Montée de niveau au-delà du niveau 1 (progression complète, respec).
    - Pouvoirs/attaques avancés (synergies, conditions, effets complexes).
    - Synchronisation cloud / comptes et partage entre appareils.
    - Export PDF / impression et import/export de builds.
    - Automatisation des combats / jets de dés (simulateur).
    - Ajout de règles, objets, pouvoirs, personnages personnalisés.

---

## Story 1 — Création d’un personnage niveau 1 (assistant)
**En tant que** joueur (y compris débutant),
**Je veux** créer un personnage de niveau 1 via un assistant pas-à-pas,
**Afin de** disposer d’une fiche prête à jouer immédiatement.

### Critères d’acceptation (testables)
- [ ] Étant donné l’ouverture de l’app, **Quand** je lance l’assistant, **Alors** je vois les étapes : espèce → carrière/archétype → répartition de points/compétences → équipement de départ → récapitulatif.
- [ ] **Quand** un choix viole une règle (prérequis/points restants), **Alors** je vois un message clair et je ne peux pas continuer tant que l’erreur n’est pas corrigée.
- [ ] **Quand** je valide l’assistant, **Alors** les valeurs dérivées sont **calculées automatiquement** (PV, défense, initiative, charges/portées simples).
- [ ] **Quand** je termine, **Alors** une **fiche personnage** s’affiche avec tous les champs nécessaires “prêts à jouer”.
- [ ] **Quand** je sauvegarde, **Alors** le personnage est **stocké localement** et je peux **le recharger** hors ligne.
- [ ] **Quand** je suis hors connexion, **Alors** l’assistant et la fiche restent utilisables (sans ressources réseau).


### Notes métier / contraintes

**Règles**
- Budget de points à répartir (caractéristiques/compétences) et plafonds par étape.
- Prérequis : espèce ↔ carrière/archétype, caractéristiques minimales pour certaines options.
- Calculs dérivés déterministes : PV, défense, initiative, charges/portées (règles de priorités/arrondis explicites).
- Équipement de départ : packs conformes + échanges limités, respect du poids/slots et du budget.
- Version des règles (v1) attachée au personnage pour compatibilité future.
- Assistant linéaire avec retour possible à l’étape précédente (sans perdre les choix).

**Données nécessaires**
- Catalogues locaux : espèces, carrières/archétypes, compétences, caractéristiques de base.
- Équipements : nom, catégorie, coût, poids/volume, contraintes d’usage.
- Tables/formules pour valeurs dérivées (PV, défense, initiative, charges/portées).
- Messages d’erreur/validation (i18n) clairs et actionnables.
- Métadonnées de persistance : version de schéma, version des règles.

**Erreurs à gérer**
- Prérequis non remplis / budget de points insuffisant.
- Surcapacité (poids/slots) ou équipement incompatible.
- Données de règles manquantes/corrompues (fallback et message).
- Incompatibilité de version (règles ↔ personnage) — bloquer ou migrer plus tard.
- Sauvegarde locale échouée (espace/permission) avec message explicite.
- Reprise après interruption de l’assistant (état restauré ou relance propre).

---

## Story 2 — Sauvegarder / Charger localement (hors ligne)

**En tant que** joueur,  
**Je veux** sauvegarder et recharger mon personnage localement,  
**Afin de** pouvoir jouer hors ligne et reprendre plus tard.

### Critères d’acceptation (testables)
- [ ] Étant donné un personnage valide, **Quand** je choisis “Sauvegarder”, **Alors** les données sont persistées en local et datées.
- [ ] **Quand** j’ouvre l’app sans réseau, **Alors** je peux “Charger” le dernier personnage sauvegardé.
- [ ] **Quand** aucune sauvegarde n’existe, **Alors** l’option “Charger” est désactivée ou affiche un message explicite.
- [ ] **Quand** une sauvegarde est corrompue/incompatible, **Alors** un message clair s’affiche et je peux relancer la création.
- [ ] **Quand** une nouvelle sauvegarde est créée, **Alors** elle remplace l’ancienne (une seule sauvegarde au MVP).

### Notes / Contraintes
**Règles**
- Une seule sauvegarde active (MVP) ; écrasement contrôlé.
- Version de schéma + version des règles stockées avec la sauvegarde.

**Données nécessaires**
- Snapshot complet du personnage (y compris méta : versions, timestamp).
- Espace disque disponible minimal (message si échec).

**Erreurs à gérer**
- Échec d’écriture/lecture (permissions/espace).
- Données invalides/corrompues.
- Incompatibilité de versions (schéma/règles) → message + contournement (recréer).

---

## Story 3 — Fiche personnage “prête à jouer” (responsive & accessible)

**En tant que** joueur,  
**Je veux** consulter une fiche personnage claire et lisible,  
**Afin de** pouvoir jouer immédiatement autour d’une table, même hors ligne.

### Critères d’acceptation (testables)
- [ ] **Quand** je termine l’assistant ou charge une sauvegarde valide, **Alors** j’accède à une fiche affichant : nom, espèce, carrière/archétype, caractéristiques, compétences clés, PV, défense, initiative, équipement de départ.
- [ ] **Quand** l’écran est petit (téléphone), **Alors** la fiche reste lisible (mise en page en sections/onglets ou accordéons).
- [ ] **Quand** l’écran est large (tablette/desktop), **Alors** les informations principales sont visibles **sans défilement** vertical excessif (mise en colonnes).
- [ ] **Quand** je suis hors ligne, **Alors** la fiche s’affiche sans dépendance réseau.
- [ ] **Quand** des données obligatoires manquent/corrompues, **Alors** un message explicite s’affiche avec une action pour relancer la création ou recharger.
- [ ] **Quand** j’appuie sur “Modifier”, **Alors** je reviens à l’assistant en conservant les choix déjà faits.

### Notes / Contraintes
**Règles**
- Lecture seule au MVP (édition via l’assistant seulement).
- Les valeurs dérivées affichées doivent **correspondre exactement** aux règles v1.

**Données nécessaires**
- Données consolidées du personnage (y compris valeurs dérivées).
- Messages d’erreur/indicateurs d’état (hors-ligne, données incomplètes).

**Erreurs à gérer**
- Données incomplètes/incompatibles → message + action de reprise (assistant ou chargement).
- Problèmes d’affichage (troncation) sur petits écrans → mise en page alternative.

---

## Story 4
**En tant que** …  
**Je veux** …  
**Afin de** …

### Critères d’acceptation (testables)
- [ ] Étant donné … Quand … Alors …
- [ ] Étant donné … Quand … Alors …

### Notes métier / contraintes
- Règles :
- Données nécessaires :
- Erreurs à gérer :

---

## Definition of Ready (DoR)
- [ ] Story claire, valeur utilisateur identifiée
- [ ] Critères d’acceptation complets et testables
- [ ] Dépendances connues
- [ ] Taille raisonnable (≤ 2 jours)

## Definition of Done (DoD)
- [ ] Tests unitaires/Bloc/Widget verts (TDD)
- [ ] Analyse/lints OK
- [ ] Docs/ADR mises à jour si décision impactée
- [ ] UI accessible/responsive (au niveau MVP)
