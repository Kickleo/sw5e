import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw5e_manager/app/home_nav.dart';
import 'package:sw5e_manager/features/character_creation/presentation/pages/class_picker_page.dart';
import 'package:sw5e_manager/features/character_creation/presentation/pages/saved_characters_page.dart';
import 'package:sw5e_manager/features/character_creation/presentation/pages/species_picker.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeNav(),
        routes: [
          GoRoute(
            path: 'species-picker',
            name: SpeciesPickerPage.routeName,
            pageBuilder: (context, state) {
              final initialId = state.extra as String?;
              return MaterialPage(
                key: state.pageKey,
                child: SpeciesPickerPage(initialSpeciesId: initialId),
              );
            },
          ),
          GoRoute(
            path: 'class-picker',
            name: ClassPickerPage.routeName,
            pageBuilder: (context, state) {
              final initialId = state.extra as String?;
              return MaterialPage(
                key: state.pageKey,
                child: ClassPickerPage(initialClassId: initialId),
              );
            },
          ),
          GoRoute(
            path: 'saved-characters',
            name: SavedCharactersPage.routeName,
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const SavedCharactersPage(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Erreur de navigation : ${state.error}'),
      ),
    ),
  );
});
