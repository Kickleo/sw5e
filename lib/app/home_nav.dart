/// ---------------------------------------------------------------------------
/// Fichier : lib/app/home_nav.dart
/// Rôle : Gérer la navigation par onglets principale (création rapide / résumé).
/// Dépendances : Widgets Flutter, vues UI du module de création de personnage.
/// Exemple d'usage : embarqué dans Sw5eApp comme scaffold principal.
/// ---------------------------------------------------------------------------
library;
import 'package:flutter/material.dart';
import 'package:sw5e_manager/ui/character_creation/pages/character_summary_page.dart';
import 'package:sw5e_manager/ui/character_creation/pages/quick_create_page.dart';

/// HomeNav = widget principal affichant un [NavigationBar] pour basculer
/// entre les différentes pages de création de personnage.
class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  // Index de l'onglet actuellement sélectionné dans la barre inférieure.
  int _index = 0;

  // Tableau immuable des pages affichées dans les différents onglets.
  static const _pages = <Widget>[
    QuickCreatePage(),
    CharacterSummaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Le Scaffold fournit une structure de base avec un corps dynamique et
    // une barre de navigation inférieure pilotant le changement de page.
    return Scaffold(
      body: _pages[_index], // Affiche la page correspondant à l'index actif.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index, // Synchronise l'état sélectionné visuellement.
        onDestinationSelected: (i) =>
            setState(() => _index = i), // Met à jour l'index et rafraîchit l'UI.
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: 'Créer',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Résumé',
          ),
        ],
      ),
    );
  }
}
