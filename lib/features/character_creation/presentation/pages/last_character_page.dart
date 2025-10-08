import 'package:flutter/material.dart';

import 'package:sw5e_manager/di/character_creation_module.dart';
import 'package:sw5e_manager/core/domain/result.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/load_last_character.dart';

class LastCharacterPage extends StatefulWidget {
  const LastCharacterPage({super.key});

  @override
  State<LastCharacterPage> createState() => _LastCharacterPageState();
}

class _LastCharacterPageState extends State<LastCharacterPage> {
  late final LoadLastCharacter _load = sl<LoadLastCharacter>();
  bool _loading = true;
  String? _error;
  Character? _character;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final Result<Character?> res = await _load();
    if (!mounted) return;

    res.match(
      ok: (c) => setState(() {
        _character = c;
        _loading = false;
      }),
      err: (e) => setState(() {
        _error = '${e.code}${e.message != null ? ' — ${e.message}' : ''}';
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dernier personnage'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _refresh,
            tooltip: 'Rafraîchir',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _refresh)
              : _character == null
                  ? const _EmptyView()
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        children: [
                          Text(
                            _character!.name.value,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Espèce: ${_character!.speciesId.value} • '
                            'Classe: ${_character!.classId.value} • '
                            'BG: ${_character!.backgroundId.value}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              _ChipStat(label: 'Niveau', value: '${_character!.level.value}'),
                              _ChipStat(label: 'Bonus de maîtrise', value: '+${_character!.proficiencyBonus.value}'),
                              _ChipStat(label: 'PV', value: '${_character!.hitPoints.value}'),
                              _ChipStat(label: 'Défense', value: '${_character!.defense.value}'),
                              _ChipStat(label: 'Init', value: _fmtSigned(_character!.initiative.value)),
                              _ChipStat(label: 'Crédits', value: '${_character!.credits.value}'),
                              _ChipStat(label: 'Poids', value: '${_character!.encumbrance.grams} g'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text('Caractéristiques', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          _AbilitiesTable(abilities: _character!.abilities),

                          const SizedBox(height: 16),
                          Text('Compétences maîtrisées', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          if (_character!.skills.isEmpty)
                            const Text('Aucune')
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _character!.skills
                                  .map((s) => Chip(
                                        label: Text('${s.skillId} (${s.sources.map((e) => e.name).join('+')})'),
                                      ))
                                  .toList(),
                            ),

                          const SizedBox(height: 16),
                          Text('Inventaire', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          if (_character!.inventory.isEmpty)
                            const Text('Vide')
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _character!.inventory
                                  .map((l) => Text('• ${l.itemId.value} ×${l.quantity.value}'))
                                  .toList(),
                            ),

                          const SizedBox(height: 16),
                          Text('Manœuvres / Dés de supériorité', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Connues: ${_character!.maneuversKnown.value}'),
                          Text('Dés: ${_character!.superiorityDice.count}d${_character!.superiorityDice.die ?? '-'}'),
                        ],
                      ),
                    ),
    );
  }

  String _fmtSigned(int v) => v >= 0 ? '+$v' : '$v';
}

class _ChipStat extends StatelessWidget {
  final String label;
  final String value;
  const _ChipStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _AbilitiesTable extends StatelessWidget {
  final Map<String, dynamic> abilities; // AbilityScore
  const _AbilitiesTable({required this.abilities});

  @override
  Widget build(BuildContext context) {
    final rows = <DataRow>[];
    const order = ['str', 'dex', 'con', 'int', 'wis', 'cha'];
    for (final k in order) {
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

  static String _fmtMod(int m) => m >= 0 ? '+$m' : '$m';
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
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Erreur : $message'),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
      ]),
    );
  }
}
