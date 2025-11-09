part of '../quick_create_page.dart';

class _SpeciesStep extends StatelessWidget {
  const _SpeciesStep({
    required this.species,
    required this.speciesLabels,
    required this.selectedSpecies,
    required this.selectedSpeciesDef,
    required this.selectedLanguages,
    required this.traits,
    required this.effects,
    required this.onSelect,
    required this.onOpenPicker,
  });

  final List<String> species;
  final Map<String, LocalizedText> speciesLabels;
  final String? selectedSpecies;
  final SpeciesDef? selectedSpeciesDef;
  final List<LanguageDef> selectedLanguages;
  final List<TraitDef> traits;
  final List<CharacterEffect> effects;
  final ValueChanged<String?> onSelect;
  final VoidCallback onOpenPicker;

  String _titleCase(String slug) => slug
      .split(RegExp(r'[\-_.]'))
      .map(
        (part) =>
            part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
      )
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final LocalizedText? fallbackLanguages = selectedSpeciesDef?.languages;
    final bool showLanguageCard = LanguageDetailsCard.hasDisplayableContent(
      l10n,
      selectedLanguages,
      fallback: fallbackLanguages,
    );
    final List<SpeciesAbilityBonus> abilityBonuses =
        selectedSpeciesDef?.abilityBonuses ?? const <SpeciesAbilityBonus>[];
    final bool showAbilityBonuses =
        SpeciesAbilityBonusesCard.hasDisplayableContent(abilityBonuses);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedSpecies,
                decoration: InputDecoration(
                  labelText: l10n.speciesLabel,
                  border: const OutlineInputBorder(),
                ),
                items: species
                    .map(
                      (id) => DropdownMenuItem(
                        value: id,
                        child: Text(_labelFor(l10n, id)),
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
              label: Text(l10n.speciesBrowse),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (showAbilityBonuses) ...[
          SpeciesAbilityBonusesCard(bonuses: abilityBonuses),
          const SizedBox(height: 16),
        ],
        if (showLanguageCard) ...[
          LanguageDetailsCard(
            languages: selectedLanguages,
            fallback: fallbackLanguages,
          ),
          const SizedBox(height: 16),
        ],
        if (effects.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.speciesEffectsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...effects.map((effect) => _buildEffectCard(context, effect)),
            ],
          )
        else if (traits.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.speciesTraitsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SpeciesTraitDetailsList.fromDefinitions(traits: traits),
            ],
          )
        else
          Text(l10n.noSpeciesTraits),
      ],
    );
  }

  String _labelFor(AppLocalizations l10n, String id) {
    final LocalizedText? text = speciesLabels[id];
    if (text != null) {
      final String label = l10n.localizedCatalogLabel(text).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }

  Widget _buildEffectCard(BuildContext context, CharacterEffect effect) {
    final l10n = context.l10n;
    final String title = effect.title.isNotEmpty ? effect.title : effect.source;
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(effect.description),
            const SizedBox(height: 8),
            Text(
              _categoryLabel(l10n, effect.category),
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(AppLocalizations l10n, CharacterEffectCategory category) {
    switch (category) {
      case CharacterEffectCategory.passive:
        return l10n.effectPassive;
      case CharacterEffectCategory.action:
        return l10n.effectAction;
      case CharacterEffectCategory.bonusAction:
        return l10n.effectBonusAction;
    }
  }
}
