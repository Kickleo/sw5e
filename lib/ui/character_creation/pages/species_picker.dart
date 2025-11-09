/// ---------------------------------------------------------------------------
/// Fichier : lib/ui/character_creation/pages/species_picker.dart
/// Rôle : Vue Flutter du sélecteur d'espèce ; se contente de binder le
///        `SpeciesPickerBloc` aux widgets et d'exposer l'identifiant choisi.
/// Dépendances : flutter_bloc, service locator, SpeciesPickerBloc.
/// Exemple d'usage :
///   Navigator.pushNamed(context, SpeciesPickerPage.routeName);
/// ---------------------------------------------------------------------------
library;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/common/di/service_locator.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/presentation/character_creation/blocs/species_picker_bloc.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/language_details.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/species_ability_bonuses.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/species_trait_details.dart';

/// SpeciesPickerPage = écran modal permettant de choisir une espèce niveau 1.
class SpeciesPickerPage extends StatefulWidget {
  const SpeciesPickerPage({super.key, this.initialSpeciesId});

  static const String routeName = 'species-picker';

  final String? initialSpeciesId;

  @override
  State<SpeciesPickerPage> createState() => _SpeciesPickerPageState();
}

class _SpeciesPickerPageState extends State<SpeciesPickerPage> {
  /// BLoC instancié via le service locator et possédé par la page.
  late final SpeciesPickerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = SpeciesPickerBloc(
      catalog: ServiceLocator.resolve<CatalogRepository>(),
      logger: ServiceLocator.resolve<AppLogger>(),
    )..add(SpeciesPickerStarted(initialSpeciesId: widget.initialSpeciesId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SpeciesPickerBloc>.value(
      value: _bloc,
      child: const _SpeciesPickerView(),
    );
  }
}

class _SpeciesPickerView extends StatelessWidget {
  const _SpeciesPickerView();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocConsumer<SpeciesPickerBloc, SpeciesPickerState>(
      listenWhen: (SpeciesPickerState previous, SpeciesPickerState current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (BuildContext context, SpeciesPickerState state) {
        final String? message = state.errorMessage;
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (BuildContext context, SpeciesPickerState state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.speciesPickerTitle),
            actions: <Widget>[
              TextButton(
                onPressed: state.hasSelection
                    ? () => Navigator.of(context).pop(state.selectedSpeciesId)
                    : null,
                child: Text(context.l10n.pickerSelectAction),
              ),
            ],
          ),
          body: _buildBody(context, state, theme),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    SpeciesPickerState state,
    ThemeData theme,
  ) {
    if (state.isLoadingList && !state.hasLoadedOnce) {
      return const Center(child: CircularProgressIndicator());
    }

    final l10n = context.l10n;
    if (state.hasError && state.speciesIds.isEmpty) {
      return Center(child: Text(state.errorMessage ?? l10n.unknownError));
    }

    if (state.speciesIds.isEmpty) {
      return Center(child: Text(l10n.noSpeciesAvailable));
    }

    return Row(
      children: <Widget>[
        SizedBox(
          width: 240,
          child: _SpeciesList(
            speciesIds: state.speciesIds,
            selectedId: state.selectedSpeciesId,
            speciesDefinitions: state.speciesDefinitions,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: state.isLoadingDetails
              ? const Center(child: CircularProgressIndicator())
              : _SpeciesDetails(
                  state: state,
                  theme: theme,
                ),
        ),
      ],
    );
  }
}

class _SpeciesList extends StatelessWidget {
  const _SpeciesList({
    required this.speciesIds,
    required this.selectedId,
    required this.speciesDefinitions,
  });

  final List<String> speciesIds;
  final String? selectedId;
  final Map<String, SpeciesDef> speciesDefinitions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView.builder(
      itemCount: speciesIds.length,
      itemBuilder: (BuildContext context, int index) {
        final String id = speciesIds[index];
        final bool selected = id == selectedId;
        return ListTile(
          selected: selected,
          title: Text(_labelFor(l10n, id)),
          subtitle: Text(id),
          onTap: () =>
              context.read<SpeciesPickerBloc>().add(SpeciesPickerSpeciesRequested(id)),
        );
      },
    );
  }

  String _labelFor(AppLocalizations l10n, String id) {
    final SpeciesDef? def = speciesDefinitions[id];
    if (def != null) {
      final String label = l10n.localizedCatalogLabel(def.name).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }
}

class _SpeciesDetails extends StatelessWidget {
  const _SpeciesDetails({required this.state, required this.theme});

  final SpeciesPickerState state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final SpeciesDef? selected = state.selectedSpecies;
    final l10n = context.l10n;

    if (selected == null) {
      return Center(child: Text(l10n.noSpeciesSelected));
    }

    final List<LanguageDef> languages = state.selectedLanguages;
    final List<SpeciesAbilityBonus> bonuses = selected.abilityBonuses;
    final bool showLanguages = LanguageDetailsCard.hasDisplayableContent(
      l10n,
      languages,
      fallback: selected.languages,
    );
    final bool showAbilityBonuses =
        SpeciesAbilityBonusesCard.hasDisplayableContent(bonuses);
    final bool showTraitDetails = selected.traitIds.isNotEmpty ||
        SpeciesTraitDetailsList.hasDisplayableContent(state.selectedTraits);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: <Widget>[
          Text(
            _localizedName(l10n, selected.name),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(l10n.speciesIdentifier(selected.id)),
          const SizedBox(height: 12),
          Text(l10n.speciesSpeed(selected.speed.toString())),
          Text(l10n.speciesSize(selected.size.toString())),
          if (showAbilityBonuses) ...<Widget>[
            const SizedBox(height: 12),
            SpeciesAbilityBonusesCard(bonuses: bonuses),
          ],
          if (showLanguages) ...<Widget>[
            const SizedBox(height: 12),
            LanguageDetailsCard(
              languages: languages,
              fallback: selected.languages,
            ),
          ],
          if (selected.descriptionShort != null || selected.description != null)
            const SizedBox(height: 16),
          if (selected.descriptionShort != null)
            Text(l10n.localizedCatalogLabel(selected.descriptionShort!)),
          if (selected.description != null) ...<Widget>[
            if (selected.descriptionShort != null)
              const SizedBox(height: 8),
            Text(l10n.localizedCatalogLabel(selected.description!)),
          ],
          const SizedBox(height: 16),
          Text(
            l10n.speciesPickerTraitsTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (!showTraitDetails)
            Text(l10n.speciesPickerNoTraits)
          else
            SpeciesTraitDetailsList(
              traitIds: selected.traitIds,
              traitDefinitions: state.traitDefinitions,
            ),
        ],
      ),
    );
  }
}

String _localizedName(AppLocalizations l10n, LocalizedText text) {
  return l10n.localizedCatalogLabel(text);
}

String _titleCase(String slug) {
  return slug
      .split(RegExp(r'[\-_.]'))
      .map((String part) =>
          part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
