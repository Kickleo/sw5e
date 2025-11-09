/// ---------------------------------------------------------------------------
/// Fichier : lib/ui/character_creation/pages/character_summary_page.dart
/// Rôle : Vue Flutter affichant le résumé des personnages sauvegardés et
///        orchestrant les interactions via CharacterSummaryBloc.
/// Dépendances : flutter_bloc (binding BLoC↔UI), Share Plus (partage),
///        ServiceLocator pour l'injection.
/// Exemple d'usage : routage GoRouter -> const CharacterSummaryPage().
/// ---------------------------------------------------------------------------
library;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sw5e_manager/app/locale/app_localizations.dart';
import 'package:sw5e_manager/common/di/service_locator.dart';
import 'package:sw5e_manager/common/logging/app_logger.dart';
import 'package:sw5e_manager/domain/characters/entities/character.dart';
import 'package:sw5e_manager/domain/characters/localization/species_effect_localization.dart';
import 'package:sw5e_manager/domain/characters/repositories/catalog_repository.dart';
import 'package:sw5e_manager/domain/characters/usecases/list_saved_characters.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/domain/characters/value_objects/character_id.dart';
import 'package:sw5e_manager/domain/characters/value_objects/skill_proficiency.dart';
import 'package:sw5e_manager/domain/characters/value_objects/ability_score.dart';
import 'package:sw5e_manager/presentation/character_creation/blocs/character_summary_bloc.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/background_details.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/language_details.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/species_ability_bonuses.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/species_trait_details.dart';
import 'package:sw5e_manager/ui/character_creation/widgets/catalog_details.dart';
class CharacterSummaryPage extends StatefulWidget {
  /// Constructeur par défaut.
  const CharacterSummaryPage({super.key});

  @override
  State<CharacterSummaryPage> createState() => _CharacterSummaryPageState();
}

class _CharacterSummaryPageState extends State<CharacterSummaryPage> {
  late final ScrollController _scrollController;
  late final AppLogger _logger;
  late final CharacterSummaryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _logger = ServiceLocator.resolve<AppLogger>();
    final ListSavedCharacters listSavedCharacters =
        ServiceLocator.resolve<ListSavedCharacters>();
    final CatalogRepository catalog =
        ServiceLocator.resolve<CatalogRepository>();
    _bloc = CharacterSummaryBloc(
      listSavedCharacters: listSavedCharacters,
      catalog: catalog,
      logger: _logger,
    )..add(const CharacterSummaryStarted());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  Future<void> _onRefresh(BuildContext context) async {
    context
        .read<CharacterSummaryBloc>()
        .add(const CharacterSummaryRefreshRequested());
  }

