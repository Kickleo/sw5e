/// ---------------------------------------------------------------------------
/// Fichier : lib/app/app.dart
/// Rôle : Déclarer le widget racine [Sw5eApp] qui configure le MaterialApp.router.
/// Dépendances : Flutter Material, flutter_riverpod, configuration GoRouter.
/// Exemple d'usage : instancié depuis `main.dart` via `runApp(const Sw5eApp())`.
/// ---------------------------------------------------------------------------
library;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw5e_manager/app/router/app_router.dart';

/// Sw5eApp = widget racine qui prépare la configuration globale MaterialApp.
class Sw5eApp extends ConsumerWidget {
  const Sw5eApp({super.key});

  /// build = fournit le `MaterialApp.router` connecté au provider `appRouter`.
  ///
  /// Pré-condition : le [ProviderScope] doit être initialisé (cf. `main.dart`).
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Récupère une instance de GoRouter depuis Riverpod ; toute navigation sera
    // pilotée par ce router configuré ailleurs dans l'application.
    final router = ref.watch(appRouterProvider);

    // Construit l'application Material en indiquant le router, le thème et les
    // options de localisation (support anglais/français + délégués Flutter).
    return MaterialApp.router(
      title: 'SW5e Manager', // Libellé utilisé par l'OS pour identifier l'app.
      theme: ThemeData(useMaterial3: true), // Activation du style Material 3.
      routerConfig: router, // Liaison du GoRouter précédemment extrait.
      debugShowCheckedModeBanner:
          false, // Supprime le ruban "debug" pendant le développement.
      supportedLocales: const [
        Locale('en'), // Localisation anglaise.
        Locale('fr'), // Localisation française.
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate, // Textes Material standard.
        GlobalWidgetsLocalizations.delegate, // Messages génériques des widgets.
        GlobalCupertinoLocalizations.delegate, // Texte pour widgets Cupertino.
      ],
    );
  }
}
