/// ---------------------------------------------------------------------------
/// Fichier : lib/ui/character_creation/pages/class_picker_page.dart
/// Rôle : Vue Flutter du sélecteur de classe ; se contente de binder le
///        `ClassPickerBloc` aux widgets et d'exposer le résultat via Navigator.
/// Dépendances : flutter_bloc, service locator, ClassPickerBloc.
/// Exemple d'usage :
///   Navigator.pushNamed(context, ClassPickerPage.routeName);
/// ---------------------------------------------------------------------------
library;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/common/di/service_locator.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/presentation/character_creation/blocs/class_picker_bloc.dart';

/// ClassPickerPage = écran modal permettant de choisir une classe niveau 1.
class ClassPickerPage extends StatefulWidget {
  const ClassPickerPage({super.key, this.initialClassId});

  static const String routeName = 'class-picker';

  final String? initialClassId;

  @override
  State<ClassPickerPage> createState() => _ClassPickerPageState();
}

class _ClassPickerPageState extends State<ClassPickerPage> {
  /// BLoC instancié via le service locator et possédé par la page.
  late final ClassPickerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ClassPickerBloc(
      catalog: ServiceLocator.resolve<CatalogRepository>(),
      logger: ServiceLocator.resolve<AppLogger>(),
    )..add(ClassPickerStarted(initialClassId: widget.initialClassId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClassPickerBloc>.value(
      value: _bloc,
      child: const _ClassPickerView(),
    );
  }
}

class _ClassPickerView extends StatelessWidget {
  const _ClassPickerView();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocConsumer<ClassPickerBloc, ClassPickerState>(
      listenWhen: (ClassPickerState previous, ClassPickerState current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (BuildContext context, ClassPickerState state) {
        final String? message = state.errorMessage;
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (BuildContext context, ClassPickerState state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.classPickerTitle),
            actions: <Widget>[
              TextButton(
                onPressed: state.hasSelection
                    ? () => Navigator.of(context).pop(state.selectedClassId)
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
    ClassPickerState state,
    ThemeData theme,
  ) {
    if (state.isLoadingList && !state.hasLoadedOnce) {
      return const Center(child: CircularProgressIndicator());
    }

    final l10n = context.l10n;
    if (state.hasError && state.classIds.isEmpty) {
      return Center(child: Text(state.errorMessage ?? l10n.unknownError));
    }

    if (state.classIds.isEmpty) {
      return Center(child: Text(l10n.noClassesAvailable));
    }

    return Row(
      children: <Widget>[
        SizedBox(
          width: 240,
          child: _ClassList(
            classIds: state.classIds,
            selectedId: state.selectedClassId,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: state.isLoadingDetails
              ? const Center(child: CircularProgressIndicator())
              : _ClassDetails(
                  state: state,
                  theme: theme,
                ),
        ),
      ],
    );
  }
}

class _ClassList extends StatelessWidget {
  const _ClassList({required this.classIds, required this.selectedId});

  final List<String> classIds;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: classIds.length,
      itemBuilder: (BuildContext context, int index) {
        final String id = classIds[index];
        final bool selected = id == selectedId;
        return ListTile(
          selected: selected,
          title: Text(_titleCase(id)),
          subtitle: Text(id),
          onTap: () =>
              context.read<ClassPickerBloc>().add(ClassPickerClassRequested(id)),
        );
      },
    );
  }
}

class _ClassDetails extends StatelessWidget {
  const _ClassDetails({required this.state, required this.theme});

  final ClassPickerState state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final ClassDef? selected = state.selectedClass;
    final l10n = context.l10n;
    if (selected == null) {
      return Center(child: Text(l10n.classPickerNoClass));
    }

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
          Text(l10n.classPickerHitDie(selected.hitDie)),
          const SizedBox(height: 12),
          Text(
            l10n.classPickerSkillsHeading(
              selected.level1.proficiencies.skillsChoose,
            ),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...selected.level1.proficiencies.skillsFrom.map(
            (String id) {
              final skillLabel = _formatSkill(id, state, l10n);
              final ability = _skillAbility(id, state, l10n);
              if (ability.isEmpty) {
                return Text('• $skillLabel');
              }
              return Text(l10n.classPickerSkillLine(skillLabel, ability));
            },
          ),
          const SizedBox(height: 16),
          Text(
            l10n.classPickerStartingEquipmentTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...selected.level1.startingEquipment.map(
            (StartingEquipmentLine line) => Text(
              l10n.classPickerEquipmentLine(
                _formatEquipment(line.id, state, l10n),
                line.qty,
              ),
            ),
          ),
          if (selected.level1.startingEquipmentOptions.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              l10n.classPickerExtraOptionsTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...selected.level1.startingEquipmentOptions.map(
              (LocalizedText option) =>
                  Text('• ${l10n.localizedCatalogLabel(option)}'),
            ),
          ],
        ],
      ),
    );
  }
}

String _localizedName(AppLocalizations l10n, LocalizedText text) {
  if (l10n.isFrench) {
    return text.fr.isNotEmpty ? text.fr : text.en;
  }
  return text.en.isNotEmpty ? text.en : text.fr;
}

String _formatSkill(String id, ClassPickerState state, AppLocalizations l10n) {
  if (id == 'any') {
    return l10n.classPickerAnySkill;
  }
  final SkillDef? def = state.skillDefinitions[id];
  if (def == null) {
    return _titleCase(id);
  }
  return _titleCase(id);
}

String _skillAbility(String id, ClassPickerState state, AppLocalizations l10n) {
  if (id == 'any') {
    return '';
  }
  final SkillDef? def = state.skillDefinitions[id];
  if (def == null) {
    return '';
  }
  return l10n.abilityAbbreviation(def.ability);
}

String _formatEquipment(
  String id,
  ClassPickerState state,
  AppLocalizations l10n,
) {
  final EquipmentDef? def = state.equipmentDefinitions[id];
  if (def == null) {
    return _titleCase(id);
  }
  if (l10n.isFrench) {
    return def.name.fr.isNotEmpty ? def.name.fr : def.name.en;
  }
  return def.name.en.isNotEmpty ? def.name.en : def.name.fr;
}

String _titleCase(String slug) {
  return slug
      .split(RegExp(r'[-_]'))
      .map(
        (String part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}
