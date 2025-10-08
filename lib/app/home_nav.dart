import 'package:flutter/material.dart';
import 'package:sw5e_manager/features/character_creation/presentation/pages/last_character_page.dart';
import 'package:sw5e_manager/features/character_creation/presentation/pages/quick_create_page.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _index = 0;

  static const _pages = <Widget>[
    QuickCreatePage(),
    LastCharacterPage(),
  ];

  static const _titles = <String>[
    'Quick Create',
    'Dernier personnage',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
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
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Dernier',
          ),
        ],
      ),
    );
  }
}
