part of 'quick_create_page.dart';

/// Vue principale contenant les listeners BLoC et le `PageView` d'étapes.
class _QuickCreateView extends StatelessWidget {
  const _QuickCreateView({
    required this.pageController,
    required this.nameController,
    required this.connectivityStatus,
  });

  final PageController pageController;
  final TextEditingController nameController;
  final ConnectivityStatus connectivityStatus;

  /// Affiche les dialogues/snackbars de fin de création en réponse au BLoC.
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

  /// Construit le layout de l'assistant et configure les écouteurs nécessaires
  /// pour synchroniser la navigation et les champs contrôlés.
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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (pageController.hasClients) {
                  pageController.jumpToPage(state.stepIndex);
                }
              });
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
              leading: IconButton(
                icon: const Icon(Icons.home_outlined),
                tooltip: "Retour à l'accueil",
                onPressed: () => context.go('/'),
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
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: PageView(
                                controller: pageController,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _SpeciesStep(
                                    species: state.species,
                                    selectedSpecies: state.selectedSpecies,
                                    traits: state.selectedSpeciesTraits,
                                    effects: state.selectedSpeciesEffects,
                                    onSelect: (value) {
                                      if (value != null) {
                                        bloc.add(QuickCreateSpeciesSelected(value));
                                      }
                                    },
                                    onOpenPicker: () async {
                                      final chosen =
                                          await context.pushNamed<String>(
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
                                    onModeChanged: (mode) => bloc.add(
                                      QuickCreateAbilityModeChanged(mode),
                                    ),
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
                                    equipmentDefinitions:
                                        state.equipmentDefinitions,
                                    onSelect: (value) {
                                      if (value != null) {
                                        bloc.add(QuickCreateClassSelected(value));
                                      }
                                    },
                                    onOpenPicker: () async {
                                      final chosen =
                                          await context.pushNamed<String>(
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
                                    onToggle: (skillId) => bloc.add(
                                      QuickCreateSkillToggled(skillId),
                                    ),
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
                            Container(
                              width: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                            Expanded(
                              child: _CharacterSummaryPanel(state: state),
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
