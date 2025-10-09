# Workflow Git pour appliquer les changements sur une nouvelle branche

Ce guide résume les commandes nécessaires pour reprendre un développement existant et le reporter sur une nouvelle branche Git locale.

## 1. Vérifier la branche actuelle
```bash
git status -sb
```
Cela permet de vérifier sur quelle branche vous vous trouvez et si l'arbre de travail contient des modifications en cours.

## 2. Créer et basculer sur la nouvelle branche
Si vous partez de la branche `work` actuelle :
```bash
git switch work              # optionnel si vous êtes déjà dessus
git switch -c feature/nouvelle-branche
```
L'option `-c` crée la nouvelle branche et bascule directement dessus.

## 3. Rejouer les commits nécessaires
Si les changements sont déjà commités sur la branche `work`, deux options principales existent :

### Option A — Recréer les commits avec `cherry-pick`
```bash
git cherry-pick <sha_du_commit_a_reprendre>
```
Répétez la commande pour chaque commit que vous souhaitez copier. Résolvez les conflits éventuels puis validez avec `git cherry-pick --continue`.

### Option B — Repartir de l'état courant
Si vous souhaitez prendre l'état actuel du répertoire de travail et en faire un nouveau commit :
```bash
git commit -am "Message descriptif"
```

## 4. Vérifier l'historique de la nouvelle branche
```bash
git log --oneline
```
Contrôlez que les commits attendus sont bien présents dans la nouvelle branche.

## 5. Pousser la branche vers le dépôt distant
```bash
git push -u origin feature/nouvelle-branche
```
L'option `-u` configure le suivi entre la branche locale et distante pour les futures synchronisations (`git push` / `git pull`).

## 6. Créer la Pull Request
Utilisez l'interface de votre forge (GitHub, GitLab, etc.) pour ouvrir une Pull Request depuis `feature/nouvelle-branche` vers la branche de destination (par exemple `main`).

> 💡 Astuce : si vous devez appliquer plusieurs commits d'affilée (par exemple toute une série de correctifs), vous pouvez utiliser `git cherry-pick <premier_sha>^..<dernier_sha>` pour tous les récupérer en une seule commande.

