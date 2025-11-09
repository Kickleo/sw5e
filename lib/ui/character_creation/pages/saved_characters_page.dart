/// ---------------------------------------------------------------------------
/// Fichier : lib/ui/character_creation/pages/saved_characters_page.dart
/// Rôle : Vue Flutter affichant la liste des personnages sauvegardés ;
///        délègue entièrement l'état au SavedCharactersBloc (ViewModel MVVM).
/// Dépendances : flutter_bloc (binding BLoC↔UI), ServiceLocator (injection),
///        entités métier Character.
/// Exemple d'usage : routage GoRouter -> const SavedCharactersPage().
/// ---------------------------------------------------------------------------
library;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/common/di/service_locator.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/services/catalog_lookup_service.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/presentation/character_creation/blocs/saved_characters_bloc.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/background_details.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/character_section_divider.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/class_feature_list.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/class_multiclassing_details.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/class_power_details.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/catalog_details.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/language_details.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/species_ability_bonuses.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/species_trait_details.dart';

class SavedCharactersPage extends StatefulWidget {
  const SavedCharactersPage({super.key});

  static const String routeName = 'saved-characters';

  @override
  State<SavedCharactersPage> createState() => _SavedCharactersPageState();
}

class _SavedCharactersPageState extends State<SavedCharactersPage> {
  late final ScrollController _scrollController;
  late final SavedCharactersBloc _bloc;
  late final CatalogLookupService _catalogLookupService;
  CatalogLookupResult _catalogLookups = const CatalogLookupResult.empty();
  int _catalogLookupRequestId = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final ListSavedCharacters listSavedCharacters =
        ServiceLocator.resolve<ListSavedCharacters>();
    final CatalogRepository catalog =
        ServiceLocator.resolve<CatalogRepository>();
    final AppLogger logger = ServiceLocator.resolve<AppLogger>();
    _catalogLookupService =
        CatalogLookupService(catalog: catalog, logger: logger);
    _bloc = SavedCharactersBloc(
      listSavedCharacters: listSavedCharacters,
    )..add(const SavedCharactersRequested());
  }

  Future<void> _loadCatalogLookups(List<Character> characters) async {
    _catalogLookupRequestId += 1;
    final int requestId = _catalogLookupRequestId;

    if (characters.isEmpty) {
      setState(() {
        _catalogLookups = const CatalogLookupResult.empty();
      });
      return;
    }

    try {
      final CatalogLookupResult result = await _catalogLookupService
          .buildForCharacters(characters: characters);
      if (!mounted || requestId != _catalogLookupRequestId) {
        return;
      }
      setState(() {
        _catalogLookups = result;
      });
    } catch (_) {
      if (!mounted || requestId != _catalogLookupRequestId) {
        return;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SavedCharactersBloc>.value(
      value: _bloc,
      child: BlocListener<SavedCharactersBloc, SavedCharactersState>(
        listenWhen: (previous, current) =>
            previous.characters != current.characters,
        listener: (context, state) => _loadCatalogLookups(state.characters),
        child: Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.savedCharactersTitle),
            leading: IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: context.l10n.backToHomeTooltip,
            onPressed: () => context.go('/'),
          ),
          actions: [
            BlocBuilder<SavedCharactersBloc, SavedCharactersState>(
              buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
              builder: (context, state) {
                return IconButton(
                  onPressed: state.isLoading
                      ? null
                      : () => context
                          .read<SavedCharactersBloc>()
                          .add(const SavedCharactersRefreshRequested()),
                  tooltip: context.l10n.refreshTooltip,
                  icon: const Icon(Icons.refresh),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<SavedCharactersBloc, SavedCharactersState>(
          builder: (context, state) {
            if (state.isLoading && !state.hasLoadedOnce) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.hasError && state.characters.isEmpty) {
              return _ErrorView(
                message: state.errorMessage ?? context.l10n.unknownError,
                onRetry: () => context
                    .read<SavedCharactersBloc>()
                    .add(const SavedCharactersRefreshRequested()),
              );
            }

            if (state.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<SavedCharactersBloc>()
                      .add(const SavedCharactersRefreshRequested());
                },
                child: const _EmptyView(),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<SavedCharactersBloc>()
                    .add(const SavedCharactersRefreshRequested());
              },
              child: Scrollbar(
                controller: _scrollController,
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      state.characters.length + (state.hasError ? 1 : 0),
                  separatorBuilder: (_, _) => const CharacterSectionDivider(),
                  itemBuilder: (context, index) {
                  if (state.hasError) {
                    if (index == 0) {
                      return _InlineErrorBanner(
                        message:
                            state.errorMessage ?? context.l10n.unknownError,
                      );
                    }
                    final Character character = state.characters[index - 1];
                    return _CharacterCard(
                      character: character,
                      lookups: _catalogLookups,
                    );
                  }
                  final Character character = state.characters[index];
                  return _CharacterCard(
                    character: character,
                    lookups: _catalogLookups,
                  );
                },
                ),
              ),
            );
          },
        ),
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.character, required this.lookups});

  final Character character;
  final CatalogLookupResult lookups;

  String _fmtSigned(int value) => value >= 0 ? '+$value' : '$value';

  String _titleCase(String slug) {
    return slug
        .split(RegExp(r'[\-_.]'))
        .map(
          (String part) =>
              part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  String _resolveLocalizedLabel(
    AppLocalizations l10n,
    Map<String, LocalizedText> labels,
    String id,
  ) {
    final LocalizedText? text = labels[id];
    if (text != null) {
      final String value = l10n.localizedCatalogLabel(text).trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return _titleCase(id);
  }

  String _resolveSkillLabel(AppLocalizations l10n, String id) {
    final SkillDef? def = lookups.skillDefinitions[id];
    if (def != null) {
      final String value = l10n.localizedCatalogLabel(def.name).trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return _titleCase(id);
  }

  String _resolveEquipmentLabel(AppLocalizations l10n, String id) {
    final EquipmentDef? def = lookups.equipmentDefinitions[id];
    if (def != null) {
      final String value = l10n.localizedCatalogLabel(def.name).trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return _titleCase(id);
  }

  List<String> _resolveEquipmentMetadata(AppLocalizations l10n, String id) {
    final EquipmentDef? def = lookups.equipmentDefinitions[id];
    if (def == null) {
      return const <String>[];
    }
    return l10n.equipmentMetadataLines(def);
  }

  Widget _inventoryEntry(
    ThemeData theme,
    AppLocalizations l10n,
    InventoryLine line,
  ) {
    final String label =
        _resolveEquipmentLabel(l10n, line.itemId.value);
    final List<String> metadata =
        _resolveEquipmentMetadata(l10n, line.itemId.value);
    if (metadata.isEmpty) {
      return Text(l10n.inventoryLine(label, line.quantity.value));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.inventoryLine(label, line.quantity.value)),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: metadata
                .map(
                  (entry) => Text(
                    entry,
                    style: theme.textTheme.bodySmall,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget? _buildClassSection(AppLocalizations l10n, ThemeData theme) {
    final ClassDef? classDef = lookups.classDefinitions[character.classId.value];
    if (classDef == null) {
      return null;
    }

    final List<Widget> children = <Widget>[];
    if (classDef.multiclassing?.hasAbilityRequirements ?? false) {
      children
        ..add(
          ClassMulticlassingDetails(
            classDef: classDef,
            abilityDefinitions: lookups.abilityDefinitions,
            headingStyle:
                theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        )
        ..add(const SizedBox(height: 8));
    }
    if (_hasPowerInfo(classDef)) {
      children
        ..add(ClassPowerDetails(classDef: classDef))
        ..add(const SizedBox(height: 8));
    }

    if (classDef.level1.classFeatures.isNotEmpty) {
      children.add(
        ClassFeatureList(
          heading: l10n.summaryClassLevel1FeaturesTitle,
          headingStyle:
              theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          features: classDef.level1.classFeatures,
        ),
      );
    }

    if (children.isEmpty) {
      return null;
    }

    return _Section(
      title: l10n.summaryClassFeatures,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget? _buildBackgroundSection(AppLocalizations l10n, ThemeData theme) {
    final BackgroundDef? backgroundDef =
        lookups.backgroundDefinitions[character.backgroundId.value];
    if (backgroundDef == null) {
      return null;
    }

    final List<Widget> children = buildBackgroundDetails(
      l10n: l10n,
      theme: theme,
      background: backgroundDef,
      skillDefinitions: lookups.skillDefinitions,
      equipmentDefinitions: lookups.equipmentDefinitions,
    );

    if (children.isEmpty) {
      return null;
    }

    return _Section(
      title: l10n.summaryBackgroundDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final String speciesLabel = _resolveLocalizedLabel(
      l10n,
      lookups.speciesNames,
      character.speciesId.value,
    );
    final String classLabel = _resolveLocalizedLabel(
      l10n,
      lookups.classNames,
      character.classId.value,
    );
    final String backgroundLabel = _resolveLocalizedLabel(
      l10n,
      lookups.backgroundNames,
      character.backgroundId.value,
    );
    final SpeciesDef? speciesDef =
        lookups.speciesDefinitions[character.speciesId.value];
    final List<LanguageDef> speciesLanguages = <LanguageDef>[];
    if (speciesDef != null) {
      for (final String languageId in speciesDef.languageIds) {
        final LanguageDef? language = lookups.languageDefinitions[languageId];
        if (language != null) {
          speciesLanguages.add(language);
        }
      }
    }
    final LocalizedText? speciesLanguageFallback = speciesDef?.languages;
    final List<SpeciesAbilityBonus> speciesAbilityBonuses =
        speciesDef?.abilityBonuses ?? const <SpeciesAbilityBonus>[];
    final bool showAbilityBonuses =
        SpeciesAbilityBonusesCard.hasDisplayableContent(speciesAbilityBonuses);
    final bool showLanguageDetails = LanguageDetailsCard.hasDisplayableContent(
      l10n,
      speciesLanguages,
      fallback: speciesLanguageFallback,
    );
    final List<String> speciesTraitIds = character.speciesTraits
        .map((CharacterTrait trait) => trait.id.value)
        .toList(growable: false);
    final bool showTraitDetails = speciesTraitIds.isNotEmpty;
    final Widget? classSection = _buildClassSection(l10n, theme);
    final Widget? backgroundSection = _buildBackgroundSection(l10n, theme);
    final List<String> customizationOptionIds =
        character.customizationOptionIds.toList()..sort();
    final bool showCustomizationOptions =
        CustomizationOptionDetailsList.hasDisplayableContent(
      customizationOptionIds,
    );
    final Widget customizationDetails = CustomizationOptionDetailsList(
      optionIds: customizationOptionIds,
      optionDefinitions: lookups.customizationOptionDefinitions,
    );
    final List<String> forcePowerIds = character.forcePowerIds.toList()..sort();
    final bool showForcePowers =
        PowerDetailsList.hasDisplayableContent(forcePowerIds);
    final Widget forcePowerDetails = PowerDetailsList(
      powerIds: forcePowerIds,
      powerDefinitions: lookups.forcePowerDefinitions,
    );
    final List<String> techPowerIds = character.techPowerIds.toList()..sort();
    final bool showTechPowers =
        PowerDetailsList.hasDisplayableContent(techPowerIds);
    final Widget techPowerDetails = PowerDetailsList(
      powerIds: techPowerIds,
      powerDefinitions: lookups.techPowerDefinitions,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name.value,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.savedCharactersHeader(
                          speciesLabel,
                          classLabel,
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.savedCharactersBackground(backgroundLabel),
                        style: theme.textTheme.bodySmall,
                      ),
                      if (showAbilityBonuses) ...[
                        const SizedBox(height: 12),
                        SpeciesAbilityBonusesCard(
                          bonuses: speciesAbilityBonuses,
                        ),
                      ],
                      if (showLanguageDetails) ...[
                        const SizedBox(height: 12),
                        LanguageDetailsCard(
                          languages: speciesLanguages,
                          fallback: speciesLanguageFallback,
                        ),
                      ],
                      if (showTraitDetails) ...[
                        const SizedBox(height: 12),
                        Text(
                          l10n.characterSpeciesTraitsHeading,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SpeciesTraitDetailsList(
                          traitIds: speciesTraitIds,
                          traitDefinitions: lookups.traitDefinitions,
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.savedCharactersLevel(character.level.value),
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      l10n.savedCharactersDefense(character.defense.value),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (classSection != null) ...[
              classSection,
              const SizedBox(height: 16),
            ],
            if (backgroundSection != null) ...[
              backgroundSection,
              const SizedBox(height: 16),
            ],
            if (showCustomizationOptions) ...[
              _Section(
                title: l10n.characterCustomizationOptionsTitle,
                child: customizationDetails,
              ),
              const SizedBox(height: 16),
            ],
            if (showForcePowers) ...[
              _Section(
                title: l10n.characterForcePowersTitle,
                child: forcePowerDetails,
              ),
              const SizedBox(height: 16),
            ],
            if (showTechPowers) ...[
              _Section(
                title: l10n.characterTechPowersTitle,
                child: techPowerDetails,
              ),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _ChipStat(label: l10n.statHp, value: '${character.hitPoints.value}'),
                _ChipStat(
                    label: l10n.statInitiative,
                    value: _fmtSigned(character.initiative.value)),
                _ChipStat(
                    label: l10n.statProficiency,
                    value: '+${character.proficiencyBonus.value}'),
                _ChipStat(label: l10n.statCredits, value: '${character.credits.value}'),
                _ChipStat(
                    label: l10n.statEncumbrance,
                    value: '${character.encumbrance.grams} g'),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: l10n.savedCharactersCharacteristicsTitle,
              child: _AbilitiesTable(
                abilities: character.abilities,
                abilityDefinitions: lookups.abilityDefinitions,
              ),
            ),
            if (character.skills.isNotEmpty) ...[
              const SizedBox(height: 16),
              _Section(
                title: l10n.savedCharactersSkillsTitle,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: character.skills
                      .map(
                        (skill) => Chip(
                          label: Text(
                            '${_resolveSkillLabel(l10n, skill.skillId)} (${skill.sources.map((source) => source.name).join('+')})',
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            if (character.inventory.isNotEmpty) ...[
              const SizedBox(height: 16),
              _Section(
                title: l10n.savedCharactersInventoryTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: character.inventory
                      .map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _inventoryEntry(theme, l10n, line),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasPowerInfo(ClassDef def) {
    if (def.powerSource != null && def.powerSource!.trim().isNotEmpty) {
      return true;
    }
    return def.powerList != null;
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const Icon(Icons.group_off, size: 64),
        const SizedBox(height: 16),
        Center(
          child: Text(
            l10n.savedCharactersEmpty,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ChipStat extends StatelessWidget {
  const _ChipStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label : $value'),
    );
  }
}

class _AbilitiesTable extends StatelessWidget {
  const _AbilitiesTable({
    required this.abilities,
    required this.abilityDefinitions,
  });

  final Map<String, AbilityScore> abilities;
  final Map<String, AbilityDef> abilityDefinitions;

  static const List<String> _order = <String>['str', 'dex', 'con', 'int', 'wis', 'cha'];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    String _abilityLabel(String ability) {
      final AbilityDef? def = abilityDefinitions[ability];
      final String abbreviation = l10n.abilityAbbreviation(ability);
      if (def != null) {
        final String localized =
            l10n.localizedCatalogLabel(def.name).trim();
        if (localized.isNotEmpty) {
          final String suffix = abbreviation.trim().isNotEmpty
              ? abbreviation
              : def.abbreviation.trim();
          if (suffix.isNotEmpty) {
            return '$localized ($suffix)';
          }
          return localized;
        }
      }
      if (abbreviation.trim().isNotEmpty) {
        return abbreviation;
      }
      return ability.toUpperCase();
    }

    Widget _abilityCell(String ability) {
      final AbilityDef? def = abilityDefinitions[ability];
      final String label = _abilityLabel(ability);
      final String? description = def?.description != null
          ? l10n.localizedCatalogLabel(def!.description!).trim()
          : null;
      final Text text = Text(
        label,
        style: theme.textTheme.bodyMedium,
      );
      if (description != null && description.isNotEmpty) {
        return Tooltip(
          message: description,
          child: text,
        );
      }
      return text;
    }

    String _scoreWithModifier(AbilityScore score) {
      final String modifier = score.modifier >= 0
          ? '+${score.modifier}'
          : score.modifier.toString();
      return '${score.value} ($modifier)';
    }

    final List<TableRow> rows = <TableRow>[];
    for (final String ability in _order) {
      final AbilityScore? score = abilities[ability];
      if (score == null) {
        continue;
      }
      rows.add(
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _abilityCell(ability),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                _scoreWithModifier(score),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
      },
      children: rows,
    );
  }
}
