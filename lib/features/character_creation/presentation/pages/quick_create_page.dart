import 'package:flutter/material.dart';
import 'package:sw5e_manager/di/character_creation_module.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/ability_score.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/background_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/character_name.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/class_id.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/species_id.dart';
import 'package:sw5e_manager/features/character_creation/presentation/pages/class_picker_page.dart';
import 'package:sw5e_manager/features/character_creation/presentation/pages/species_picker.dart';

class QuickCreatePage extends StatefulWidget {
  const QuickCreatePage({super.key});

  @override
  State<QuickCreatePage> createState() => _QuickCreatePageState();
}

enum _CreationStep {
  species,
  classes,
  background,
}

class _QuickCreatePageState extends State<QuickCreatePage> {
  final _nameController = TextEditingController(text: 'Rey');

  late final CatalogRepository _catalog = sl<CatalogRepository>();
  late final FinalizeLevel1Character _finalize = sl<FinalizeLevel1Character>();

  final PageController _pageController = PageController();
  int _currentStepIndex = 0;

  bool _loading = true;
  List<String> _species = [];
  List<String> _classes = [];
  List<String> _backgrounds = [];
  List<TraitDef> _selectedSpeciesTraits = [];

  String? _selectedSpecies;
  String? _selectedClass;
  String? _selectedBackground;
  ClassDef? _selectedClassDef;
  bool _classDetailsLoading = false;

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
      if (!mounted) return;
      await Future.wait([
        _refreshSpeciesTraits(),
        _refreshClassDef(),
      ]);
    } catch (e) {
      setState(() {
        _status = 'Erreur de chargement du catalogue: $e';
        _loading = false;
      });
    }
  }

  List<_CreationStep> get _steps => _CreationStep.values;

  bool get _isLastStep => _currentStepIndex == _steps.length - 1;

  bool get _canGoNext {
    switch (_steps[_currentStepIndex]) {
      case _CreationStep.species:
        return _selectedSpecies != null;
      case _CreationStep.classes:
        return _selectedClass != null;
      case _CreationStep.background:
        return _selectedClass != null &&
            _selectedBackground != null &&
            _nameController.text.trim().isNotEmpty;
    }
  }

  Future<void> _createCharacter() async {
    final name = _nameController.text.trim();
    if (_selectedSpecies == null ||
        _selectedClass == null ||
        _selectedBackground == null ||
        name.isEmpty) return;

    setState(() => _status = 'Création en cours…');

    // Récupère la classe pour connaître skills_from et n en choisir 2
    final clazz = await _catalog.getClass(_selectedClass!);
    final from = clazz?.level1.proficiencies.skillsFrom ?? const <String>[];
    final choose = clazz?.level1.proficiencies.skillsChoose ?? 0;
    final chosenSkills = from.take(choose).toSet(); // simple: on prend les 2 premiers

    // MVP: pas d’équipement additionnel (on garde le pack de départ)
    final input = FinalizeLevel1Input(
      name: CharacterName(name),
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

  Future<void> _pickClass() async {
    final chosen = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ClassPickerPage(initialClassId: _selectedClass),
      ),
    );
    if (!mounted) return;
    if (chosen != null && chosen != _selectedClass) {
      setState(() {
        _selectedClass = chosen;
      });
      await _refreshClassDef();
    }
  }

  void _goToStep(int index) {
    if (index == _currentStepIndex) return;
    setState(() => _currentStepIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep() {
    if (!_canGoNext) return;
    if (_isLastStep) {
      _createCharacter();
      return;
    }
    _goToStep(_currentStepIndex + 1);
  }

  void _previousStep() {
    if (_currentStepIndex == 0) return;
    _goToStep(_currentStepIndex - 1);
  }

  Widget _buildStepIndicator(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isActive = index == _currentStepIndex;
        final isCompleted = index < _currentStepIndex;
        final canOpen = index <= _currentStepIndex;
        return ActionChip(
          label: Text(
            switch (step) {
              _CreationStep.species => 'Espèce',
              _CreationStep.classes => 'Classe',
              _CreationStep.background => 'Nom & background',
            },
            style: theme.textTheme.labelLarge?.copyWith(
              color: isActive
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSecondaryContainer,
            ),
          ),
          backgroundColor: isActive
              ? theme.colorScheme.primary
              : isCompleted
                  ? theme.colorScheme.secondaryContainer
                  : theme.colorScheme.surfaceVariant,
          onPressed: canOpen ? () => _goToStep(index) : null,
        );
      }),
    );
  }

  Widget _buildSpeciesStep(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choisis ton espèce', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedSpecies,
            items: _species
                .map((id) => DropdownMenuItem(value: id, child: Text(id)))
                .toList(),
            onChanged: (v) {
              setState(() => _selectedSpecies = v);
              _refreshSpeciesTraits();
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickSpecies,
            icon: const Icon(Icons.travel_explore),
            label: const Text('Explorer les espèces'),
          ),
          const SizedBox(height: 24),
          if (_selectedSpeciesTraits.isNotEmpty) ...[
            Text("Traits d'espèce", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._selectedSpeciesTraits.map((t) {
              final title = (t.name.fr.isNotEmpty ? t.name.fr : t.name.en);
              return Card(
                elevation: 0,
                child: ListTile(
                  dense: true,
                  title: Text(title, style: theme.textTheme.titleSmall),
                  subtitle: Text(
                    t.description,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }),
          ] else
            Text(
              'Sélectionne une espèce pour voir ses traits.',
              style: theme.textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }

  Widget _buildClassStep(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choisis ta classe', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedClass,
            items: _classes
                .map(
                  (id) => DropdownMenuItem(
                    value: id,
                    child: Text(_formatSlug(id)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == _selectedClass) return;
              setState(() => _selectedClass = v);
              _refreshClassDef();
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _classes.isEmpty ? null : _pickClass,
            icon: const Icon(Icons.travel_explore),
            label: const Text('Explorer les classes'),
          ),
          const SizedBox(height: 24),
          if (_classDetailsLoading)
            const Center(child: CircularProgressIndicator())
          else if (_selectedClassDef != null)
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedClassDef!.name.fr.isNotEmpty
                          ? _selectedClassDef!.name.fr
                          : _selectedClassDef!.name.en,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    if (_selectedClass != null)
                      Text(
                        _selectedClass!,
                        style: theme.textTheme.labelMedium,
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('Dé de vie: d${_selectedClassDef!.hitDie}')),
                        Chip(
                          label: Text(
                              _selectedClassDef!.level1.startingCredits != null
                                  ? 'Crédits initiaux: ${_selectedClassDef!.level1.startingCredits}'
                                  : _selectedClassDef!.level1.startingCreditsRoll != null
                                      ? 'Crédits initiaux: ${_selectedClassDef!.level1.startingCreditsRoll}'
                                      : 'Crédits initiaux: —'),
                        ),
                        Chip(
                          label: Text(
                              'Compétences à choisir: ${_selectedClassDef!.level1.proficiencies.skillsChoose}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Options de compétences', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    if (_selectedClassDef!.level1.proficiencies.skillsFrom.isEmpty)
                      const Text('Aucune option définie')
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedClassDef!.level1.proficiencies.skillsFrom
                            .map((id) => Chip(label: Text(_formatSkillOption(id))))
                            .toList(),
                      ),
                    const SizedBox(height: 16),
                    Text('Équipement de départ', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    if (_selectedClassDef!.level1.startingEquipment.isEmpty &&
                        _selectedClassDef!.level1.startingEquipmentOptions.isEmpty)
                      const Text('Aucun équipement défini')
                    else ...[
                      if (_selectedClassDef!.level1.startingEquipment.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _selectedClassDef!.level1.startingEquipment
                              .map(
                                (line) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text('${line.qty} × ${_formatSlug(line.id)}'),
                                ),
                              )
                              .toList(),
                        ),
                      if (_selectedClassDef!.level1.startingEquipmentOptions.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _selectedClassDef!.level1.startingEquipmentOptions
                              .map(
                                (line) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(line),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ],
                ),
              ),
            )
          else
            Text(
              'Sélectionne une classe pour voir ses détails.',
              style: theme.textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }

  Widget _buildFinalizeStep(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Identité du personnage', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Ex: Rey',
              labelText: 'Nom du personnage',
            ),
          ),
          const SizedBox(height: 24),
          Text('Background', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedBackground,
            items: _backgrounds
                .map(
                  (id) => DropdownMenuItem(
                    value: id,
                    child: Text(_formatSlug(id)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedBackground = v),
          ),
          const SizedBox(height: 24),
          Text(
            'Clique sur "Terminer" pour finaliser le personnage.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
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

  Future<void> _refreshClassDef() async {
    final id = _selectedClass;
    if (id == null) {
      setState(() {
        _selectedClassDef = null;
        _classDetailsLoading = false;
      });
      return;
    }
    setState(() {
      _classDetailsLoading = true;
    });
    try {
      final cls = await _catalog.getClass(id);
      if (!mounted) return;
      setState(() {
        _selectedClassDef = cls;
        _classDetailsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Erreur de chargement de la classe: $e';
        _classDetailsLoading = false;
      });
    }
  }

  String _formatSlug(String slug) {
    if (slug == 'any') {
      return "n'importe quelle compétence";
    }
    return slug
        .split(RegExp(r'[-_]'))
        .map(
          (part) => part.isEmpty
              ? part
          : part[0].toUpperCase() + part.substring(1),
        )
        .join(' ');
  }

  String _formatSkillOption(String slug) {
    if (slug == 'any') {
      return "N'importe quelle compétence";
    }
    return _formatSlug(slug);
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Create (MVP)')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
                _buildStepIndicator(context),
                const SizedBox(height: 16),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildSpeciesStep(context),
                      _buildClassStep(context),
                      _buildFinalizeStep(context),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      if (_currentStepIndex > 0)
                        OutlinedButton.icon(
                          onPressed: _previousStep,
                          icon: const Icon(Icons.chevron_left),
                          label: const Text('Précédent'),
                        ),
                      if (_currentStepIndex > 0) const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _canGoNext ? _nextStep : null,
                          icon: Icon(_isLastStep ? Icons.check : Icons.chevron_right),
                          label: Text(_isLastStep ? 'Terminer' : 'Suivant'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_status.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_status, style: theme.textTheme.bodyMedium),
                  ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
