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
import 'package:sw5e_manager/common/di/service_locator.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/presentation/character_creation/blocs/species_picker_bloc.dart';

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
            title: const Text('Choisir une espèce'),
            actions: <Widget>[
              TextButton(
                onPressed: state.hasSelection
                    ? () => Navigator.of(context).pop(state.selectedSpeciesId)
                    : null,
                child: const Text('Sélectionner'),
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

    if (state.hasError && state.speciesIds.isEmpty) {
      return Center(child: Text(state.errorMessage ?? 'Erreur inconnue'));
    }

    if (state.speciesIds.isEmpty) {
      return const Center(child: Text('Aucune espèce disponible'));
    }

    return Row(
      children: <Widget>[
        SizedBox(
          width: 240,
          child: _SpeciesList(
            speciesIds: state.speciesIds,
            selectedId: state.selectedSpeciesId,
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
  const _SpeciesList({required this.speciesIds, required this.selectedId});

  final List<String> speciesIds;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: speciesIds.length,
      itemBuilder: (BuildContext context, int index) {
        final String id = speciesIds[index];
        final bool selected = id == selectedId;
        return ListTile(
          selected: selected,
          title: Text(_titleCase(id)),
          subtitle: Text(id),
          onTap: () =>
              context.read<SpeciesPickerBloc>().add(SpeciesPickerSpeciesRequested(id)),
        );
      },
    );
  }
}

class _SpeciesDetails extends StatelessWidget {
  const _SpeciesDetails({required this.state, required this.theme});

  final SpeciesPickerState state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final SpeciesDef? selected = state.selectedSpecies;

    if (selected == null) {
      return const Center(child: Text('Aucune espèce sélectionnée'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: <Widget>[
          Text(
            _localizedName(selected.name),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('Identifiant : ${selected.id}'),
          const SizedBox(height: 12),
          Text('Vitesse : ${selected.speed}'),
          Text('Taille : ${selected.size}'),
          const SizedBox(height: 16),
          Text(
            'Traits d\'espèce',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (state.selectedTraits.isEmpty)
            const Text('Aucun trait listé pour cette espèce.')
          else
            ...state.selectedTraits.map(
              (TraitDef trait) => Card(
                child: ListTile(
                  title: Text(_localizedName(trait.name)),
                  subtitle: Text(trait.description),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _localizedName(LocalizedText text) {
  return text.fr.isNotEmpty ? text.fr : text.en;
}

String _titleCase(String slug) {
  return slug
      .split(RegExp(r'[-_]'))
      .map((String part) =>
          part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
