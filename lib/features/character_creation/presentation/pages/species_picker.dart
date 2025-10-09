import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sw5e_manager/di/character_creation_module.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';

class SpeciesPickerPage extends ConsumerStatefulWidget {
  const SpeciesPickerPage({super.key, this.initialSpeciesId});

  static const routeName = 'species-picker';

  final String? initialSpeciesId;

  @override
  ConsumerState<SpeciesPickerPage> createState() => _SpeciesPickerPageState();
}

class _SpeciesPickerPageState extends ConsumerState<SpeciesPickerPage> {
  late final CatalogRepository _catalog = ref.read(catalogRepositoryProvider);

  bool _loading = true;
  String? _error;

  List<String> _speciesIds = [];
  String? _selectedId;
  SpeciesDef? _selected;
  List<TraitDef> _traits = const <TraitDef>[];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ids = await _catalog.listSpecies();
      final String? pick = widget.initialSpeciesId ?? (ids.isNotEmpty ? ids.first : null);
      SpeciesDef? def;
      List<TraitDef> traits = const <TraitDef>[];
      if (pick != null) {
        def = await _catalog.getSpecies(pick);
        if (def != null) {
          traits = await _loadTraits(def);
        }
      }
      if (!mounted) return;
      setState(() {
        _speciesIds = ids;
        _selectedId = pick;
        _selected = def;
        _traits = traits;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur de chargement: $e';
        _loading = false;
      });
    }
  }

  Future<List<TraitDef>> _loadTraits(SpeciesDef species) async {
    final traits = <TraitDef>[];
    for (final traitId in species.traitIds) {
      final trait = await _catalog.getTrait(traitId);
      if (trait != null) {
        traits.add(trait);
      }
    }
    return traits;
  }

  Future<void> _onSelect(String id) async {
    setState(() {
      _selectedId = id;
      _selected = null;
      _traits = const <TraitDef>[];
      _error = null;
      _loading = true;
    });
    try {
      final spec = await _catalog.getSpecies(id);
      List<TraitDef> traits = const <TraitDef>[];
      if (spec != null) {
        traits = await _loadTraits(spec);
      }
      if (!mounted) return;
      setState(() {
        _selected = spec;
        _traits = traits;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur: $e';
        _loading = false;
      });
    }
  }

  void _confirm() {
    if (_selectedId == null) return;
    Navigator.of(context).pop(_selectedId);
  }

  String _titleCase(String slug) {
    return slug
        .split(RegExp(r'[-_]'))
        .map((part) => part.isEmpty
            ? part
            : part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir une espèce'),
        actions: [
          TextButton(
            onPressed: _selectedId == null ? null : _confirm,
            child: const Text('Sélectionner'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Row(
                  children: [
                    SizedBox(
                      width: 240,
                      child: ListView.builder(
                        itemCount: _speciesIds.length,
                        itemBuilder: (context, index) {
                          final id = _speciesIds[index];
                          final selected = id == _selectedId;
                          return ListTile(
                            selected: selected,
                            title: Text(_titleCase(id)),
                            subtitle: Text(id),
                            onTap: () => _onSelect(id),
                          );
                        },
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: _selected == null
                          ? const Center(child: Text('Aucune espèce sélectionnée'))
                          : Padding(
                              padding: const EdgeInsets.all(16),
                              child: ListView(
                                children: [
                                  Text(
                                    _selected!.name.fr.isNotEmpty
                                        ? _selected!.name.fr
                                        : _selected!.name.en,
                                    style: th.textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Identifiant : ${_selected!.id}'),
                                  const SizedBox(height: 12),
                                  Text('Vitesse : ${_selected!.speed}'),
                                  Text('Taille : ${_selected!.size}'),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Traits d’espèce',
                                    style: th.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  if (_traits.isEmpty)
                                    const Text('Aucun trait listé pour cette espèce.')
                                  else
                                    ..._traits.map(
                                      (trait) => Card(
                                        child: ListTile(
                                          title: Text(trait.name.fr.isNotEmpty
                                              ? trait.name.fr
                                              : trait.name.en),
                                          subtitle: Text(trait.description),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}
