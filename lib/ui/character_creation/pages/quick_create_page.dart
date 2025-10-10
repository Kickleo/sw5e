/// ---------------------------------------------------------------------------
/// Fichier : lib/ui/character_creation/pages/quick_create_page.dart
/// Rôle : Vue Flutter de l'assistant de création rapide, liée au QuickCreateBloc.
/// Dépendances : flutter_bloc, Riverpod (connectivité), QuickCreateBloc,
///        ServiceLocator (résolution des use cases),
///        use cases loadQuickCreateCatalog/loadSpeciesDetails/loadClassDetails,
///        routes UI.
/// Exemple d'usage : routage GoRouter -> const QuickCreatePage().
/// ---------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sw5e_manager/common/di/service_locator.dart';
import 'package:sw5e_manager/common/errors/app_failure.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/core/connectivity/connectivity_providers.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_class_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_quick_create_catalog.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/presentation/character_creation/blocs/quick_create_bloc.dart';
import 'package:sw5e_manager/presentation/character_creation/states/quick_create_state.dart';
import 'package:sw5e_manager/ui/character_creation/pages/class_picker_page.dart';
import 'package:sw5e_manager/ui/character_creation/pages/species_picker.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/character_section_divider.dart';

class QuickCreatePage extends ConsumerStatefulWidget {
  /// Constructeur standard.
  const QuickCreatePage({super.key});

  @override
  ConsumerState<QuickCreatePage> createState() => _QuickCreatePageState();
}

class _QuickCreatePageState extends ConsumerState<QuickCreatePage> {
  late final PageController _pageController;
  late final TextEditingController _nameController;
  late final QuickCreateBloc _bloc;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _nameController = TextEditingController();
    final LoadQuickCreateCatalog loadCatalog =
        ServiceLocator.resolve<LoadQuickCreateCatalog>();
    final LoadSpeciesDetails loadSpeciesDetails =
        ServiceLocator.resolve<LoadSpeciesDetails>();
    final LoadClassDetails loadClassDetails =
        ServiceLocator.resolve<LoadClassDetails>();
    final FinalizeLevel1Character finalize =
        ServiceLocator.resolve<FinalizeLevel1Character>();
    final AppLogger logger = ServiceLocator.resolve<AppLogger>();

    _bloc = QuickCreateBloc(
      loadQuickCreateCatalog: loadCatalog,
      loadSpeciesDetails: loadSpeciesDetails,
      loadClassDetails: loadClassDetails,
      finalizeLevel1Character: finalize,
      logger: logger,
    )..add(const QuickCreateStarted());

    final String initialName = _bloc.state.characterName;
    if (initialName.isNotEmpty) {
      _nameController.text = initialName;
    }
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _pageController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onNameChanged() {
    _bloc.add(QuickCreateNameChanged(_nameController.text));
  }

  @override
  Widget build(BuildContext context) {
    final connectivityStatus = ref
        .watch(connectivityStatusProvider)
        .maybeWhen(
          data: (status) => status,
          orElse: () => ConnectivityStatus.connected,
        );

    return BlocProvider<QuickCreateBloc>.value(
      value: _bloc,
      child: _QuickCreateView(
        pageController: _pageController,
        nameController: _nameController,
        connectivityStatus: connectivityStatus,
      ),
    );
  }
}

class _QuickCreateView extends StatelessWidget {
  const _QuickCreateView({
    required this.pageController,
    required this.nameController,
    required this.connectivityStatus,
  });

  final PageController pageController;
  final TextEditingController nameController;
  final ConnectivityStatus connectivityStatus;