  Future<void> _onShareIntent(
    BuildContext context,
    CharacterSummaryShareIntent intent,
  ) async {
    try {
      await Share.share(intent.message, subject: intent.subject);
    } on Object catch (error, stackTrace) {
      _logger.warn(
        'CharacterSummaryPage.share: échec',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      if (context.mounted) {
        context
            .read<CharacterSummaryBloc>()
            .add(const CharacterSummaryShareAcknowledged());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CharacterSummaryBloc>.value(
      value: _bloc,
      child: BlocListener<CharacterSummaryBloc, CharacterSummaryState>(
        listenWhen: (previous, current) =>
            previous.shareIntent != current.shareIntent &&
            current.shareIntent != null,
        listener: (context, state) {
          final CharacterSummaryShareIntent? intent = state.shareIntent;
          if (intent != null) {
            unawaited(_onShareIntent(context, intent));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.characterSummaryTitle),
            leading: IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: context.l10n.backToHomeTooltip,
              onPressed: () => context.go('/'),
            ),
            actions: [
              BlocBuilder<CharacterSummaryBloc, CharacterSummaryState>(
                buildWhen: (previous, current) =>
                    previous.isLoading != current.isLoading,
                builder: (context, state) {
                  return IconButton(
                    onPressed: state.isLoading
                        ? null
                        : () => context
                            .read<CharacterSummaryBloc>()
                            .add(const CharacterSummaryRefreshRequested()),
                    tooltip: context.l10n.refreshTooltip,
                    icon: const Icon(Icons.refresh),
                  );
                },
              ),
              BlocBuilder<CharacterSummaryBloc, CharacterSummaryState>(
                buildWhen: (previous, current) =>
                    previous.isSharing != current.isSharing ||
                    previous.selectedId != current.selectedId ||
                    previous.characters != current.characters,
                builder: (context, state) {
                  final Character? selected = state.selectedCharacter;
                  return IconButton(
                    onPressed: selected == null || state.isSharing
                        ? null
                        : () => context
                            .read<CharacterSummaryBloc>()
                            .add(CharacterSummaryShareRequested(context.l10n)),
                    tooltip: context.l10n.shareTooltip,
                    icon: const Icon(Icons.share),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<CharacterSummaryBloc, CharacterSummaryState>(
            builder: (context, state) {
              if (state.isLoading && !state.hasLoadedOnce) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.hasError && state.characters.isEmpty) {
                return _ErrorView(
                  message: state.errorMessage ?? context.l10n.unknownError,
                  onRetry: () => context
                      .read<CharacterSummaryBloc>()
                      .add(const CharacterSummaryRefreshRequested()),
                );
              }

              if (state.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => _onRefresh(context),
                  child: const _EmptyView(),
                );
              }

              final Character? selected = state.selectedCharacter;

              return RefreshIndicator(
                onRefresh: () => _onRefresh(context),
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _CharacterSelector(
                        characters: state.characters,
                        selectedId: state.selectedId ?? selected?.id,
                        onChanged: (CharacterId? id) {
                          if (id != null) {
                            context.read<CharacterSummaryBloc>().add(
                                  CharacterSummaryCharacterSelected(id),
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (selected != null)
                        _CharacterSummaryCard(
                          character: selected,
                          state: state,
                        ),
                    ],
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

class _CharacterSelector extends StatelessWidget {
  const _CharacterSelector({
    required this.characters,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Character> characters;
  final CharacterId? selectedId;
  final ValueChanged<CharacterId?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CharacterId>(
      initialValue: selectedId,
      decoration: InputDecoration(
        labelText: context.l10n.savedCharacterDropdownLabel,
        border: const OutlineInputBorder(),
      ),
      items: characters
          .map(
            (Character character) => DropdownMenuItem<CharacterId>(
              value: character.id,
              child: Text(character.name.value),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _CharacterSummaryCard extends StatelessWidget {
  const _CharacterSummaryCard({
    required this.character,
    required this.state,
  });

  final Character character;
  final CharacterSummaryState state;

  String _fmtSigned(int value) => value >= 0 ? '+$value' : '$value';

  String _catalogLabel(
    AppLocalizations l10n,
    LocalizedText? text,
    String fallback,
  ) {
    if (text != null) {
      final String label = l10n.localizedCatalogLabel(text).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(fallback);
  }

  String _skillChipLabel(AppLocalizations l10n, SkillProficiency skill) {
    final String label = _catalogLabel(
      l10n,
      state.skillDefinitions[skill.skillId]?.name,
      skill.skillId,
    );
    if (skill.sources.isEmpty) {
      return label;
    }
    final String sources =
        skill.sources.map((source) => _titleCase(source.name)).join('+');
    return '$label ($sources)';
  }

  String _equipmentLabel(AppLocalizations l10n, String id) {
    final EquipmentDef? def = state.equipmentDefinitions[id];
    if (def != null) {
      final String label = l10n.localizedCatalogLabel(def.name).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }

  List<String> _equipmentMetadata(AppLocalizations l10n, String id) {
    final EquipmentDef? def = state.equipmentDefinitions[id];
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
    final String label = _equipmentLabel(l10n, line.itemId.value);
    final List<String> metadata =
        _equipmentMetadata(l10n, line.itemId.value);
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

  String _titleCase(String slug) {
    return slug
        .split(RegExp(r'[\-_.]'))
        .map((part) =>
            part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final String speciesLabel = _catalogLabel(
      l10n,
      state.speciesNames[character.speciesId.value],
      character.speciesId.value,
    );
    final String classLabel = _catalogLabel(
      l10n,
      state.classNames[character.classId.value],
      character.classId.value,
    );
    final String backgroundLabel = _catalogLabel(
      l10n,
      state.backgroundNames[character.backgroundId.value],
      character.backgroundId.value,
    );
    final List<String> customizationOptionIds =
        character.customizationOptionIds.toList()..sort();
    final bool showCustomizationOptions =
        CustomizationOptionDetailsList.hasDisplayableContent(
      customizationOptionIds,
    );
    final Widget customizationDetails = CustomizationOptionDetailsList(
      optionIds: customizationOptionIds,
      optionDefinitions: state.customizationOptionDefinitions,
    );
    final List<String> forcePowerIds = character.forcePowerIds.toList()..sort();
    final bool showForcePowers =
        PowerDetailsList.hasDisplayableContent(forcePowerIds);
    final Widget forcePowerDetails = PowerDetailsList(
      powerIds: forcePowerIds,
      powerDefinitions: state.forcePowerDefinitions,
    );
    final List<String> techPowerIds = character.techPowerIds.toList()..sort();
    final bool showTechPowers =
        PowerDetailsList.hasDisplayableContent(techPowerIds);
    final Widget techPowerDetails = PowerDetailsList(
      powerIds: techPowerIds,
      powerDefinitions: state.techPowerDefinitions,
    );
    final SpeciesDef? speciesDef =
        state.speciesDefinitions[character.speciesId.value];
    final List<LanguageDef> speciesLanguages = <LanguageDef>[];
    if (speciesDef != null) {
      for (final String languageId in speciesDef.languageIds) {
        final LanguageDef? language = state.languageDefinitions[languageId];
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
    final BackgroundDef? backgroundDef =
        state.backgroundDefinitions[character.backgroundId.value];
    final List<Widget> backgroundDetails = backgroundDef == null
        ? const <Widget>[]
        : buildBackgroundDetails(
            l10n: l10n,
            theme: theme,
            background: backgroundDef,
            skillDefinitions: state.skillDefinitions,
            equipmentDefinitions: state.equipmentDefinitions,
          );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              character.name.value,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text('$speciesLabel • $classLabel',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              l10n.savedCharactersBackground(backgroundLabel),
              style: theme.textTheme.bodySmall,
            ),
            if (showAbilityBonuses) ...[
              const SizedBox(height: 12),
              SpeciesAbilityBonusesCard(bonuses: speciesAbilityBonuses),
            ],
            if (showLanguageDetails) ...[
              const SizedBox(height: 12),
              LanguageDetailsCard(
                languages: speciesLanguages,
                fallback: speciesLanguageFallback,
              ),
            ] else
              const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _ChipStat(label: l10n.statLevel, value: '${character.level.value}'),
                _ChipStat(
                  label: l10n.statProficiency,
                  value: '+${character.proficiencyBonus.value}',
                ),
                _ChipStat(label: l10n.statHp, value: '${character.hitPoints.value}'),
                _ChipStat(label: l10n.statDefense, value: '${character.defense.value}'),
                _ChipStat(
                  label: l10n.statInitiative,
                  value: _fmtSigned(character.initiative.value),
                ),
                _ChipStat(label: l10n.statCredits, value: '${character.credits.value}'),
                _ChipStat(
                  label: l10n.statCarriedWeight,
                  value: '${character.encumbrance.grams} g',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: l10n.characterProfileTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.savedCharactersHeader(speciesLabel, classLabel)),
                  Text(l10n.savedCharactersBackground(backgroundLabel)),
                  if (character.speciesTraits.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.characterSpeciesTraitsHeading,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SpeciesTraitDetailsList(
                      traitIds: character.speciesTraits
                          .map((trait) => trait.id.value),
                      traitDefinitions: state.traitDefinitions,
                    ),
                  ],
                ],
              ),
            ),
            if (showCustomizationOptions) ...[
              const SizedBox(height: 16),
              _Section(
                title: l10n.characterCustomizationOptionsTitle,
                child: customizationDetails,
              ),
            ],
            if (showForcePowers) ...[
              const SizedBox(height: 16),
              _Section(
                title: l10n.characterForcePowersTitle,
                child: forcePowerDetails,
              ),
            ],
            if (showTechPowers) ...[
              const SizedBox(height: 16),
              _Section(
                title: l10n.characterTechPowersTitle,
                child: techPowerDetails,
              ),
            ],
            const SizedBox(height: 16),
            if (backgroundDetails.isNotEmpty) ...[
              _Section(
                title: l10n.summaryBackgroundDetails,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: backgroundDetails,
                ),
              ),
              const SizedBox(height: 16),
            ],
            _Section(
              title: l10n.characterAbilitiesTitle,
              child: _AbilitiesTable(
                abilities: character.abilities,
                abilityDefinitions: state.abilityDefinitions,
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: l10n.characterMasteredSkillsTitle,
              child: character.skills.isEmpty
                  ? Text(l10n.characterNoSkills)
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: character.skills
                          .map(
                            (skill) => Chip(
                              label: Text(
                                _skillChipLabel(l10n, skill),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: l10n.characterInventoryTitle,
              child: character.inventory.isEmpty
                  ? Text(l10n.characterInventoryEmpty)
                  : Column(
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
            const SizedBox(height: 16),
            _Section(
              title: l10n.characterManeuversTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.characterManeuversKnown(
                      character.maneuversKnown.value)),
                  Text(
                    l10n.characterManeuverDice(
                      character.superiorityDice.count,
                      character.superiorityDice.die,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipStat extends StatelessWidget {
  const _ChipStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
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
        Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        child,
      ],
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

  static String _fmtMod(int modifier) => modifier >= 0 ? '+$modifier' : '$modifier';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final List<DataRow> rows = <DataRow>[];
    for (final String key in _order) {
      final AbilityScore? score = abilities[key];
      if (score == null) {
        continue;
      }
      final AbilityDef? def = abilityDefinitions[key];
      final String abbreviation = l10n.abilityAbbreviation(key);
      String abilityLabel;
      String? abilityDescription;
      if (def != null) {
        final String localized = l10n.localizedCatalogLabel(def.name).trim();
        if (def.description != null) {
          final String description =
              l10n.localizedCatalogLabel(def.description!).trim();
          if (description.isNotEmpty) {
            abilityDescription = description;
          }
        }
        if (localized.isNotEmpty) {
          final String suffix = abbreviation.trim().isNotEmpty
              ? abbreviation
              : def.abbreviation.trim();
          abilityLabel = suffix.isNotEmpty ? '$localized ($suffix)' : localized;
        } else {
          abilityLabel = abbreviation.trim().isNotEmpty
              ? abbreviation
              : key.toUpperCase();
        }
      } else {
        abilityLabel = abbreviation.trim().isNotEmpty
            ? abbreviation
            : key.toUpperCase();
      }
      final Widget labelWidget = abilityDescription != null
          ? Tooltip(message: abilityDescription!, child: Text(abilityLabel))
          : Text(abilityLabel);
      rows.add(
        DataRow(
          cells: [
            DataCell(labelWidget),
            DataCell(Text('${score.value}')),
            DataCell(Text(_fmtMod(score.modifier))),
          ],
        ),
      );
    }
    return DataTable(
      columns: <DataColumn>[
        DataColumn(label: Text(l10n.abilitiesTableAbility)),
        DataColumn(label: Text(l10n.abilitiesTableScore)),
        DataColumn(label: Text(l10n.abilitiesTableModifier)),
      ],
      rows: rows,
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(context.l10n.emptySavedCharacters),
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
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: Text(context.l10n.retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
