/// ---------------------------------------------------------------------------
/// Fichier : lib/ui/character_creation/pages/character_summary_page.dart
/// Rôle : Vue Flutter affichant le résumé des personnages sauvegardés et
///        orchestrant les interactions via CharacterSummaryBloc.
/// Dépendances : flutter_bloc (binding BLoC↔UI), Share Plus (partage),
///        ServiceLocator pour l'injection.
/// Exemple d'usage : routage GoRouter -> const CharacterSummaryPage().
/// ---------------------------------------------------------------------------
library;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/common/di/service_locator.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_id.dart';
import 'package:sw5e_manager/presentation/character_creation/blocs/character_summary_bloc.dart';
class CharacterSummaryPage extends StatefulWidget {
  /// Constructeur par défaut.
  const CharacterSummaryPage({super.key});

  @override
  State<CharacterSummaryPage> createState() => _CharacterSummaryPageState();
}

class _CharacterSummaryPageState extends State<CharacterSummaryPage> {
  late final ScrollController _scrollController;
  late final AppLogger _logger;
  late final CharacterSummaryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _logger = ServiceLocator.resolve<AppLogger>();
    final ListSavedCharacters listSavedCharacters =
        ServiceLocator.resolve<ListSavedCharacters>();
    _bloc = CharacterSummaryBloc(
      listSavedCharacters: listSavedCharacters,
      logger: _logger,
    )..add(const CharacterSummaryStarted());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  Future<void> _onRefresh(BuildContext context) async {
    context
        .read<CharacterSummaryBloc>()
        .add(const CharacterSummaryRefreshRequested());
  }

