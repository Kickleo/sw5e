import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sw5e_manager/di/character_creation_module.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';

class ClassPickerPage extends ConsumerStatefulWidget {
  const ClassPickerPage({super.key, this.initialClassId});

  static const routeName = 'class-picker';

  final String? initialClassId;

  @override
  ConsumerState<ClassPickerPage> createState() => _ClassPickerPageState();
}

class _ClassPickerPageState extends ConsumerState<ClassPickerPage> {
  late final CatalogRepository _catalog = ref.read(catalogRepositoryProvider);

  bool _loading = true;
  bool _detailLoading = false;
  String? _error;

  List<String> _classIds = [];
  String? _selectedId;
  ClassDef? _selected;

  final Map<String, SkillDef> _skillCache = {};
  final Map<String, EquipmentDef> _equipmentCache = {};

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
      final ids = await _catalog.listClasses();
      final String? pick = widget.initialClassId ?? (ids.isNotEmpty ? ids.first : null);
      ClassDef? def;
      if (pick != null) {
        def = await _catalog.getClass(pick);
        if (def != null) {
          await Future.wait([
            _ensureSkillDefs(def.level1.proficiencies.skillsFrom),
            _ensureEquipmentDefs(def.level1.startingEquipment.map((e) => e.id)),
          ]);
        }
      }

      if (!mounted) return;
      setState(() {
        _classIds = ids;
        _selectedId = pick;
        _selected = def;
        _loading = false;
        _detailLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur de chargement: $e';
        _loading = false;
        _detailLoading = false;
      });
    }
  }

  Future<void> _ensureSkillDefs(Iterable<String> ids) async {
    for (final id in ids) {
      if (id == 'any') continue;
      if (_skillCache.containsKey(id)) continue;
      final def = await _catalog.getSkill(id);
      if (def != null) {
        _skillCache[id] = def;
      }
    }
  }

  Future<void> _ensureEquipmentDefs(Iterable<String> ids) async {
    for (final id in ids) {
      if (_equipmentCache.containsKey(id)) continue;
      final def = await _catalog.getEquipment(id);
      if (def != null) {
        _equipmentCache[id] = def;
      }
    }
  }

  Future<void> _onSelect(String id) async {
    setState(() {
      _selectedId = id;
      _selected = null;
      _detailLoading = true;
      _error = null;
    });
    try {
      final cls = await _catalog.getClass(id);
      if (cls != null) {
        await Future.wait([
          _ensureSkillDefs(cls.level1.proficiencies.skillsFrom),
          _ensureEquipmentDefs(cls.level1.startingEquipment.map((e) => e.id)),
        ]);
      }
      if (!mounted) return;
      setState(() {
        _selected = cls;
        _detailLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur: $e';
        _detailLoading = false;
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

  String _formatSkill(String id) {
    if (id == 'any') {
      return "N'importe quelle compétence";
    }
    final def = _skillCache[id];
    if (def == null) return _titleCase(id);
    return '${_titleCase(id)} (${def.ability.toUpperCase()})';
  }

  String _formatEquipment(String id) {
    final def = _equipmentCache[id];
    if (def == null) return _titleCase(id);
    final name = def.name.fr.isNotEmpty ? def.name.fr : def.name.en;
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir une classe'),
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
                        itemCount: _classIds.length,
                        itemBuilder: (context, index) {
                          final id = _classIds[index];
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
                      child: _detailLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _selected == null
                              ? const Center(child: Text('Aucune classe sélectionnée'))
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
                                      Text('Dé de vie : d${_selected!.hitDie}'),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Compétences : choisir ${_selected!.level1.proficiencies.skillsChoose} parmi :',
                                        style: th.textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      ..._selected!.level1.proficiencies.skillsFrom
                                          .map((id) => Text('• ${_formatSkill(id)}')),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Équipement de départ',
                                        style: th.textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      ..._selected!.level1.startingEquipment
                                          .map((e) => Text('• ${_formatEquipment(e.id)} ×${e.qty}')),
                                      if (_selected!.level1.startingEquipmentOptions.isNotEmpty) ...[
                                        const SizedBox(height: 16),
                                        Text(
                                          'Options supplémentaires',
                                          style: th.textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        ..._selected!.level1.startingEquipmentOptions
                                            .map((opt) => Text('• $opt')),
                                      ],
                                    ],
                                  ),
                                ),
                    ),
                  ],
                ),
    );
  }
}
