/// ---------------------------------------------------------------------------
/// Fichier : lib/ui/character_creation/pages/saved_characters_page.dart
/// Rôle : Vue Flutter affichant la liste des personnages sauvegardés ;
///        délègue entièrement l'état au SavedCharactersBloc (ViewModel MVVM).
/// Dépendances : flutter_bloc (binding BLoC↔UI), ServiceLocator (injection),
///        entités métier Character.
/// Exemple d'usage : routage GoRouter -> const SavedCharactersPage().
/// ---------------------------------------------------------------------------
library;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sw5e_manager/common/di/service_locator.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/presentation/character_creation/blocs/saved_characters_bloc.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/character_section_divider.dart';

class SavedCharactersPage extends StatefulWidget {
  const SavedCharactersPage({super.key});

  static const String routeName = 'saved-characters';

  @override
  State<SavedCharactersPage> createState() => _SavedCharactersPageState();
}

class _SavedCharactersPageState extends State<SavedCharactersPage> {
  late final ScrollController _scrollController;
  late final SavedCharactersBloc _bloc;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final ListSavedCharacters listSavedCharacters =
        ServiceLocator.resolve<ListSavedCharacters>();
    _bloc = SavedCharactersBloc(
      listSavedCharacters: listSavedCharacters,
    )..add(const SavedCharactersRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SavedCharactersBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Personnages sauvegardés'),
          actions: [
            BlocBuilder<SavedCharactersBloc, SavedCharactersState>(
              buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
              builder: (context, state) {
                return IconButton(
                  onPressed: state.isLoading
                      ? null
                      : () => context
                          .read<SavedCharactersBloc>()
                          .add(const SavedCharactersRefreshRequested()),
                  tooltip: 'Rafraîchir',
                  icon: const Icon(Icons.refresh),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<SavedCharactersBloc, SavedCharactersState>(
          builder: (context, state) {
            if (state.isLoading && !state.hasLoadedOnce) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.hasError && state.characters.isEmpty) {
              return _ErrorView(
                message: state.errorMessage ?? 'Erreur inconnue',
                onRetry: () => context
                    .read<SavedCharactersBloc>()
                    .add(const SavedCharactersRefreshRequested()),
              );
            }

            if (state.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<SavedCharactersBloc>()
                      .add(const SavedCharactersRefreshRequested());
                },
                child: const _EmptyView(),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<SavedCharactersBloc>()
                    .add(const SavedCharactersRefreshRequested());
              },
              child: Scrollbar(
                controller: _scrollController,
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      state.characters.length + (state.hasError ? 1 : 0),
                  separatorBuilder: (_, _) => const CharacterSectionDivider(),
                  itemBuilder: (context, index) {
                    if (state.hasError) {
                      if (index == 0) {
                        return _InlineErrorBanner(
                          message:
                              state.errorMessage ?? 'Erreur inconnue',
                        );
                      }
                      final Character character = state.characters[index - 1];
                      return _CharacterCard(character: character);
                    }
                    final Character character = state.characters[index];
                    return _CharacterCard(character: character);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.character});

  final Character character;

  String _fmtSigned(int value) => value >= 0 ? '+$value' : '$value';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name.value,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Espèce : ${character.speciesId.value} • Classe : ${character.classId.value}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Historique : ${character.backgroundId.value}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Niveau ${character.level.value}',
                        style: theme.textTheme.bodyMedium),
                    Text('Défense ${character.defense.value}',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _ChipStat(label: 'PV', value: '${character.hitPoints.value}'),
                _ChipStat(
                    label: 'Init', value: _fmtSigned(character.initiative.value)),
                _ChipStat(
                    label: 'Bonus maîtrise',
                    value: '+${character.proficiencyBonus.value}'),
                _ChipStat(label: 'Crédits', value: '${character.credits.value}'),
                _ChipStat(
                    label: 'Charge',
                    value: '${character.encumbrance.grams} g'),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Caractéristiques',
              child: _AbilitiesTable(abilities: character.abilities),
            ),
            if (character.skills.isNotEmpty) ...[
              const SizedBox(height: 16),
              _Section(
                title: 'Compétences',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: character.skills
                      .map((skill) => Chip(
                            label: Text(
                                '${skill.skillId} (${skill.sources.map((source) => source.name).join('+')})'),
                          ))
                      .toList(),
                ),
              ),
            ],
            if (character.inventory.isNotEmpty) ...[
              const SizedBox(height: 16),
              _Section(
                title: 'Inventaire',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: character.inventory
                      .map((line) =>
                          Text('• ${line.itemId.value} ×${line.quantity.value}'))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: const [
        Icon(Icons.group_off, size: 64),
        SizedBox(height: 16),
        Center(
          child: Text(
            'Aucun personnage enregistré pour le moment.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
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
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
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
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ChipStat extends StatelessWidget {
  const _ChipStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label : $value'),
    );
  }
}

class _AbilitiesTable extends StatelessWidget {
  const _AbilitiesTable({required this.abilities});

  final Map<String, AbilityScore> abilities;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
      },
      children: abilities.entries
          .map(
            (entry) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(entry.key, style: theme.textTheme.bodyMedium),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    entry.value.toString(),
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
