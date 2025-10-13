// Interface utilisateur principale de l'assistant de création rapide.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sw5e_manager/app/locale/app_locale_controller.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/common/di/service_locator.dart';
import 'package:sw5e_manager/common/errors/app_failure.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/core/connectivity/connectivity_providers.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/clear_character_draft.dart';
import 'package:sw5e_manager/domain/characters/usecases/finalize_level1_character.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_character_draft.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_class_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_quick_create_catalog.dart';
import 'package:sw5e_manager/domain/characters/usecases/load_species_details.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_ability_scores.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_background.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_class.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_equipment.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_name.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_skills.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_species.dart';
import 'package:sw5e_manager/domain/characters/usecases/persist_character_draft_step.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_effect.dart';
import 'package:sw5e_manager/presentation/character_creation/blocs/quick_create_bloc.dart';
import 'package:sw5e_manager/presentation/character_creation/states/quick_create_state.dart';
import 'package:sw5e_manager/ui/character_creation/pages/class_picker_page.dart';
import 'package:sw5e_manager/ui/character_creation/pages/species_picker.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/character_section_divider.dart';

part 'quick_create_view.dart';
part 'summary/character_summary_panel.dart';
part 'summary/summary_section.dart';
part 'summary/summary_row.dart';
part 'steps/species_step.dart';
part 'steps/abilities_step.dart';
part 'steps/manual_ability_field.dart';
part 'steps/class_step.dart';
part 'steps/skill_step.dart';
part 'steps/equipment_step.dart';
part 'steps/background_step.dart';
part 'widgets/quick_create_controls.dart';

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

  /// Prépare les contrôleurs et instancie le BLoC avec les dépendances
  /// résolues via le service locator.
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    final LoadQuickCreateCatalog loadCatalog =
        ServiceLocator.resolve<LoadQuickCreateCatalog>();
    final LoadSpeciesDetails loadSpeciesDetails =
        ServiceLocator.resolve<LoadSpeciesDetails>();
    final LoadClassDetails loadClassDetails =
        ServiceLocator.resolve<LoadClassDetails>();
    final LoadCharacterDraft loadCharacterDraft =
        ServiceLocator.resolve<LoadCharacterDraft>();
    final FinalizeLevel1Character finalize =
        ServiceLocator.resolve<FinalizeLevel1Character>();
    final AppLogger logger = ServiceLocator.resolve<AppLogger>();
    final PersistCharacterDraftName persistDraftName =
        ServiceLocator.resolve<PersistCharacterDraftName>();
    final PersistCharacterDraftSpecies persistDraftSpecies =
        ServiceLocator.resolve<PersistCharacterDraftSpecies>();
    final PersistCharacterDraftClass persistDraftClass =
        ServiceLocator.resolve<PersistCharacterDraftClass>();
    final PersistCharacterDraftBackground persistDraftBackground =
        ServiceLocator.resolve<PersistCharacterDraftBackground>();
    final PersistCharacterDraftAbilityScores persistDraftAbilities =
        ServiceLocator.resolve<PersistCharacterDraftAbilityScores>();
    final PersistCharacterDraftSkills persistDraftSkills =
        ServiceLocator.resolve<PersistCharacterDraftSkills>();
    final PersistCharacterDraftEquipment persistDraftEquipment =
        ServiceLocator.resolve<PersistCharacterDraftEquipment>();
    final PersistCharacterDraftStep persistDraftStep =
        ServiceLocator.resolve<PersistCharacterDraftStep>();
    final ClearCharacterDraft clearDraft =
        ServiceLocator.resolve<ClearCharacterDraft>();
    final Locale currentLocale = ref.read(appLocaleProvider);

    _bloc = QuickCreateBloc(
      loadQuickCreateCatalog: loadCatalog,
      loadSpeciesDetails: loadSpeciesDetails,
      loadClassDetails: loadClassDetails,
      loadCharacterDraft: loadCharacterDraft,
      finalizeLevel1Character: finalize,
      logger: logger,
      persistCharacterDraftName: persistDraftName,
      persistCharacterDraftSpecies: persistDraftSpecies,
      persistCharacterDraftClass: persistDraftClass,
      persistCharacterDraftBackground: persistDraftBackground,
      persistCharacterDraftAbilityScores: persistDraftAbilities,
      persistCharacterDraftSkills: persistDraftSkills,
      persistCharacterDraftEquipment: persistDraftEquipment,
      persistCharacterDraftStep: persistDraftStep,
      clearCharacterDraft: clearDraft,
      languageCode: currentLocale.languageCode,
    )..add(const QuickCreateStarted());

    _pageController = PageController(initialPage: _bloc.state.stepIndex);

    final String initialName = _bloc.state.characterName;
    if (initialName.isNotEmpty) {
      _nameController.text = initialName;
    }
    _nameController.addListener(_onNameChanged);
  }

  /// Libère les contrôleurs et ferme le BLoC lorsque la page est détruite.
  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _pageController.dispose();
    _bloc.close();
    super.dispose();
  }

  /// Répercute les modifications du champ texte vers le BLoC pour persistance.
  void _onNameChanged() {
    _bloc.add(QuickCreateNameChanged(_nameController.text));
  }

  /// Construit l'arbre de widgets principal de la page, en injectant le BLoC
  /// et les contrôleurs nécessaires aux sous-vues.
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
