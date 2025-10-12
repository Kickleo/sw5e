import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sw5e_manager/ui/character_creation/pages/saved_characters_page.dart';

/// Page d'accueil offrant les principales entrées de l'application.
///
/// L'objectif est de proposer un point de départ clair pour l'utilisateur en
/// lui présentant les deux actions disponibles à ce stade du projet :
///
/// * démarrer la création d'un nouveau personnage ;
/// * consulter la liste des personnages déjà enregistrés.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SW5e Manager'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bienvenue dans SW5e Manager',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Gérez vos héros : créez-en un nouveau ou ouvrez une fiche existante.",
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                FilledButton.icon(
                  onPressed: () => context.go('/create'),
                  icon: const Icon(Icons.bolt),
                  label: const Text('Créer un nouveau personnage'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.goNamed(SavedCharactersPage.routeName),
                  icon: const Icon(Icons.folder_shared),
                  label: const Text('Charger une fiche existante'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
