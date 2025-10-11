<!--
Fichier : lib/data/characters/README.md
Rôle : Documenter les adaptateurs de persistance des personnages.
Dépendances : Domaine personnages pour les contrats, `lib/common` pour logger/Result.
Exemple d'usage : Consulter pour comprendre où implémenter un nouveau repository.
-->

# Data · Characters

Ce dossier héberge les adaptateurs de persistance pour les personnages.

```
lib/data/characters
├── README.md              (ce document)
└── repositories/          (implémentations concrètes des `CharacterRepository`)
```

## Principes
- **Ports/Adapters** : le domaine expose `CharacterRepository`, ce dossier fournit ses implémentations.
- **Inversion de dépendances** : aucun import depuis l'UI/Presentation pour permettre le test isolé.
- **Documenté et testé** : chaque repository possède un en-tête, des docstrings et des tests d'intégration ciblés.

## Tests
- Unitaires : scénarios in-memory.
- Persistance fichier : `PersistentCharacterRepository` couvert par des tests
  écrivant dans un répertoire temporaire.

