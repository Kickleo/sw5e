import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/presentation/viewmodels/saved_characters_view_model.dart';

class SavedCharactersPage extends HookConsumerWidget {
  const SavedCharactersPage({super.key});

  static const routeName = 'saved-characters';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final state = ref.watch(savedCharactersViewModelProvider);
    final viewModel = ref.read(savedCharactersViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnages sauvegardés'),
        actions: [
          IconButton(
            onPressed: state.isLoading ? null : viewModel.refresh,
            tooltip: 'Rafraîchir',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && !state.hasLoadedOnce) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.hasError && state.characters.isEmpty) {
            return _ErrorView(
              message: state.errorMessage ?? 'Erreur inconnue',
              onRetry: viewModel.refresh,
            );
          }

          if (state.isEmpty) {
            return RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: const _EmptyView(),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            child: Scrollbar(
              controller: scrollController,
              child: ListView.separated(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: state.characters.length + (state.hasError ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (state.hasError) {
                    if (index == 0) {
                      return _InlineErrorBanner(message: state.errorMessage ?? 'Erreur inconnue');
                    }
                    final character = state.characters[index - 1];
                    return _CharacterCard(character: character);
                  }
                  final character = state.characters[index];
                  return _CharacterCard(character: character);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.character});

  final Character character;

  String _fmtSigned(int v) => v >= 0 ? '+$v' : '$v';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    Text('Niveau ${character.level.value}', style: theme.textTheme.bodyMedium),
                    Text('Défense ${character.defense.value}', style: theme.textTheme.bodyMedium),
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
                _ChipStat(label: 'Init', value: _fmtSigned(character.initiative.value)),
                _ChipStat(label: 'Bonus maîtrise', value: '+${character.proficiencyBonus.value}'),
                _ChipStat(label: 'Crédits', value: '${character.credits.value}'),
                _ChipStat(label: 'Charge', value: '${character.encumbrance.grams} g'),
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
                      .map((s) => Chip(
                            label: Text('${s.skillId} (${s.sources.map((e) => e.name).join('+')})'),
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
                      .map((l) => Text('• ${l.itemId.value} ×${l.quantity.value}'))
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
    final theme = Theme.of(context);
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

class _AbilitiesTable extends StatelessWidget {
  const _AbilitiesTable({required this.abilities});

  final Map<String, dynamic> abilities; // AbilityScore

  static const _order = ['str', 'dex', 'con', 'int', 'wis', 'cha'];

  static String _fmtMod(int m) => m >= 0 ? '+$m' : '$m';

  @override
  Widget build(BuildContext context) {
    final rows = <DataRow>[];
    for (final k in _order) {
      final score = abilities[k]!;
      rows.add(DataRow(cells: [
        DataCell(Text(k.toUpperCase())),
        DataCell(Text('${score.value}')),
        DataCell(Text(_fmtMod(score.modifier))),
      ]));
    }
    return DataTable(
      columns: const [
        DataColumn(label: Text('Carac')),
        DataColumn(label: Text('Score')),
        DataColumn(label: Text('Mod')),
      ],
      rows: rows,
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      children: const [
        Center(child: Text('Aucun personnage sauvegardé.')),
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
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
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
