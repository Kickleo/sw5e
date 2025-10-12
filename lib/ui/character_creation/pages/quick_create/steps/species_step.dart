part of quick_create_page;

class _SpeciesStep extends StatelessWidget {
  const _SpeciesStep({
    required this.species,
    required this.selectedSpecies,
    required this.traits,
    required this.effects,
    required this.onSelect,
    required this.onOpenPicker,
  });

  final List<String> species;
  final String? selectedSpecies;
  final List<TraitDef> traits;
  final List<CharacterEffect> effects;
  final ValueChanged<String?> onSelect;
  final VoidCallback onOpenPicker;

  String _titleCase(String slug) => slug
      .split(RegExp(r'[-_]'))
      .map(
        (part) =>
            part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
      )
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
                    .map(
                      (id) => DropdownMenuItem(
                        value: id,
                        child: Text(_titleCase(id)),
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
              label: const Text('Parcourir'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (effects.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Effets d’espèce',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...effects.map(_buildEffectCard),
            ],
          )
        else if (traits.isNotEmpty)
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
                    title: Text(
                      trait.name.fr.isNotEmpty ? trait.name.fr : trait.name.en,
                    ),
                    subtitle: Text(trait.description),
                  ),
                ),
              ),
            ],
          )
        else
          const Text('Aucun trait spécifique pour cette espèce.'),
      ],
    );
  }

  Widget _buildEffectCard(CharacterEffect effect) {
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
              _categoryLabel(effect.category),
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(CharacterEffectCategory category) {
    switch (category) {
      case CharacterEffectCategory.passive:
        return 'Effet passif';
      case CharacterEffectCategory.action:
        return 'Action';
      case CharacterEffectCategory.bonusAction:
        return 'Action bonus';
    }
  }
}
