import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sw5e_manager/core/connectivity/connectivity_providers.dart';
import 'package:sw5e_manager/features/character_creation/domain/repositories/catalog_repository.dart';
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
                'Compétences : choisir ${classDefData.level1.proficiencies.skillsChoose} parmi ${classDefData.level1.proficiencies.skillsFrom.join(', ')}',
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
