/// ---------------------------------------------------------------------------
/// Fichier : lib/app/locale/app_locale_controller.dart
/// Rôle : Exposer un contrôleur Riverpod permettant de modifier la langue de
///        l'application dynamiquement.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider global stockant la locale choisie par l'utilisateur.
final appLocaleProvider =
    StateNotifierProvider<AppLocaleController, Locale>(
  (ref) => AppLocaleController(),
);

/// Contrôleur responsable d'appliquer une nouvelle langue à l'application.
class AppLocaleController extends StateNotifier<Locale> {
  AppLocaleController() : super(const Locale('fr'));

  /// Sélectionne une [Locale] différente si nécessaire.
  void setLocale(Locale locale) {
    if (locale == state) {
      return;
    }
    state = locale;
  }
}
