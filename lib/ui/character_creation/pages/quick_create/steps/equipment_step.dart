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
    final l10n = context.l10n;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final classData = classDef;
    if (classData == null) {
      return Center(
        child: Text(l10n.equipmentStepSelectClass),
      );
    }
    if (equipmentDefinitions.isEmpty) {
      return Center(child: Text(l10n.equipmentStepCatalogMissing));
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
            final Iterable<String> localizedValues = def.name.translations.values;
            final bool matchesTranslation = localizedValues.any(
              (value) => value.toLowerCase().contains(lower),
            );
            return matchesTranslation || id.contains(lower);
          })
          .toList(growable: false);
    }, [equipmentIds, equipmentDefinitions, query.value]);

    final startingWeightG = _computeStartingWeight(classData);
    final purchasesWeightG = _computePurchasesWeight();
    final displayTotalWeight =
        totalWeightG != null ? _formatWeight(totalWeightG!) : '—';
    final displayCapacity =
        capacityG != null ? _formatWeight(capacityG!) : '—';
    final overCapacity =
        capacityG != null && totalWeightG != null && totalWeightG! > capacityG!;
    final overCredits = availableCredits >= 0 && totalCost > availableCredits;

    String equipmentLabel(String id) {
      final def = equipmentDefinitions[id];
      if (def == null) return id;
      return l10n.localizedCatalogLabel(def.name);
    }

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.equipmentStepCredits(availableCredits),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (classData.level1.startingCreditsRoll != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.equipmentStepAlternateRoll(
                classData.level1.startingCreditsRoll!,
              ),
            ),
          ),
        const SizedBox(height: 16),
        SwitchListTile.adaptive(
          value: useStartingEquipment,
          contentPadding: EdgeInsets.zero,
          onChanged: onToggleStartingEquipment,
          title: Text(l10n.equipmentStepUseStarting),
          subtitle: classData.level1.startingEquipment.isEmpty
              ? Text(l10n.equipmentStepNoStarting)
              : Text(
                  classData.level1.startingEquipment
                      .map(
                        (line) => l10n.startingEquipmentLine(
                          equipmentLabel(line.id),
                          line.qty,
                        ),
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
                    Text(
                      l10n.equipmentStepOptionsTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...classData.level1.startingEquipmentOptions.map(
                      (option) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• ${l10n.localizedCatalogLabel(option)}',
                        ),
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
                Text(
                  l10n.equipmentStepPurchasesTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...chosenEquipment.entries.map((entry) {
                  final def = equipmentDefinitions[entry.key];
                  final label = equipmentLabel(entry.key);
                  final cost = def?.cost ?? 0;
                  return Text(
                    l10n.equipmentStepPurchaseLine(
                      label,
                      entry.value,
                      cost * entry.value,
                    ),
                  );
                }),
              ],
            ),
          ),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Text(l10n.equipmentStepCost(totalCost)),
            Text(
              l10n.equipmentStepRemainingCredits(remainingCredits),
              style: TextStyle(
                color: remainingCredits < 0 ? Colors.red : null,
              ),
            ),
            Text(l10n.equipmentStepTotalWeight(displayTotalWeight)),
            Text(l10n.equipmentStepCapacity(displayCapacity)),
            if (useStartingEquipment && startingWeightG != null)
              Text(
                l10n.equipmentStepStartingWeight(
                  _formatWeight(startingWeightG),
                ),
              ),
            if (chosenEquipment.isNotEmpty && purchasesWeightG != null)
              Text(
                l10n.equipmentStepPurchasesWeight(
                  _formatWeight(purchasesWeightG),
                ),
              ),
          ],
        ),
        if (overCredits)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.equipmentStepOverCredits,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (overCapacity)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.equipmentStepOverCapacity,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: queryController,
          decoration: InputDecoration(
            labelText: l10n.equipmentStepSearchLabel,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
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
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(l10n.equipmentStepSearchEmpty),
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
                  final List<Widget> subtitleLines = <Widget>[
                    Text(
                      l10n.equipmentStepListSubtitle(
                        def.cost,
                        _formatWeight(def.weightG),
                        _titleCase(def.type),
                      ),
                    ),
                  ];
                  if (def.weaponCategory != null &&
                      def.weaponCategory!.trim().isNotEmpty) {
                    subtitleLines.add(
                      Text(
                        l10n.equipmentStepWeaponCategory(
                          _titleCase(def.weaponCategory!),
                        ),
                      ),
                    );
                  }
                  if (def.weaponDamage.isNotEmpty) {
                    for (final WeaponDamage damage in def.weaponDamage) {
                      final String dice = _formatWeaponDice(damage);
                      final String typeLabel = damage.damageTypeName != null
                          ? l10n.localizedCatalogLabel(damage.damageTypeName!)
                          : _titleCase(damage.damageType);
                      subtitleLines.add(
                        Text(
                          l10n.equipmentStepWeaponDamage(dice, typeLabel),
                        ),
                      );
                      if (damage.damageTypeNotes != null) {
                        final String notes =
                            l10n.localizedCatalogLabel(damage.damageTypeNotes!);
                        if (notes.trim().isNotEmpty) {
                          subtitleLines.add(
                            Text(
                              l10n.equipmentStepDamageNotes(notes.trim()),
                            ),
                          );
                        }
                      }
                    }
                  }
                  if (def.weaponRange != null &&
                      (def.weaponRange!.primary != null ||
                          def.weaponRange!.maximum != null)) {
                    subtitleLines.add(
                      Text(
                        l10n.equipmentStepWeaponRange(
                          def.weaponRange!.primary,
                          def.weaponRange!.maximum,
                        ),
                      ),
                    );
                  }
                  if (def.weaponProperties.isNotEmpty) {
                    final String formattedProperties = def.weaponProperties
                        .map(_titleCase)
                        .join(', ');
                    subtitleLines.add(
                      Text(
                        l10n.equipmentStepWeaponProperties(
                          formattedProperties,
                        ),
                      ),
                    );
                  }
                  if (def.rarity != null && def.rarity!.trim().isNotEmpty) {
                    subtitleLines.add(
                      Text(
                        l10n.equipmentStepRarity(
                          _titleCase(def.rarity!),
                        ),
                      ),
                    );
                  }
                  if (def.description != null) {
                    subtitleLines.add(
                      Text(
                        l10n.localizedCatalogLabel(def.description!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        title: Text(
                          l10n.localizedCatalogLabel(def.name),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: subtitleLines,
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

  String _formatWeaponDice(WeaponDamage damage) {
    final int? count = damage.diceCount;
    final int? die = damage.diceDie;
    final int? modifier = damage.diceModifier;
    if (count == null || die == null) {
      if (modifier != null && modifier != 0) {
        return modifier > 0 ? '+$modifier' : '$modifier';
      }
      return '—';
    }
    final String base = '${count}d$die';
    if (modifier == null || modifier == 0) {
      return base;
    }
    final String mod = modifier > 0 ? '+$modifier' : '$modifier';
    return '$base$mod';
  }

  String _titleCase(String slug) => slug
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
