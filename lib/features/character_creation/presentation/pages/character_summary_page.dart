import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_id.dart';
import 'package:sw5e_manager/features/character_creation/presentation/viewmodels/character_summary_view_model.dart';

class CharacterSummaryPage extends ConsumerWidget {
  const CharacterSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(characterSummaryViewModelProvider);
    final viewModel = ref.read(characterSummaryViewModelProvider.notifier);
    final charactersAsync = state.characters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résumé de personnage'),
        actions: [
          IconButton(
            onPressed: charactersAsync.isLoading ? null : viewModel.refresh,
            tooltip: 'Rafraîchir',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: state.selectedCharacter == null || state.isSharing
                ? null
                : viewModel.shareSelectedCharacter,
            tooltip: 'Partager',
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: charactersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: error is Exception ? error.toString() : 'Erreur: $error',
          onRetry: viewModel.refresh,
        ),
        data: (characters) => characters.isEmpty
            ? const _EmptyView()
            : RefreshIndicator(
                onRefresh: viewModel.refresh,
                child: Scrollbar(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _CharacterSelector(
                        characters: characters,
                        selectedId: state.selectedId ?? state.selectedCharacter?.id,
                        onChanged: (id) {
                          if (id != null) {
                            viewModel.selectCharacter(id);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (state.selectedCharacter != null)
                        _CharacterSummaryCard(character: state.selectedCharacter!),
                    ],
                  ),
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
      decoration: const InputDecoration(
        labelText: 'Personnage sauvegardé',
        border: OutlineInputBorder(),
      ),
      items: characters
          .map(
            (c) => DropdownMenuItem<CharacterId>(
              value: c.id,
              child: Text(c.name.value),
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
            Text(
              character.name.value,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Identifiant : ${character.id.value}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _ChipStat(label: 'Niveau', value: '${character.level.value}'),
                _ChipStat(
                    label: 'Bonus de maîtrise',
                    value: '+${character.proficiencyBonus.value}'),
                _ChipStat(label: 'PV', value: '${character.hitPoints.value}'),
                _ChipStat(label: 'Défense', value: '${character.defense.value}'),
                _ChipStat(label: 'Initiative', value: _fmtSigned(character.initiative.value)),
                _ChipStat(label: 'Crédits', value: '${character.credits.value}'),
                _ChipStat(label: 'Poids porté', value: '${character.encumbrance.grams} g'),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Profil',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Espèce : ${character.speciesId.value}'),
                  Text('Classe : ${character.classId.value}'),
                  Text('Historique : ${character.backgroundId.value}'),
                  if (character.speciesTraits.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Traits d’espèce :',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: character.speciesTraits
                          .map((t) => Chip(label: Text(t.id.value)))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Caractéristiques',
              child: _AbilitiesTable(abilities: character.abilities),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Compétences maîtrisées',
              child: character.skills.isEmpty
                  ? const Text('Aucune')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: character.skills
                          .map((s) => Chip(
                                label: Text('${s.skillId} (${s.sources.map((e) => e.name).join('+')})'),
                              ))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Inventaire',
              child: character.inventory.isEmpty
                  ? const Text('Vide')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: character.inventory
                          .map((l) => Text('• ${l.itemId.value} ×${l.quantity.value}'))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Manœuvres / Dés de supériorité',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Connues: ${character.maneuversKnown.value}'),
                  Text('Dés: ${character.superiorityDice.count}d${character.superiorityDice.die ?? '-'}'),
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
    final theme = Theme.of(context);
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

  static const _order = ['str', 'dex', 'con', 'int', 'wis', 'cha'];

  static String _fmtMod(int m) => m >= 0 ? '+$m' : '$m';

  @override
  Widget build(BuildContext context) {
    final rows = <DataRow>[];
    for (final key in _order) {
      final score = abilities[key]!;
      rows.add(
        DataRow(
          cells: [
            DataCell(Text(key.toUpperCase())),
            DataCell(Text('${score.value}')),
            DataCell(Text(_fmtMod(score.modifier))),
          ],
        ),
      );
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
    return const Center(
      child: Text('Aucun personnage sauvegardé.'),
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
