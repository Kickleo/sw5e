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

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _index = 0;

  static const _pages = <Widget>[
    QuickCreatePage(),
    CharacterSummaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
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
