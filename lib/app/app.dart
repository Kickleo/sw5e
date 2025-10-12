/// Définit le widget racine qui installe le routeur et les paramètres globaux.
/// L'objectif est d'encapsuler toute la configuration transversale de
/// l'application (thème, navigation, localisations) dans un seul endroit pour
/// garder les écrans métier simples.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw5e_manager/app/router/app_router.dart';

/// Widget racine de l'application.
///
/// `Sw5eApp` récupère la configuration du routeur via Riverpod puis installe le
/// `MaterialApp.router` avec :
///
/// - un titre cohérent avec les stores mobiles ;
/// - le thème Material 3 partagé ;
/// - la configuration de navigation [GoRouter] (définition des routes et
///   redirections) ;
/// - la désactivation de la bannière de debug pour éviter les captures d'écran
///   polluées ;
/// - les délégués de localisation utilisés par les textes et composants natifs.
class Sw5eApp extends ConsumerWidget {
  const Sw5eApp({super.key});

  /// Expose un [MaterialApp] piloté par [GoRouter].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Le router est fourni par la couche navigation via Riverpod afin de
    // réagir automatiquement aux mises à jour (ex. deep-links, rechargement de
    // configuration).
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      // Identité de l'application affichée par l'OS.
      title: 'SW5e Manager',
      // Palette Material 3 partagée par l'ensemble des écrans.
      theme: ThemeData(useMaterial3: true),
      // Router centralisé responsable de l'arbre de navigation, des guards et
      // des redirections conditionnelles.
      routerConfig: router,
      // Evite d'afficher la bannière de debug sur les builds de dev pour se
      // rapprocher du rendu final même en phase de prototypage.
      debugShowCheckedModeBanner: false,
      // Deux langues officiellement prises en charge (anglais + français) ; les
      // écrans peuvent déterminer les traductions disponibles via cette liste.
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      // Enregistre les délégués qui chargent les traductions de widgets,
      // dialogues et composants Cupertino par défaut.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