  void _handleCompletion(BuildContext context, QuickCreateState state) {
    final completion = state.completion;
    if (completion == null) {
      return;
    }
    switch (completion) {
      case QuickCreateSuccess(:final Character character):
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Personnage créé'),
            content: Text(
              'Nom: ${character.name.value}\n'
              'Espèce: ${character.speciesId.value}\n'
              'Classe: ${character.classId.value}\n'
              'BG: ${character.backgroundId.value}\n\n'
              'HP: ${character.hitPoints.value}\n'
              'Défense: ${character.defense.value}\n'
              'Initiative: ${character.initiative.value}\n'
              'Crédits: ${character.credits.value}\n'
              'Inventaire: ${character.inventory.map((line) => "${line.itemId.value} x${line.quantity.value}").join(", ")}\n'
              'Compétences: ${character.skills.map((skill) => skill.skillId).join(", ")}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
        break;
      case QuickCreateFailure(:final AppFailure failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.toDisplayMessage(includeCode: true))),
        );
        break;
    }
    context.read<QuickCreateBloc>().add(const QuickCreateCompletionCleared());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<QuickCreateBloc, QuickCreateState>(
          listenWhen: (prev, curr) => prev.completion != curr.completion,
          listener: _handleCompletion,
        ),
        BlocListener<QuickCreateBloc, QuickCreateState>(
          listenWhen: (prev, curr) => prev.characterName != curr.characterName,
          listener: (context, state) {
            if (nameController.text != state.characterName) {
              nameController.text = state.characterName;
            }
          },
        ),
        BlocListener<QuickCreateBloc, QuickCreateState>(
          listenWhen: (prev, curr) => prev.stepIndex != curr.stepIndex,
          listener: (context, state) {
            if (!pageController.hasClients) {
              return;
            }
            if (pageController.page?.round() == state.stepIndex) {
              return;
            }
            pageController.animateToPage(
              state.stepIndex,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
      child: BlocBuilder<QuickCreateBloc, QuickCreateState>(
        builder: (context, state) {
          final bloc = context.read<QuickCreateBloc>();
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Création rapide — Étape ${state.stepIndex + 1}/${QuickCreateStep.values.length}',
              ),
            ),
            body: Column(
              children: [
                if (connectivityStatus == ConnectivityStatus.disconnected)
                  MaterialBanner(
                    backgroundColor: Colors.orange.shade100,
                    content: const Text(
                      'Mode hors ligne : certaines fonctionnalités réseau sont indisponibles.',
                    ),
                    actions: const [SizedBox.shrink()],
                  ),
                if (state.statusMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 8),
                        Expanded(child: Text(state.statusMessage!)),
                      ],
                    ),
                  ),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(state.errorMessage!)),
                      ],
                    ),
                  ),
                Expanded(
                  child: state.isLoadingCatalog
                      ? const Center(child: CircularProgressIndicator())
                      : PageView(
                          controller: pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _SpeciesStep(
                              species: state.species,
                              selectedSpecies: state.selectedSpecies,
                              traits: state.selectedSpeciesTraits,
                              onSelect: (value) {
                                if (value != null) {
                                  bloc.add(QuickCreateSpeciesSelected(value));
                                }
                              },
                              onOpenPicker: () async {
                                final chosen = await context.pushNamed<String>(
                                  SpeciesPickerPage.routeName,
                                  extra: state.selectedSpecies,
                                );
                                if (chosen != null) {
                                  bloc.add(QuickCreateSpeciesSelected(chosen));
                                }
                              },
                            ),
                            _AbilitiesStep(
                              mode: state.abilityMode,
                              assignments: state.abilityAssignments,
                              pool: state.abilityPool,
                              onModeChanged: (mode) =>
                                  bloc.add(QuickCreateAbilityModeChanged(mode)),
                              onReroll: () => bloc.add(
                                const QuickCreateAbilityScoresRerolled(),
                              ),
                              onAssign: (ability, value) => bloc.add(
                                QuickCreateAbilityAssigned(ability, value),
                              ),
                            ),
                            _ClassStep(
                              classes: state.classes,
                              selectedClass: state.selectedClass,
                              classDef: state.selectedClassDef,
                              isLoadingDetails: state.isLoadingClassDetails,
                              onSelect: (value) {
                                if (value != null) {
                                  bloc.add(QuickCreateClassSelected(value));
                                }
                              },
                              onOpenPicker: () async {
                                final chosen = await context.pushNamed<String>(
                                  ClassPickerPage.routeName,
                                  extra: state.selectedClass,
                                );
                                if (chosen != null) {
                                  bloc.add(QuickCreateClassSelected(chosen));
                                }
                              },
                            ),
                            _SkillStep(
                              availableSkills: state.availableSkills,
                              skillDefinitions: state.skillDefinitions,
                              chosenSkills: state.chosenSkills,
                              requiredCount: state.skillChoicesRequired,
                              onToggle: (skillId) =>
                                  bloc.add(QuickCreateSkillToggled(skillId)),
                            ),
                            _EquipmentStep(
                              isLoading: state.isLoadingEquipment,
                              classDef: state.selectedClassDef,
                              equipmentDefinitions: state.equipmentDefinitions,
                              equipmentIds: state.equipmentList,
                              chosenEquipment: state.chosenEquipment,
                              useStartingEquipment: state.useStartingEquipment,
                              totalWeightG: state.totalInventoryWeightG,
                              capacityG: state.carryingCapacityLimitG,
                              totalCost: state.totalPurchasedEquipmentCost,
                              remainingCredits: state.remainingCredits,
                              availableCredits: state.availableCredits,
                              onToggleStartingEquipment: (usePackage) =>
                                  bloc.add(
                                    QuickCreateUseStartingEquipmentChanged(
                                      usePackage,
                                    ),
                                  ),
                              onQuantityChanged: (id, quantity) => bloc.add(
                                QuickCreateEquipmentQuantityChanged(
                                  id,
                                  quantity,
                                ),
                              ),
                            ),
                            _BackgroundStep(
                              backgrounds: state.backgrounds,
                              selectedBackground: state.selectedBackground,
                              nameController: nameController,
                              onBackgroundChanged: (value) {
                                if (value != null) {
                                  bloc.add(
                                    QuickCreateBackgroundSelected(value),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                ),
                _QuickCreateControls(
                  state: state,
                  onPrevious: () =>
                      bloc.add(const QuickCreatePreviousStepRequested()),
                  onNext: () => bloc.add(const QuickCreateNextStepRequested()),
                  onCreate: () => bloc.add(const QuickCreateSubmitted()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SpeciesStep extends StatelessWidget {
  const _SpeciesStep({
    required this.species,
    required this.selectedSpecies,
    required this.traits,
    required this.onSelect,
    required this.onOpenPicker,
  });

  final List<String> species;
  final String? selectedSpecies;
  final List<TraitDef> traits;
  final ValueChanged<String?> onSelect;
  final VoidCallback onOpenPicker;

  String _titleCase(String slug) => slug
      .split(RegExp(r'[-_]'))
      .map(
        (part) =>
            part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
      )
      .join(' ');

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedSpecies,
                decoration: const InputDecoration(
                  labelText: 'Espèce',
                  border: OutlineInputBorder(),
                ),
                items: species
                    .map(
                      (id) => DropdownMenuItem(
                        value: id,
                        child: Text(_titleCase(id)),
                      ),
                    )
                    .toList(),
                onChanged: onSelect,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onOpenPicker,
              icon: const Icon(Icons.search),
              label: const Text('Parcourir'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (traits.isEmpty)
          const Text('Aucun trait spécifique pour cette espèce.')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Traits d’espèce',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...traits.map(
                (trait) => Card(
                  child: ListTile(
                    title: Text(
                      trait.name.fr.isNotEmpty ? trait.name.fr : trait.name.en,
                    ),
                    subtitle: Text(trait.description),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _AbilitiesStep extends HookWidget {
  const _AbilitiesStep({
    required this.mode,
    required this.assignments,
    required this.pool,
    required this.onModeChanged,
    required this.onReroll,
    required this.onAssign,
  });

  final AbilityGenerationMode mode;
  final Map<String, int?> assignments;
  final List<int> pool;
  final ValueChanged<AbilityGenerationMode> onModeChanged;
  final VoidCallback onReroll;
  final void Function(String ability, int? value) onAssign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final abilityOrder = QuickCreateState.abilityOrder;
    final abilityLabels = QuickCreateState.abilityLabels;
    final abilityAbbreviations = QuickCreateState.abilityAbbreviations;

    final poolCounts = <int, int>{};
    for (final value in pool) {
      poolCounts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }
    final sortedPoolEntries = poolCounts.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final assignedCounts = <int, int>{};
    for (final entry in assignments.entries) {
      final value = entry.value;
      if (value == null) continue;
      assignedCounts.update(value, (count) => count + 1, ifAbsent: () => 1);
    }

    Widget buildControl(String ability) {
      final currentValue = assignments[ability];
      if (mode == AbilityGenerationMode.manual) {
        return _ManualAbilityField(
          key: ValueKey('manual-$ability'),
          initialValue: currentValue,
          onChanged: (value) => onAssign(ability, value),
        );
      }

      final optionValues = <int>{};
      for (final entry in poolCounts.entries) {
        final value = entry.key;
        final available = entry.value;
        var used = assignedCounts[value] ?? 0;
        if (currentValue == value && used > 0) {
          used -= 1;
        }
        if (used < available) {
          optionValues.add(value);
        }
      }
      if (currentValue != null) {
        optionValues.add(currentValue);
      }
      final sortedOptions = optionValues.toList()
        ..sort((a, b) => b.compareTo(a));

      return DropdownButtonFormField<int?>(
        key: ValueKey('dropdown-$ability-${mode.name}'),
        initialValue: currentValue,
        decoration: const InputDecoration(
          labelText: 'Score',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('—')),
          ...sortedOptions.map(
            (value) => DropdownMenuItem<int?>(
              value: value,
              child: Text(value.toString()),
            ),
          ),
        ],
        onChanged: (value) => onAssign(ability, value),
      );
    }

    String modifierText(int? score) {
      if (score == null) return 'Mod —';
      final modifier = AbilityScore(score).modifier;
      final sign = modifier >= 0 ? '+' : '';
      return 'Mod $sign$modifier';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Attribuez vos caractéristiques',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: RadioGroup<AbilityGenerationMode>(
            groupValue: mode,
            onChanged: (value) {
              if (value != null) onModeChanged(value);
            },
            child: Column(
              children: [
                RadioListTile<AbilityGenerationMode>(
                  value: AbilityGenerationMode.standardArray,
                  title: const Text('Tableau standard'),
                  subtitle: const Text(
                    'Utiliser les scores fixes 15, 14, 13, 12, 10 et 8.',
                  ),
                ),
                const Divider(height: 0),
                RadioListTile<AbilityGenerationMode>(
                  value: AbilityGenerationMode.roll,
                  title: const Text('Lancer les dés'),
                  subtitle: const Text(
                    'Lancez 4d6, conservez les 3 meilleurs et assignez les 6 scores obtenus.',
                  ),
                ),
              if (mode == AbilityGenerationMode.roll)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: onReroll,
                      icon: const Icon(Icons.casino),
                      label: const Text('Lancer les dés'),
                    ),
                  ),
                ),
                const Divider(height: 0),
                RadioListTile<AbilityGenerationMode>(
                  value: AbilityGenerationMode.manual,
                  title: const Text('Saisie manuelle'),
                  subtitle: const Text(
                    'Entrez vous-même les scores obtenus ailleurs et assignez-les.',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (mode != AbilityGenerationMode.manual) ...[
          Text('Scores disponibles', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (sortedPoolEntries.isEmpty)
            const Text('Aucun score généré pour le moment.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in sortedPoolEntries)
                  Chip(
                    label: Text(
                      entry.value > 1
                          ? '${entry.key} ×${entry.value}'
                          : entry.key.toString(),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 16),
        ] else ...[
          const Text('Chaque champ accepte une valeur entre 1 et 20.'),
          const SizedBox(height: 16),
        ],
        ...abilityOrder.map((ability) {
          final label = abilityLabels[ability] ?? ability.toUpperCase();
          final abbr = abilityAbbreviations[ability] ?? ability.toUpperCase();
          final currentValue = assignments[ability];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$label ($abbr)',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        modifierText(currentValue),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  buildControl(ability),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        const Text(
          'Astuce : pour calculer le modificateur, soustrayez 10 du score et divisez par 2 (arrondi à l’inférieur).',
        ),
      ],
    );
  }
}

class _ManualAbilityField extends HookWidget {
  const _ManualAbilityField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  final int? initialValue;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(
      text: initialValue?.toString() ?? '',
    );
    final errorText = useState<String?>(null);

    useEffect(() {
      final newText = initialValue?.toString() ?? '';
      if (controller.text != newText) {
        controller.value = controller.value.copyWith(text: newText);
      }
      if (newText.isNotEmpty) {
        final value = int.tryParse(newText);
        if (value != null &&
            value >= AbilityScore.min &&
            value <= AbilityScore.max) {
          errorText.value = null;
        }
      }
      return null;
    }, [initialValue]);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Score',
        border: const OutlineInputBorder(),
        errorText: errorText.value,
      ),
      onChanged: (text) {
        final trimmed = text.trim();
        if (trimmed.isEmpty) {
          errorText.value = 'Requis';
          onChanged(null);
          return;
        }
        final value = int.tryParse(trimmed);
        if (value == null) {
          errorText.value = 'Entrez un nombre';
          onChanged(null);
          return;
        }
        if (value < AbilityScore.min || value > AbilityScore.max) {
          errorText.value =
              'Doit être entre ${AbilityScore.min} et ${AbilityScore.max}';
          onChanged(null);
          return;
        }
        errorText.value = null;
        onChanged(value);
      },
    );
  }
}

class _ClassStep extends StatelessWidget {
  const _ClassStep({
    required this.classes,
    required this.selectedClass,
    required this.classDef,
    required this.isLoadingDetails,
    required this.onSelect,
    required this.onOpenPicker,
  });

  final List<String> classes;
  final String? selectedClass;
  final ClassDef? classDef;
  final bool isLoadingDetails;
  final ValueChanged<String?> onSelect;
  final VoidCallback onOpenPicker;

  String _titleCase(String slug) => slug
      .split(RegExp(r'[-_]'))
      .map(
        (part) =>
            part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
      )
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final classDefData = classDef;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Classe',
                  border: OutlineInputBorder(),
                ),
                items: classes
                    .map(
                      (id) => DropdownMenuItem(
                        value: id,
                        child: Text(_titleCase(id)),
                      ),
                    )
                    .toList(),
                onChanged: onSelect,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onOpenPicker,
              icon: const Icon(Icons.search),
              label: const Text('Détails'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoadingDetails)
          const Center(child: CircularProgressIndicator())
        else if (classDefData == null)
          const Text('Aucune classe sélectionnée.')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classDefData.name.fr.isNotEmpty
                    ? classDefData.name.fr
                    : classDefData.name.en,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('Dé de vie : d${classDefData.hitDie}'),
              const SizedBox(height: 12),
              Text(
                'Compétences : choisir ${classDefData.level1.proficiencies.skillsChoose} (étape suivante)',
              ),
              const SizedBox(height: 12),
              Text(
                'Équipement de départ :\n${classDefData.level1.startingEquipment.map((e) => '• ${e.id} ×${e.qty}').join('\n')}',
              ),
            ],
          ),
      ],
    );
  }
}

class _SkillStep extends StatelessWidget {
  const _SkillStep({
    required this.availableSkills,
    required this.skillDefinitions,
    required this.chosenSkills,
    required this.requiredCount,
    required this.onToggle,
  });

  final List<String> availableSkills;
  final Map<String, SkillDef> skillDefinitions;
  final Set<String> chosenSkills;
  final int requiredCount;
  final ValueChanged<String> onToggle;

  String _titleCase(String slug) => slug
      .split(RegExp(r'[-_]'))
      .map(
        (part) =>
            part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
      )
      .join(' ');

  String _abilityLabel(String ability) {
    switch (ability.toLowerCase()) {
      case 'str':
        return 'FOR';
      case 'dex':
        return 'DEX';
      case 'con':
        return 'CON';
      case 'int':
        return 'INT';
      case 'wis':
        return 'SAG';
      case 'cha':
        return 'CHA';
      default:
        return ability.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (requiredCount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'La classe sélectionnée n’offre aucun choix de compétence supplémentaire.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (availableSkills.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Aucune compétence disponible pour cette classe. Vérifiez le catalogue.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final sortedSkills = List<String>.from(availableSkills);
    sortedSkills.sort();
    final canSelectMore = chosenSkills.length < requiredCount;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Choisissez $requiredCount compétence${requiredCount > 1 ? 's' : ''} (${chosenSkills.length}/$requiredCount sélectionnées).',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...sortedSkills.map((skillId) {
          final skillDef = skillDefinitions[skillId];
          final selected = chosenSkills.contains(skillId);
          final canToggle = selected || canSelectMore;
          final ability = skillDef?.ability ?? '';
          final subtitle = ability.isEmpty
              ? null
              : Text('Basée sur ${_abilityLabel(ability)}');
          return Card(
            child: CheckboxListTile(
              value: selected,
              onChanged: canToggle ? (_) => onToggle(skillId) : null,
              title: Text(_titleCase(skillId)),
              subtitle: subtitle,
            ),
          );
        }),
        if (!canSelectMore)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Vous avez atteint le nombre maximum de compétences sélectionnées. Décochez-en une pour en choisir une autre.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _EquipmentStep extends HookWidget {
  const _EquipmentStep({
    required this.isLoading,
    required this.classDef,
    required this.equipmentDefinitions,
    required this.equipmentIds,
    required this.chosenEquipment,
    required this.useStartingEquipment,
    required this.totalWeightG,
    required this.capacityG,
    required this.totalCost,
    required this.remainingCredits,
    required this.availableCredits,
    required this.onToggleStartingEquipment,
    required this.onQuantityChanged,
  });

  final bool isLoading;
  final ClassDef? classDef;
  final Map<String, EquipmentDef> equipmentDefinitions;
  final List<String> equipmentIds;
  final Map<String, int> chosenEquipment;
  final bool useStartingEquipment;
  final int? totalWeightG;
  final int? capacityG;
  final int totalCost;
  final int remainingCredits;
  final int availableCredits;
  final ValueChanged<bool> onToggleStartingEquipment;
  final void Function(String id, int quantity) onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final classData = classDef;
    if (classData == null) {
      return const Center(
        child: Text('Choisissez une classe pour configurer votre équipement.'),
      );
    }
    if (equipmentDefinitions.isEmpty) {
      return const Center(child: Text('Catalogue d\'équipement indisponible.'));
    }

    final queryController = useTextEditingController();
    final query = useState('');

    useEffect(() {
      void listener() => query.value = queryController.text;
      queryController.addListener(listener);
      return () => queryController.removeListener(listener);
    }, [queryController]);

    final filteredIds = useMemoized(() {
      final lower = query.value.toLowerCase().trim();
      if (lower.isEmpty) {
        return List<String>.from(equipmentIds);
      }
      return equipmentIds
          .where((id) {
            final def = equipmentDefinitions[id];
            if (def == null) return false;
            final fr = def.name.fr.toLowerCase();
            final en = def.name.en.toLowerCase();
            return fr.contains(lower) ||
                en.contains(lower) ||
                id.contains(lower);
          })
          .toList(growable: false);
    }, [equipmentIds, equipmentDefinitions, query.value]);

    final startingWeightG = _computeStartingWeight(classData);
    final purchasesWeightG = _computePurchasesWeight();
    final displayTotalWeight = totalWeightG != null
        ? _formatWeight(totalWeightG!)
        : '—';
    final displayCapacity = capacityG != null ? _formatWeight(capacityG!) : '—';
    final overCapacity =
        capacityG != null && totalWeightG != null && totalWeightG! > capacityG!;
    final overCredits = availableCredits >= 0 && totalCost > availableCredits;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crédits de départ : ${availableCredits}cr',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (classData.level1.startingCreditsRoll != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Jet alternatif : ${classData.level1.startingCreditsRoll}',
            ),
          ),
        const SizedBox(height: 16),
        SwitchListTile.adaptive(
          value: useStartingEquipment,
          contentPadding: EdgeInsets.zero,
          onChanged: onToggleStartingEquipment,
          title: const Text('Prendre l\'équipement de départ de la classe'),
          subtitle: classData.level1.startingEquipment.isEmpty
              ? const Text(
                  'Cette classe ne fournit pas d\'équipement spécifique par défaut.',
                )
              : Text(
                  classData.level1.startingEquipment
                      .map(
                        (line) => '• ${_equipmentLabel(line.id)} ×${line.qty}',
                      )
                      .join('\n'),
                ),
        ),
        if (classData.level1.startingEquipmentOptions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Options d\'équipement de départ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...classData.level1.startingEquipmentOptions.map(
                      (option) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(option),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (chosenEquipment.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Achats en cours',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...chosenEquipment.entries.map((entry) {
                  final def = equipmentDefinitions[entry.key];
                  final label = def != null ? def.name.fr : entry.key;
                  final cost = def?.cost ?? 0;
                  return Text(
                    '• $label ×${entry.value} (${cost * entry.value}cr)',
                  );
                }),
              ],
            ),
          ),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Text('Coût des achats : ${totalCost}cr'),
            Text(
              'Crédits restants : ${remainingCredits}cr',
              style: TextStyle(
                color: remainingCredits < 0 ? Colors.red : null,
              ),
            ),
            Text('Poids total : $displayTotalWeight'),
            Text('Capacité : $displayCapacity'),
            if (useStartingEquipment && startingWeightG != null)
              Text(
                'Équipement de départ : ${_formatWeight(startingWeightG)}',
              ),
            if (chosenEquipment.isNotEmpty && purchasesWeightG != null)
              Text('Achats : ${_formatWeight(purchasesWeightG)}'),
          ],
        ),
        if (overCredits)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Vous dépassez vos crédits de départ.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (overCapacity)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Le poids total dépasse votre capacité de portance.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: queryController,
          decoration: const InputDecoration(
            labelText: 'Rechercher un objet…',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: header),
          if (filteredIds.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Aucun équipement ne correspond à votre recherche.',
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final id = filteredIds[index];
                  final def = equipmentDefinitions[id];
                  if (def == null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(title: Text(id)),
                        if (index < filteredIds.length - 1)
                          const CharacterSectionDivider(
                            spacing: 8,
                            thickness: 1,
                          ),
                      ],
                    );
                  }
                  final qty = chosenEquipment[id] ?? 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        title: Text(def.name.fr),
                        subtitle: Text(
                          '${def.cost}cr · ${_formatWeight(def.weightG)} · ${def.type}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: qty > 0
                                  ? () => onQuantityChanged(id, qty - 1)
                                  : null,
                            ),
                            SizedBox(
                              width: 32,
                              child: Text('$qty', textAlign: TextAlign.center),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => onQuantityChanged(id, qty + 1),
                            ),
                          ],
                        ),
                      ),
                      if (index < filteredIds.length - 1)
                        const CharacterSectionDivider(
                          spacing: 8,
                          thickness: 1,
                        ),
                    ],
                  );
                },
                childCount: filteredIds.length,
              ),
            ),
        ],
      ),
    );
  }

  String _equipmentLabel(String id) {
    final def = equipmentDefinitions[id];
    return def != null ? def.name.fr : id;
  }

  int? _computeStartingWeight(ClassDef def) {
    if (!useStartingEquipment) {
      return 0;
    }
    var total = 0;
    for (final line in def.level1.startingEquipment) {
      final eq = equipmentDefinitions[line.id];
      if (eq == null) {
        return null;
      }
      total += eq.weightG * line.qty;
    }
    return total;
  }

  int? _computePurchasesWeight() {
    var total = 0;
    for (final entry in chosenEquipment.entries) {
      final eq = equipmentDefinitions[entry.key];
      if (eq == null) {
        return null;
      }
      total += eq.weightG * entry.value;
    }
    return total;
  }

  String _formatWeight(int grams) {
    final kilograms = grams / 1000;
    if (kilograms >= 10) {
      return '${kilograms.toStringAsFixed(1)} kg';
    }
    return '${kilograms.toStringAsFixed(2)} kg';
  }
}

