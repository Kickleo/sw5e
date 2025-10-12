part of '../quick_create_page.dart';

class _EquipmentStep extends HookWidget {
  const _EquipmentStep({
    required this.isLoading,
    required this.classDef,
    required this.equipmentDefinitions,
    required this.equipmentIds,
    required this.chosenEquipment,
    required this.useStartingEquipment,
    required this.totalWeightG,
    required this.capacityG,
    required this.totalCost,
    required this.remainingCredits,
    required this.availableCredits,
    required this.onToggleStartingEquipment,
    required this.onQuantityChanged,
  });

  final bool isLoading;
  final ClassDef? classDef;
  final Map<String, EquipmentDef> equipmentDefinitions;
  final List<String> equipmentIds;
  final Map<String, int> chosenEquipment;
  final bool useStartingEquipment;
  final int? totalWeightG;
  final int? capacityG;
  final int totalCost;
  final int remainingCredits;
  final int availableCredits;
  final ValueChanged<bool> onToggleStartingEquipment;
  final void Function(String id, int quantity) onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final classData = classDef;
    if (classData == null) {
      return const Center(
        child: Text('Choisissez une classe pour configurer votre équipement.'),
      );
    }
    if (equipmentDefinitions.isEmpty) {
      return const Center(child: Text('Catalogue d\'équipement indisponible.'));
    }

    final queryController = useTextEditingController();
    final query = useState('');

    useEffect(() {
      void listener() => query.value = queryController.text;
      queryController.addListener(listener);
      return () => queryController.removeListener(listener);
    }, [queryController]);

    final filteredIds = useMemoized(() {
      final lower = query.value.toLowerCase().trim();
      if (lower.isEmpty) {
        return List<String>.from(equipmentIds);
      }
      return equipmentIds
          .where((id) {
            final def = equipmentDefinitions[id];
            if (def == null) return false;
            final fr = def.name.fr.toLowerCase();
            final en = def.name.en.toLowerCase();
            return fr.contains(lower) ||
                en.contains(lower) ||
                id.contains(lower);
          })
          .toList(growable: false);
    }, [equipmentIds, equipmentDefinitions, query.value]);

    final startingWeightG = _computeStartingWeight(classData);
    final purchasesWeightG = _computePurchasesWeight();
    final displayTotalWeight = totalWeightG != null
        ? _formatWeight(totalWeightG!)
        : '—';
    final displayCapacity = capacityG != null ? _formatWeight(capacityG!) : '—';
    final overCapacity =
        capacityG != null && totalWeightG != null && totalWeightG! > capacityG!;
    final overCredits = availableCredits >= 0 && totalCost > availableCredits;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crédits de départ : ${availableCredits}cr',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (classData.level1.startingCreditsRoll != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Jet alternatif : ${classData.level1.startingCreditsRoll}',
            ),
          ),
        const SizedBox(height: 16),
        SwitchListTile.adaptive(
          value: useStartingEquipment,
          contentPadding: EdgeInsets.zero,
          onChanged: onToggleStartingEquipment,
          title: const Text('Prendre l\'équipement de départ de la classe'),
          subtitle: classData.level1.startingEquipment.isEmpty
              ? const Text(
                  'Cette classe ne fournit pas d\'équipement spécifique par défaut.',
                )
              : Text(
                  classData.level1.startingEquipment
                      .map(
                        (line) => '• ${_equipmentLabel(line.id)} ×${line.qty}',
                      )
                      .join('\n'),
                ),
        ),
        if (classData.level1.startingEquipmentOptions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Options d\'équipement de départ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...classData.level1.startingEquipmentOptions.map(
                      (option) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(option),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (chosenEquipment.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Achats en cours',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...chosenEquipment.entries.map((entry) {
                  final def = equipmentDefinitions[entry.key];
                  final label = def != null ? def.name.fr : entry.key;
                  final cost = def?.cost ?? 0;
                  return Text(
                    '• $label ×${entry.value} (${cost * entry.value}cr)',
                  );
                }),
              ],
            ),
          ),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Text('Coût des achats : ${totalCost}cr'),
            Text(
              'Crédits restants : ${remainingCredits}cr',
              style: TextStyle(
                color: remainingCredits < 0 ? Colors.red : null,
              ),
            ),
            Text('Poids total : $displayTotalWeight'),
            Text('Capacité : $displayCapacity'),
            if (useStartingEquipment && startingWeightG != null)
              Text(
                'Équipement de départ : ${_formatWeight(startingWeightG)}',
              ),
            if (chosenEquipment.isNotEmpty && purchasesWeightG != null)
              Text('Achats : ${_formatWeight(purchasesWeightG)}'),
          ],
        ),
        if (overCredits)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Vous dépassez vos crédits de départ.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (overCapacity)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Le poids total dépasse votre capacité de portance.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: queryController,
          decoration: const InputDecoration(
            labelText: 'Rechercher un objet…',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: header),
          if (filteredIds.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Aucun équipement ne correspond à votre recherche.',
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final id = filteredIds[index];
                  final def = equipmentDefinitions[id];
                  if (def == null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(title: Text(id)),
                        if (index < filteredIds.length - 1)
                          const CharacterSectionDivider(
                            spacing: 8,
                            thickness: 1,
                          ),
                      ],
                    );
                  }
                  final qty = chosenEquipment[id] ?? 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        title: Text(def.name.fr),
                        subtitle: Text(
                          '${def.cost}cr · ${_formatWeight(def.weightG)} · ${def.type}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: qty > 0
                                  ? () => onQuantityChanged(id, qty - 1)
                                  : null,
                            ),
                            SizedBox(
                              width: 32,
                              child: Text('$qty', textAlign: TextAlign.center),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => onQuantityChanged(id, qty + 1),
                            ),
                          ],
                        ),
                      ),
                      if (index < filteredIds.length - 1)
                        const CharacterSectionDivider(
                          spacing: 8,
                          thickness: 1,
                        ),
                    ],
                  );
                },
                childCount: filteredIds.length,
              ),
            ),
        ],
      ),
    );
  }

  String _equipmentLabel(String id) {
    final def = equipmentDefinitions[id];
    if (def == null) return id;
    return def.name.fr.isNotEmpty ? def.name.fr : def.name.en;
  }

  int? _computeStartingWeight(ClassDef classData) {
    if (!useStartingEquipment) {
      return 0;
    }
    int total = 0;
    for (final line in classData.level1.startingEquipment) {
      final def = equipmentDefinitions[line.id];
      if (def?.weightG == null) {
        return null;
      }
      total += def!.weightG * line.qty;
    }
    return total;
  }

  int? _computePurchasesWeight() {
    int total = 0;
    for (final entry in chosenEquipment.entries) {
      final def = equipmentDefinitions[entry.key];
      if (def?.weightG == null) {
        return null;
      }
      total += def!.weightG * entry.value;
    }
    return total;
  }

  String _formatWeight(int grams) {
    final kilograms = grams / 1000;
    if (kilograms >= 10) {
      return '${kilograms.toStringAsFixed(1)} kg';
    }
    return '${kilograms.toStringAsFixed(2)} kg';
  }
}
