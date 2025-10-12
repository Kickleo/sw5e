/// Navigation principale entre l'assistant rapide et le résumé.
library;
import 'package:flutter/material.dart';
import 'package:sw5e_manager/ui/character_creation/pages/character_summary_page.dart';
import 'package:sw5e_manager/ui/character_creation/pages/quick_create/quick_create_page.dart';

/// Affiche un [Scaffold] avec barre de navigation inférieure permettant de
/// basculer entre l'assistant de création rapide et la page de résumé.
/// L'objectif est de proposer deux espaces complémentaires :
///
/// 1. l'onglet « Créer » consomme l'assistant guidé ;
/// 2. l'onglet « Résumé » permettra d'exposer la fiche du personnage une fois la
///    finalisation terminée.
class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _index = 0;

  // L'ordre de cette liste doit rester synchronisé avec les destinations de la
  // barre de navigation : la position 0 correspond à l'assistant, la position 1
  // au résumé. On conserve des widgets const pour éviter de recréer
  // systématiquement les sous-arbres quand l'utilisateur navigue.
  static const List<Widget> _pages = <Widget>[
    QuickCreatePage(),
    CharacterSummaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Le contenu principal affiche la page correspondant à l'onglet courant.
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        // Un simple `setState` suffit : seul l'index change, les sous-pages
        // étant conservées dans la liste statique ci-dessus.
        onDestinationSelected: (int i) => setState(() => _index = i),
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
