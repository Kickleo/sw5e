import 'package:flutter/material.dart';
import 'package:sw5e_manager/di/character_creation_module.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/ability_score.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/background_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_name.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/class_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/species_id.dart';
import 'package:sw5e_manager/features/character_creation/presentation/pages/species_picker.dart';

class QuickCreatePage extends StatefulWidget {
  const QuickCreatePage({super.key});

  @override
  State<QuickCreatePage> createState() => _QuickCreatePageState();
}

class _QuickCreatePageState extends State<QuickCreatePage> {
  final _nameController = TextEditingController(text: 'Rey');

  late final CatalogRepository _catalog = sl<CatalogRepository>();
  late final FinalizeLevel1Character _finalize = sl<FinalizeLevel1Character>();

  bool _loading = true;
  List<String> _species = [];
  List<String> _classes = [];
  List<String> _backgrounds = [];
  List<TraitDef> _selectedSpeciesTraits = [];

  String? _selectedSpecies;
  String? _selectedClass;
  String? _selectedBackground;

  // pour affichage simple
  String _status = '';

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final sp = await _catalog.listSpecies();
      final cl = await _catalog.listClasses();
      final bg = await _catalog.listBackgrounds();
      setState(() {
        _species = sp;
        _classes = cl;
        _backgrounds = bg;
        _selectedSpecies = sp.isNotEmpty ? sp.first : null;
        _selectedClass = cl.isNotEmpty ? cl.first : null;
        _selectedBackground = bg.isNotEmpty ? bg.first : null;
        _loading = false;
      });
      if (mounted) {
        await _refreshSpeciesTraits();
      }
    } catch (e) {
      setState(() {
        _status = 'Erreur de chargement du catalogue: $e';
        _loading = false;
      });
    }
  }

  Future<void> _createCharacter() async {
    if (_selectedSpecies == null || _selectedClass == null || _selectedBackground == null) return;

    setState(() => _status = 'Création en cours…');

    // Récupère la classe pour connaître skills_from et n en choisir 2
    final clazz = await _catalog.getClass(_selectedClass!);
    final from = clazz?.level1.proficiencies.skillsFrom ?? const <String>[];
    final choose = clazz?.level1.proficiencies.skillsChoose ?? 0;
    final chosenSkills = from.take(choose).toSet(); // simple: on prend les 2 premiers

    // MVP: pas d’équipement additionnel (on garde le pack de départ)
    final input = FinalizeLevel1Input(
      name: CharacterName(_nameController.text),
      speciesId: SpeciesId(_selectedSpecies!),
      classId: ClassId(_selectedClass!),
      backgroundId: BackgroundId(_selectedBackground!),
      baseAbilities: {
        'str': AbilityScore(10),
        'dex': AbilityScore(12),
        'con': AbilityScore(14),
        'int': AbilityScore(10),
        'wis': AbilityScore(10),
        'cha': AbilityScore(10),
      },
      chosenSkills: chosenSkills,
      chosenEquipment: const <ChosenEquipmentLine>[
        // Exemple si tu veux forcer un ajout: ChosenEquipmentLine(itemId: EquipmentItemId('blaster-pistol'), quantity: Quantity(1))
      ],
    );

    final result = await _finalize(input);
    if (!mounted) return;

    result.match(
      ok: (c) {
        setState(() => _status = 'OK: ${c.name.value} • HP ${c.hitPoints.value} • DEF ${c.defense.value} • INIT ${c.initiative.value} • ${c.credits.value} cr');
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Personnage créé'),
            content: Text(
              'Nom: ${c.name.value}\n'
              'Espèce: ${c.speciesId.value}\n'
              'Classe: ${c.classId.value}\n'
              'BG: ${c.backgroundId.value}\n\n'
              'HP: ${c.hitPoints.value}\n'
              'Défense: ${c.defense.value}\n'
              'Initiative: ${c.initiative.value}\n'
              'Crédits: ${c.credits.value}\n'
              'Inventaire: ${c.inventory.map((l) => "${l.itemId.value} x${l.quantity.value}").join(", ")}\n'
              'Compétences: ${c.skills.map((s) => s.skillId).join(", ")}',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fermer')),
            ],
          ),
        );
      },
      err: (e) {
        setState(() => _status = 'Erreur: ${e.code} ${e.message ?? ""}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.code} ${e.message ?? ""}')),
        );
      },
    );
  }

  Future<void> _pickSpecies() async {
    final chosen = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => SpeciesPickerPage(initialSpeciesId: _selectedSpecies),
      ),
    );
    if (!mounted) return;
    if (chosen != null && chosen != _selectedSpecies) {
      setState(() {
        _selectedSpecies = chosen;
      });
      await _refreshSpeciesTraits();
    }
  }

  Future<void> _refreshSpeciesTraits() async {
    final id = _selectedSpecies;
    if (id == null) {
      setState(() => _selectedSpeciesTraits = []);
      return;
    }
    final sp = await _catalog.getSpecies(id);
    final traits = <TraitDef>[];
    for (final tid in sp?.traitIds ?? const <String>[]) {
      final t = await _catalog.getTrait(tid);
      if (t != null) traits.add(t);
    }
    if (!mounted) return;
    setState(() => _selectedSpeciesTraits = traits);
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Create (MVP)')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text('Nom du personnage', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ex: Rey',
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Espèce', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSpecies,
                    items: _species.map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
                    onChanged: (v) {
                      setState(() => _selectedSpecies = v);
                      _refreshSpeciesTraits();
                    },
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _pickSpecies,
                      icon: const Icon(Icons.travel_explore),
                      label: const Text('Explorer les espèces'),
                    ),
                  ),

                  const SizedBox(height: 16),
                  if (_selectedSpeciesTraits.isNotEmpty) ...[
                    Text('Traits d\'espèce', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ..._selectedSpeciesTraits.map((t) {
                      final title = (t.name.fr.isNotEmpty ? t.name.fr : t.name.en);
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(title, style: theme.textTheme.titleSmall),
                        subtitle: Text(
                          t.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],

                  Text('Classe', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedClass,
                    items: _classes.map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
                    onChanged: (v) => setState(() => _selectedClass = v),
                  ),
                  const SizedBox(height: 16),

                  Text('Background', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBackground,
                    items: _backgrounds.map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
                    onChanged: (v) => setState(() => _selectedBackground = v),
                  ),
                  const SizedBox(height: 24),

                  FilledButton.icon(
                    onPressed: _createCharacter,
                    icon: const Icon(Icons.check),
                    label: const Text('Créer le personnage'),
                  ),

                  const SizedBox(height: 16),
                  Text(_status, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
