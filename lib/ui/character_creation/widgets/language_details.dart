import 'package:flutter/material.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';

/// Displays species or background languages using localized catalog data.
class LanguageDetailsCard extends StatelessWidget {
  const LanguageDetailsCard({
    super.key,
    required this.languages,
    this.fallback,
  });

  /// Structured language definitions sourced from catalog v2.
  final List<LanguageDef> languages;

  /// Optional fallback narrative when no structured languages are available.
  final LocalizedText? fallback;

  /// Returns `true` when either structured languages or fallback text can be
  /// displayed for the given context.
  static bool hasDisplayableContent(
    AppLocalizations l10n,
    List<LanguageDef> languages, {
    LocalizedText? fallback,
  }) {
    if (languages.isNotEmpty) {
      return true;
    }
    if (fallback != null) {
      final String resolved = l10n.localizedCatalogLabel(fallback).trim();
      return resolved.isNotEmpty;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<LanguageDef> normalized = _deduplicateLanguages();
    final String? fallbackLabel = _fallbackLabel(l10n);

    if (normalized.isEmpty && (fallbackLabel == null || fallbackLabel.isEmpty)) {
      return const SizedBox.shrink();
    }

    if (normalized.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.languagesTitle),
          subtitle: Text(fallbackLabel!),
        ),
      );
    }

    final List<Widget> tiles = <Widget>[
      ListTile(
        leading: const Icon(Icons.language),
        title: Text(l10n.languagesTitle),
      ),
      const Divider(height: 0),
      ...normalized.map((LanguageDef language) {
        final String name = l10n.localizedCatalogLabel(language.name).trim();
        final LocalizedText? description = language.description;
        final LocalizedText? script = language.script;
        final String? scriptLabel = _scriptLabel(l10n, script);
        final String? descriptionLabel = description == null
            ? null
            : _normalizeText(l10n.localizedCatalogLabel(description));
        final String? speakersLabel =
            _typicalSpeakersLabel(l10n, language.typicalSpeakers);
        final List<String> subtitleLines = <String>[];
        if (descriptionLabel != null) {
          subtitleLines.add(descriptionLabel);
        }
        if (scriptLabel != null) {
          subtitleLines.add(scriptLabel);
        }
        if (speakersLabel != null) {
          subtitleLines.add(speakersLabel);
        }
        final Widget? subtitleWidget = subtitleLines.isEmpty
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int i = 0; i < subtitleLines.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: 4),
                    Text(subtitleLines[i]),
                  ],
                ],
              );
        return ListTile(
          title: Text(name.isEmpty ? language.id : name),
          subtitle: subtitleWidget,
          isThreeLine: subtitleLines.length > 1,
        );
      }),
    ];

    if (fallbackLabel != null && fallbackLabel.isNotEmpty) {
      tiles
        ..add(const Divider(height: 0))
        ..add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Text(fallbackLabel),
          ),
        );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: tiles,
      ),
    );
  }

  List<LanguageDef> _deduplicateLanguages() {
    if (languages.isEmpty) {
      return const <LanguageDef>[];
    }
    final Set<String> seen = <String>{};
    final List<LanguageDef> unique = <LanguageDef>[];
    for (final LanguageDef language in languages) {
      if (seen.add(language.id)) {
        unique.add(language);
      }
    }
    return unique;
  }

  String? _fallbackLabel(AppLocalizations l10n) {
    if (fallback == null) {
      return null;
    }
    final String resolved = l10n.localizedCatalogLabel(fallback!).trim();
    return resolved.isEmpty ? null : resolved;
  }

  String? _scriptLabel(AppLocalizations l10n, LocalizedText? script) {
    if (script == null) {
      return null;
    }
    final String resolved = _normalizeText(l10n.localizedCatalogLabel(script));
    if (resolved == null || resolved.isEmpty) {
      return null;
    }
    return l10n.languageScriptLabel(resolved);
  }

  String? _typicalSpeakersLabel(
    AppLocalizations l10n,
    List<LanguageTypicalSpeaker> speakers,
  ) {
    if (speakers.isEmpty) {
      return null;
    }
    final Set<String> seen = <String>{};
    final List<String> labels = <String>[];
    for (final LanguageTypicalSpeaker speaker in speakers) {
      final LocalizedText? name = speaker.name;
      final String resolved = name == null
          ? speaker.id
          : _normalizeText(l10n.localizedCatalogLabel(name)) ?? '';
      if (resolved.isEmpty) {
        continue;
      }
      final String normalizedKey = resolved.toLowerCase();
      if (seen.add(normalizedKey)) {
        labels.add(resolved);
      }
    }
    if (labels.isEmpty) {
      return null;
    }
    return l10n.languageTypicalSpeakersLabel(labels.join(', '));
  }

  String? _normalizeText(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
