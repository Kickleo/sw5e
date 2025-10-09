import 'package:flutter/material.dart';
import 'package:sw5e_manager/di/character_creation_module.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';

class SpeciesPickerPage extends StatefulWidget {
  final String? initialSpeciesId;
  const SpeciesPickerPage({super.key, this.initialSpeciesId});

  @override
  State<SpeciesPickerPage> createState() => _SpeciesPickerPageState();
}

class _SpeciesPickerPageState extends State<SpeciesPickerPage> {
  late final CatalogRepository _catalog = sl<CatalogRepository>();

  bool _loading = true;
  String? _error;

  List<String> _speciesIds = [];
  String? _selectedId;
  SpeciesDef? _selected;

  // cache des traits pour affichage
  final Map<String, TraitDef> _traitCache = {};

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
      final SpeciesDef? specie = pick == null ? null : await _catalog.getSpecies(pick);

      setState(() {
        _speciesIds = ids;
        _selectedId = pick;
        _selected = specie;
        _loading = false;
      });

      if (specie != null) {
        await _ensureTraitDefs(specie.traitIds);
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement: $e';
        _loading = false;
      });
    }
  }

  Future<void> _ensureTraitDefs(List<String> ids) async {
    for (final id in ids) {
      if (_traitCache.containsKey(id)) continue;
      final t = await _catalog.getTrait(id);
      if (t != null) _traitCache[id] = t;
    }
    if (mounted) setState(() {});
  }

  Future<void> _onSelect(String id) async {
    setState(() {
      _selectedId = id;
      _selected = null;
      _loading = true;
      _error = null;
    });
    try {
      final sp = await _catalog.getSpecies(id);
      setState(() {
        _selected = sp;
        _loading = false;
      });
      if (sp != null) await _ensureTraitDefs(sp.traitIds);
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
        _loading = false;
      });
    }
  }

  void _confirm() {
    if (_selectedId == null) return;
    Navigator.of(context).pop(_selectedId); // retourne l'id choisi
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
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Row(
                  children: [
                    // Liste des espèces (ids simples pour MVP)
                    SizedBox(
                      width: 240,
                      child: ListView.builder(
                        itemCount: _speciesIds.length,
                        itemBuilder: (context, index) {
                          final id = _speciesIds[index];
                          final selected = id == _selectedId;
                          return ListTile(
                            selected: selected,
                            title: Text(id),
                            onTap: () => _onSelect(id),
                          );
                        },
                      ),
                    ),
                    const VerticalDivider(width: 1),

                    // Détails
                    Expanded(
                      child: _selected == null
                          ? const Center(child: Text('Aucune espèce sélectionnée'))
                          : Padding(
                              padding: const EdgeInsets.all(16),
                              child: ListView(
                                children: [
                                  Text(
                                    _selectedId!,
                                    style: th.textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      Chip(label: Text('Vitesse: ${_selected!.speed}')),
                                      Chip(label: Text('Taille: ${_selected!.size}')),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text('Traits', style: th.textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  if (_selected!.traitIds.isEmpty)
                                    const Text('Aucun trait')
                                  else
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: _selected!.traitIds.map((tid) {
                                        final t = _traitCache[tid];
                                        if (t == null) return Text('• $tid');
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(t.name.fr.isNotEmpty ? t.name.fr : t.name.en,
                                                  style: th.textTheme.titleSmall),
                                              const SizedBox(height: 4),
                                              Text(t.description),
                                            ],
                                          ),
                                        );
                                      }).toList(),
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
