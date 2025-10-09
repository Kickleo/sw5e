import 'package:flutter/material.dart';
import 'package:sw5e_manager/di/character_creation_module.dart';
import 'package:sw5e_manager/features/character_creation/domain/entities/character.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_id.dart';

class CharacterSummaryPage extends StatefulWidget {
  const CharacterSummaryPage({super.key});

  @override
  State<CharacterSummaryPage> createState() => _CharacterSummaryPageState();
}

class _CharacterSummaryPageState extends State<CharacterSummaryPage> {
  late final ListSavedCharacters _listCharacters = sl<ListSavedCharacters>();
  late final ScrollController _scrollController;

  bool _loading = true;
  String? _error;
  List<Character> _characters = const <Character>[];
  CharacterId? _selectedId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _refresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _listCharacters();
    if (!mounted) return;
    result.match(
      ok: (characters) {
        setState(() {
          _characters = characters;
          if (characters.isEmpty) {
            _selectedId = null;
          } else if (_selectedId == null ||
              !characters.any((c) => c.id == _selectedId)) {
            _selectedId = characters.last.id;
          }
          _loading = false;
        });
      },
      err: (err) {
        setState(() {
          _error = '${err.code}${err.message != null ? ' — ${err.message}' : ''}';
          _loading = false;
        });
      },
    );
  }

  Character? get _selectedCharacter {
    if (_characters.isEmpty || _selectedId == null) return null;
    return _characters.firstWhere((c) => c.id == _selectedId,
        orElse: () => _characters.last);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résumé de personnage'),
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
              : _characters.isEmpty
                  ? const _EmptyView()
                  : Scrollbar(
                      controller: _scrollController,
                      child: RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          children: [
                            Semantics(
                              container: true,
                              label: 'Sélection du personnage sauvegardé',
                              child: DropdownButtonFormField<CharacterId>(
                                value: _selectedCharacter?.id,
                                decoration: const InputDecoration(
                                  labelText: 'Personnage',
                                  border: OutlineInputBorder(),
                                ),
                                items: _characters
                                    .map(
                                      (c) => DropdownMenuItem<CharacterId>(
                                        value: c.id,
                                        child: Text(c.name.value),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _selectedId = value);
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_selectedCharacter != null)
                              Semantics(
                                container: true,
                                label:
                                    'Résumé détaillé du personnage ${_selectedCharacter!.name.value}',
                                child: _CharacterSummaryCard(
                                  character: _selectedCharacter!,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

class _CharacterSummaryCard extends StatelessWidget {
  final Character character;
  const _CharacterSummaryCard({required this.character});

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
                _ChipStat(
                    label: 'Initiative', value: _fmtSigned(character.initiative.value)),
                _ChipStat(label: 'Crédits', value: '${character.credits.value}'),
                _ChipStat(
                    label: 'Poids porté',
                    value: '${character.encumbrance.grams} g'),
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
                          .map((trait) => Chip(label: Text(trait.id.value)))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Caractéristiques',
              child: Column(
                children: character.abilities.entries
                    .map(
                      (entry) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(entry.key.toUpperCase()),
                        subtitle: Text('Modificateur ${_fmtSigned(entry.value.modifier)}'),
                        trailing: Text('${entry.value.value}'),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Compétences maîtrisées',
              child: character.skills.isEmpty
                  ? const Text('Aucune compétence maîtrisée')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: character.skills
                          .map(
                            (skill) => Chip(
                              label: Text(
                                '${skill.skillId} — ${skill.sources.map((e) => e.name).join('+')}',
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Inventaire',
              child: character.inventory.isEmpty
                  ? const Text('Inventaire vide')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: character.inventory
                          .map((line) => Text(
                              '• ${line.itemId.value} ×${line.quantity.value}'))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Manœuvres et dés de supériorité',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Manœuvres connues : ${character.maneuversKnown.value}'),
                  Text(
                    'Dés de supériorité : ${character.superiorityDice.count}d'
                    '${character.superiorityDice.die ?? '-'}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtSigned(int value) => value >= 0 ? '+$value' : '$value';
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ChipStat extends StatelessWidget {
  final String label;
  final String value;
  const _ChipStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label : $value',
      child: Chip(
        label: Text('$label : $value'),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Aucun personnage sauvegardé pour le moment.'),
      ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Erreur : $message'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
