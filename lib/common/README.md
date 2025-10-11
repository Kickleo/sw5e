<!--
Fichier : lib/common/README.md
Rôle : Documenter la couche Common partagée et ses conventions.
Dépendances : S'appuie sur les utilitaires transverses décrits dans ce dossier.
Exemple d'usage : Lire avant d'ajouter une nouvelle utilité partagée.
-->

# Common Layer

La couche **Common** agrège les utilitaires transverses (configuration, journalisation, résultats) partagés par toutes les autres couches.

```
+-------------------+
|    Presentation   |
+---------+---------+
          |
+---------v---------+
|      Common       |
+----+----------+---+
     |          |
  Config    Logging
```

## Contenu actuel
- `config/` : Chargement des variables d'environnement et exposition typée.
- `errors/` : Politique d'erreurs `AppFailure` et messages par défaut.
- `logging/` : Interfaces et implémentations de journalisation normalisées.
- `result/` : Alias `AppResult` sur `Result` pour homogénéiser le code.

## Lignes directrices
1. Toute utilité doit être documentée (en-tête + exemples).
2. Les dépendances externes doivent être expliquées et encapsulées via interfaces.
3. Pas de logique métier ici : uniquement du transversal réutilisable.

