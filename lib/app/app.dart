/// ---------------------------------------------------------------------------
/// Fichier : lib/app/app.dart
/// Rôle : Déclarer le widget racine [Sw5eApp] qui configure le MaterialApp.router.
/// Dépendances : Flutter Material, flutter_riverpod, configuration GoRouter.
/// Exemple d'usage : instancié depuis `main.dart` via `runApp(const Sw5eApp())`.
/// ---------------------------------------------------------------------------
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
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'SW5e Manager',
      theme: ThemeData(useMaterial3: true),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
