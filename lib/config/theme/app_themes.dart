/// ---------------------------------------------------------------------------
/// Fichier : lib/config/theme/app_themes.dart
/// Rôle : Centraliser la configuration visuelle Material 3 (thèmes, AppBar) afin
///        de la partager entre les différents écrans.
/// Dépendances : Flutter Material.
/// Exemple d'usage : `final themeData = theme();`
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';

/// Fournit le [ThemeData] de l'application. Les options sont regroupées ici pour
/// simplifier la maintenance et homogénéiser le style.
ThemeData theme() {
  return ThemeData(
    // Couleur de fond des scaffolds, alignée sur un fond clair uniforme.
    scaffoldBackgroundColor: Colors.white,
    // Placeholder pour une font personnalisée éventuelle (Mulish) lorsqu'elle
    // sera intégrée aux assets.
    appBarTheme: appBarTheme(),
  );
}

/// Décrit l'apparence par défaut des AppBar (couleur, elevation, styles...).
AppBarTheme appBarTheme() {
  return const AppBarTheme(
    // Arrière-plan blanc permettant de se fondre avec le Scaffold.
    backgroundColor: Colors.white,
    // Supprime l'ombre afin d'obtenir un rendu plat Material 3.
    elevation: 0,
    // Centre le titre pour refléter la charte graphique de l'app.
    centerTitle: true,
    // Définit l'icône principale (bouton back/menu) avec un gris doux.
    iconTheme: IconThemeData(
      color: Color(0XFF8B8B8B),
    ),
    // Spécifie le style du titre (couleur et taille).
    titleTextStyle: TextStyle(
      color: Color(0XFF8B8B8B),
      fontSize: 18,
    ),
  );
}