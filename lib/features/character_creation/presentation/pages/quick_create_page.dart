import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sw5e_manager/core/connectivity/connectivity_providers.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';
import 'package:sw5e_manager/features/character_creation/domain/value_objects/ability_score.dart';
import 'package:sw5e_manager/features/character_creation/presentation/pages/class_picker_page.dart';
import 'package:sw5e_manager/features/character_creation/presentation/pages/species_picker.dart';
import 'package:sw5e_manager/features/character_creation/presentation/viewmodels/quick_create_state.dart';
import 'package:sw5e_manager/features/character_creation/presentation/viewmodels/quick_create_view_model.dart';

class QuickCreatePage extends HookConsumerWidget {
  const QuickCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quickCreateViewModelProvider);
    final viewModel = ref.read(quickCreateViewModelProvider.notifier);
    final pageController = usePageController(initialPage: state.stepIndex);
    final nameController = useTextEditingController(text: state.characterName);

    useEffect(() {
      if (nameController.text != state.characterName) {
        nameController.text = state.characterName;
      }
      return null;
    }, [state.characterName]);

    useEffect(() {
      void listener() => viewModel.updateName(nameController.text);
      nameController.addListener(listener);
      return () => nameController.removeListener(listener);
    }, [nameController, viewModel]);

    useEffect(() {
      if (!pageController.hasClients) return null;
      if (pageController.page?.round() != state.stepIndex) {
        pageController.animateToPage(
          state.stepIndex,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
      return null;
    }, [state.stepIndex]);

    ref.listen<QuickCreateState>(quickCreateViewModelProvider, (previous, next) {
      final completion = next.completion;
      if (completion != null && completion != previous?.completion) {
        switch (completion) {
          case QuickCreateSuccess(:final character):
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
                  'Inventaire: ${character.inventory.map((l) => "${l.itemId.value} x${l.quantity.value}").join(", ")}\n'
                  'Compétences: ${character.skills.map((s) => s.skillId).join(", ")}',
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
          case QuickCreateFailure(:final error):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur: ${error.code}${error.message != null ? ' — ${error.message}' : ''}')),
            );
            break;
        }
        viewModel.clearCompletion();
      }
    });

    final connectivityStatus = ref.watch(connectivityStatusProvider).maybeWhen(
          data: (status) => status,
          orElse: () => ConnectivityStatus.connected,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text('Création rapide — Étape ${state.stepIndex + 1}/${QuickCreateStep.values.length}'),
      ),
      body: Column(
        children: [
          if (connectivityStatus == ConnectivityStatus.disconnected)
            MaterialBanner(
              backgroundColor: Colors.orange.shade100,
              content: const Text('Mode hors ligne : certaines fonctionnalités réseau sont indisponibles.'),
              actions: const [SizedBox.shrink()],
            ),
          if (state.statusMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        onSelect: (value) => viewModel.selectSpecies(value),
                        onOpenPicker: () async {
                          final chosen = await context.pushNamed<String>(
                            SpeciesPickerPage.routeName,
                            extra: state.selectedSpecies,
                          );
                          if (chosen != null) {
                            viewModel.selectSpecies(chosen);
                          }
                        },
                      ),
                      _AbilitiesStep(
                        mode: state.abilityMode,
                        assignments: state.abilityAssignments,
                        pool: state.abilityPool,
                        onModeChanged: viewModel.setAbilityGenerationMode,
                        onReroll: viewModel.rerollAbilityScores,
                        onAssign: viewModel.setAbilityScore,
                      ),
                      _ClassStep(
                        classes: state.classes,
                        selectedClass: state.selectedClass,
                        classDef: state.selectedClassDef,
                        isLoadingDetails: state.isLoadingClassDetails,
                        onSelect: (value) => viewModel.selectClass(value),
                        onOpenPicker: () async {
                          final chosen = await context.pushNamed<String>(
                            ClassPickerPage.routeName,
                            extra: state.selectedClass,
                          );
                          if (chosen != null) {
                            viewModel.selectClass(chosen);
                          }
                        },
                      ),
                      _SkillStep(
                        availableSkills: state.availableSkills,
                        skillDefinitions: state.skillDefinitions,
                        chosenSkills: state.chosenSkills,
                        requiredCount: state.skillChoicesRequired,
                        onToggle: viewModel.toggleSkillSelection,
                      ),
                      _BackgroundStep(
                        backgrounds: state.backgrounds,
                        selectedBackground: state.selectedBackground,
                        nameController: nameController,
                        onBackgroundChanged: (value) => viewModel.selectBackground(value),
                      ),
                    ],
                  ),
          ),
          _QuickCreateControls(
            state: state,
            onPrevious: viewModel.previousStep,
            onNext: viewModel.nextStep,
            onCreate: viewModel.createCharacter,
          ),
        ],
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
      .map((part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
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
                    .map((id) => DropdownMenuItem(
                          value: id,
                          child: Text(_titleCase(id)),
                        ))
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
                    title: Text(trait.name.fr.isNotEmpty ? trait.name.fr : trait.name.en),
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
        value: currentValue,
        decoration: const InputDecoration(
          labelText: 'Score',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('—'),
          ),
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
          child: Column(
            children: [
              RadioListTile<AbilityGenerationMode>(
                value: AbilityGenerationMode.standardArray,
                groupValue: mode,
                title: const Text('Tableau standard'),
                subtitle: const Text('Utiliser les scores fixes 15, 14, 13, 12, 10 et 8.'),
                onChanged: (value) {
                  if (value != null) onModeChanged(value);
                },
              ),
              const Divider(height: 0),
              RadioListTile<AbilityGenerationMode>(
                value: AbilityGenerationMode.roll,
                groupValue: mode,
                title: const Text('Lancer les dés'),
                subtitle: const Text('Lancez 4d6, conservez les 3 meilleurs et assignez les 6 scores obtenus.'),
                onChanged: (value) {
                  if (value != null) onModeChanged(value);
                },
              ),
              if (mode == AbilityGenerationMode.roll)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
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
                groupValue: mode,
                title: const Text('Saisie manuelle'),
                subtitle: const Text('Entrez vous-même les scores obtenus ailleurs et assignez-les.'),
                onChanged: (value) {
                  if (value != null) onModeChanged(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (mode != AbilityGenerationMode.manual) ...[
          Text(
            'Scores disponibles',
            style: theme.textTheme.titleSmall,
          ),
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
                    label: Text(entry.value > 1
                        ? '${entry.key} ×${entry.value}'
                        : entry.key.toString()),
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
        if (value != null && value >= AbilityScore.min && value <= AbilityScore.max) {
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
          errorText.value = 'Doit être entre ${AbilityScore.min} et ${AbilityScore.max}';
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
      .map((part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
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
                    .map((id) => DropdownMenuItem(
                          value: id,
                          child: Text(_titleCase(id)),
                        ))
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
      .map((part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
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
      .map((part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
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
              .map((id) => DropdownMenuItem(
                    value: id,
                    child: Text(_titleCase(id)),
                  ))
              .toList(),
          onChanged: onBackgroundChanged,
        ),
        const SizedBox(height: 24),
        const Text(
          'Conseil : vous pourrez affiner l’équipement et les compétences dans une prochaine version.',
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
                      onPressed: state.canCreate && !state.isCreating ? onCreate : null,
                      icon: state.isCreating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
