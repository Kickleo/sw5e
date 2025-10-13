import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw5e_manager/app/locale/app_locale_controller.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/ui/character_creation/pages/saved_characters_page.dart';

/// Page d'accueil offrant les principales entrées de l'application.
///
/// L'objectif est de proposer un point de départ clair pour l'utilisateur en
/// lui présentant les deux actions disponibles à ce stade du projet :
///
/// * démarrer la création d'un nouveau personnage ;
/// * consulter la liste des personnages déjà enregistrés.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = ref.watch(appLocaleProvider);
    final localeController = ref.read(appLocaleProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.homeWelcomeTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(l10n.homeLanguageLabel),
                      const SizedBox(height: 4),
                      DropdownButton<Locale>(
                        value: locale,
                        onChanged: (value) {
                          if (value != null) {
                            localeController.setLocale(value);
                          }
                        },
                        items: AppLocalizations.supportedLocales
                            .map(
                              (supportedLocale) => DropdownMenuItem(
                                value: supportedLocale,
                                child: Text(
                                  supportedLocale.languageCode == 'fr'
                                      ? l10n.languageFrench
                                      : l10n.languageEnglish,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.homeTagline,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                FilledButton.icon(
                  onPressed: () => context.go('/create'),
                  icon: const Icon(Icons.bolt),
                  label: Text(l10n.homeCreateButton),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.goNamed(SavedCharactersPage.routeName),
                  icon: const Icon(Icons.folder_shared),
                  label: Text(l10n.homeLoadButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