  Future<void> _onShareIntent(
    BuildContext context,
    CharacterSummaryShareIntent intent,
  ) async {
    try {
      await Share.share(intent.message, subject: intent.subject);
    } on Object catch (error, stackTrace) {
      _logger.warn(
        'CharacterSummaryPage.share: échec',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      if (context.mounted) {
        context
            .read<CharacterSummaryBloc>()
            .add(const CharacterSummaryShareAcknowledged());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CharacterSummaryBloc>.value(
      value: _bloc,
      child: BlocListener<CharacterSummaryBloc, CharacterSummaryState>(
        listenWhen: (previous, current) =>
            previous.shareIntent != current.shareIntent &&
            current.shareIntent != null,
        listener: (context, state) {
          final CharacterSummaryShareIntent? intent = state.shareIntent;
          if (intent != null) {
            unawaited(_onShareIntent(context, intent));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.characterSummaryTitle),
            leading: IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: context.l10n.backToHomeTooltip,
              onPressed: () => context.go('/'),
            ),
            actions: [
              BlocBuilder<CharacterSummaryBloc, CharacterSummaryState>(
                buildWhen: (previous, current) =>
                    previous.isLoading != current.isLoading,
                builder: (context, state) {
                  return IconButton(
                    onPressed: state.isLoading
                        ? null
                        : () => context
                            .read<CharacterSummaryBloc>()
                            .add(const CharacterSummaryRefreshRequested()),
                    tooltip: context.l10n.refreshTooltip,
                    icon: const Icon(Icons.refresh),
                  );
                },
              ),
              BlocBuilder<CharacterSummaryBloc, CharacterSummaryState>(
                buildWhen: (previous, current) =>
                    previous.isSharing != current.isSharing ||
                    previous.selectedId != current.selectedId ||
                    previous.characters != current.characters,
                builder: (context, state) {
                  final Character? selected = state.selectedCharacter;
                  return IconButton(
                    onPressed: selected == null || state.isSharing
                        ? null
                        : () => context
                            .read<CharacterSummaryBloc>()
                            .add(const CharacterSummaryShareRequested()),
                    tooltip: context.l10n.shareTooltip,
                    icon: const Icon(Icons.share),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<CharacterSummaryBloc, CharacterSummaryState>(
            builder: (context, state) {
              if (state.isLoading && !state.hasLoadedOnce) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.hasError && state.characters.isEmpty) {
                return _ErrorView(
                  message: state.errorMessage ?? context.l10n.unknownError,
                  onRetry: () => context
                      .read<CharacterSummaryBloc>()
                      .add(const CharacterSummaryRefreshRequested()),
                );
              }

              if (state.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => _onRefresh(context),
                  child: const _EmptyView(),
                );
              }

              final Character? selected = state.selectedCharacter;

              return RefreshIndicator(
                onRefresh: () => _onRefresh(context),
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _CharacterSelector(
                        characters: state.characters,
                        selectedId: state.selectedId ?? selected?.id,
                        onChanged: (CharacterId? id) {
                          if (id != null) {
                            context.read<CharacterSummaryBloc>().add(
                                  CharacterSummaryCharacterSelected(id),
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (selected != null)
                        _CharacterSummaryCard(character: selected),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CharacterSelector extends StatelessWidget {
  const _CharacterSelector({
    required this.characters,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Character> characters;
  final CharacterId? selectedId;
  final ValueChanged<CharacterId?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CharacterId>(
      initialValue: selectedId,
      decoration: InputDecoration(
        labelText: context.l10n.savedCharacterDropdownLabel,
        border: const OutlineInputBorder(),
      ),
      items: characters
          .map(
            (Character character) => DropdownMenuItem<CharacterId>(
              value: character.id,
              child: Text(character.name.value),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _CharacterSummaryCard extends StatelessWidget {
  const _CharacterSummaryCard({required this.character});

  final Character character;

  String _fmtSigned(int value) => value >= 0 ? '+$value' : '$value';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              character.name.value,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.speciesIdentifier(character.id.value),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _ChipStat(label: l10n.statLevel, value: '${character.level.value}'),
                _ChipStat(
                  label: l10n.statProficiency,
                  value: '+${character.proficiencyBonus.value}',
                ),
                _ChipStat(label: l10n.statHp, value: '${character.hitPoints.value}'),
                _ChipStat(label: l10n.statDefense, value: '${character.defense.value}'),
                _ChipStat(
                  label: l10n.statInitiative,
                  value: _fmtSigned(character.initiative.value),
                ),
                _ChipStat(label: l10n.statCredits, value: '${character.credits.value}'),
                _ChipStat(
                  label: l10n.statCarriedWeight,
                  value: '${character.encumbrance.grams} g',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: l10n.characterProfileTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.savedCharactersHeader(
                      character.speciesId.value, character.classId.value)),
                  Text(l10n.savedCharactersBackground(
                      character.backgroundId.value)),
                  if (character.speciesTraits.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.characterSpeciesTraitsHeading,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: character.speciesTraits
                          .map((trait) => Chip(label: Text(trait.id.value)))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: l10n.characterAbilitiesTitle,
              child: _AbilitiesTable(abilities: character.abilities),
            ),
            const SizedBox(height: 16),
            _Section(
              title: l10n.characterMasteredSkillsTitle,
              child: character.skills.isEmpty
                  ? Text(l10n.characterNoSkills)
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: character.skills
                          .map(
                            (skill) => Chip(
                              label: Text(
                                '${skill.skillId} (${skill.sources.map((source) => source.name).join('+')})',
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: l10n.characterInventoryTitle,
              child: character.inventory.isEmpty
                  ? Text(l10n.characterInventoryEmpty)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: character.inventory
                          .map(
                            (line) => Text(
                              l10n.inventoryLine(
                                line.itemId.value,
                                line.quantity.value,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: l10n.characterManeuversTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.characterManeuversKnown(
                      character.maneuversKnown.value)),
                  Text(
                    l10n.characterManeuverDice(
                      character.superiorityDice.count,
                      character.superiorityDice.die,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipStat extends StatelessWidget {
  const _ChipStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _AbilitiesTable extends StatelessWidget {
  const _AbilitiesTable({required this.abilities});

  final Map<String, dynamic> abilities;

  static const List<String> _order = <String>['str', 'dex', 'con', 'int', 'wis', 'cha'];

  static String _fmtMod(int modifier) => modifier >= 0 ? '+$modifier' : '$modifier';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final List<DataRow> rows = <DataRow>[];
    for (final String key in _order) {
      final dynamic score = abilities[key]!;
      rows.add(
        DataRow(
          cells: [
            DataCell(Text(l10n.abilityAbbreviation(key))),
            DataCell(Text('${score.value}')),
            DataCell(Text(_fmtMod(score.modifier))),
          ],
        ),
      );
    }
    return DataTable(
      columns: <DataColumn>[
        DataColumn(label: Text(l10n.abilitiesTableAbility)),
        DataColumn(label: Text(l10n.abilitiesTableScore)),
        DataColumn(label: Text(l10n.abilitiesTableModifier)),
      ],
      rows: rows,
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(context.l10n.emptySavedCharacters),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: Text(context.l10n.retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