class _BackgroundStep extends StatelessWidget {
  const _BackgroundStep({
    required this.backgrounds,
    required this.selectedBackground,
    required this.nameController,
    required this.onBackgroundChanged,
  });

  final List<String> backgrounds;
  final String? selectedBackground;
  final TextEditingController nameController;
  final ValueChanged<String?> onBackgroundChanged;

  String _titleCase(String slug) => slug
      .split(RegExp(r'[-_]'))
      .map(
        (part) =>
            part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
      )
      .join(' ');

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom du personnage',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedBackground,
          decoration: const InputDecoration(
            labelText: 'Historique',
            border: OutlineInputBorder(),
          ),
          items: backgrounds
              .map(
                (id) =>
                    DropdownMenuItem(value: id, child: Text(_titleCase(id))),
              )
              .toList(),
          onChanged: onBackgroundChanged,
        ),
        const SizedBox(height: 24),
        const Text(
          'Pensez à vérifier votre équipement avant de finaliser la création.',
        ),
      ],
    );
  }
}

class _QuickCreateControls extends StatelessWidget {
  const _QuickCreateControls({
    required this.state,
    required this.onPrevious,
    required this.onNext,
    required this.onCreate,
  });

  final QuickCreateState state;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: state.canGoPrevious ? onPrevious : null,
                child: const Text('Précédent'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: state.currentStep == QuickCreateStep.background
                  ? FilledButton.icon(
                      onPressed: state.canCreate && !state.isCreating
                          ? onCreate
                          : null,
                      icon: state.isCreating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: const Text('Créer'),
                    )
                  : FilledButton(
                      onPressed: state.canGoNext ? onNext : null,
                      child: const Text('Suivant'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
