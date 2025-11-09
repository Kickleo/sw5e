part of '../quick_create_page.dart';

class _ClassStep extends StatelessWidget {
  const _ClassStep({
    required this.classes,
    required this.classLabels,
    required this.selectedClass,
    required this.classDef,
    required this.isLoadingDetails,
    required this.abilityDefinitions,
    required this.equipmentDefinitions,
    required this.onSelect,
    required this.onOpenPicker,
  });

  final List<String> classes;
  final Map<String, LocalizedText> classLabels;
  final String? selectedClass;
  final ClassDef? classDef;
  final bool isLoadingDetails;
  final Map<String, AbilityDef> abilityDefinitions;
  final Map<String, EquipmentDef> equipmentDefinitions;
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
    final classDefData = classDef;
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedClass,
                decoration: InputDecoration(
                  labelText: l10n.classLabel,
                  border: const OutlineInputBorder(),
                ),
                items: classes
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
              label: Text(l10n.classDetails),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoadingDetails)
          const Center(child: CircularProgressIndicator())
        else if (classDefData == null)
          Text(l10n.noClassSelected)
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.localizedCatalogLabel(classDefData.name),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (classDefData.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.localizedCatalogLabel(classDefData.description!),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 8),
              Text('${l10n.hitDiceLabel} : d${classDefData.hitDie}'),
              const SizedBox(height: 12),
              if (classDefData.primaryAbilities.isNotEmpty) ...[
                Text(
                  l10n.classPickerPrimaryAbilitiesTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAbilities(
                    l10n,
                    abilityDefinitions,
                    classDefData.primaryAbilities,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (classDefData.savingThrows.isNotEmpty) ...[
                Text(
                  l10n.classPickerSavingThrowsTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAbilities(
                    l10n,
                    abilityDefinitions,
                    classDefData.savingThrows,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_classHasPowerInfo(classDefData)) ...[
                ClassPowerDetails(classDef: classDefData),
                const SizedBox(height: 12),
              ],
              if (classDefData.weaponProficiencies.isNotEmpty) ...[
                Text(
                  l10n.classPickerWeaponProficienciesTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  formatClassProficiencies(
                    values: classDefData.weaponProficiencies,
                    l10n: l10n,
                    category: ClassProficiencyCategory.weapon,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (classDefData.armorProficiencies.isNotEmpty) ...[
                Text(
                  l10n.classPickerArmorProficienciesTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  formatClassProficiencies(
                    values: classDefData.armorProficiencies,
                    l10n: l10n,
                    category: ClassProficiencyCategory.armor,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (classDefData.toolProficiencies.isNotEmpty) ...[
                Text(
                  l10n.classPickerToolProficienciesTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  formatClassProficiencies(
                    values: classDefData.toolProficiencies,
                    l10n: l10n,
                    category: ClassProficiencyCategory.tool,
                    equipmentDefinitions: equipmentDefinitions,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
            if (classDefData.multiclassing?.hasAbilityRequirements ?? false) ...[
                ClassMulticlassingDetails(
                  classDef: classDefData,
                  abilityDefinitions: abilityDefinitions,
                  headingStyle: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
              ],
            if (classDefData.level1.classFeatures.isNotEmpty) ...[
              ClassFeatureList(
                heading: l10n.classPickerLevel1FeaturesTitle,
                features: classDefData.level1.classFeatures,
              ),
              const SizedBox(height: 12),
            ],
            Text(
              l10n.classSkillsChoice(
                classDefData.level1.proficiencies.skillsChoose,
              ),
            ),
            const SizedBox(height: 12),
            _ClassStartingEquipment(
              classDef: classDefData,
              equipmentDefinitions: equipmentDefinitions,
            ),
          ],
        ),
      ],
    );
  }

  String _labelFor(AppLocalizations l10n, String id) {
    final LocalizedText? text = classLabels[id];
    if (text != null) {
      final String label = l10n.localizedCatalogLabel(text).trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return _titleCase(id);
  }

}

String _formatAbilities(
  AppLocalizations l10n,
  Map<String, AbilityDef> abilityDefinitions,
  List<String> abilities,
) {
  if (abilities.isEmpty) {
    return '';
  }
  final Iterable<String> labels = abilities.map((String slug) {
    final AbilityDef? ability = abilityDefinitions[slug];
    if (ability != null) {
      final String name = l10n.localizedCatalogLabel(ability.name).trim();
      final String abbr = ability.abbreviation.trim();
      if (name.isNotEmpty) {
        if (abbr.isNotEmpty &&
            !name.toLowerCase().contains(abbr.toLowerCase())) {
          return '$name (${abbr.toUpperCase()})';
        }
        return name;
      }
      if (abbr.isNotEmpty) {
        return abbr.toUpperCase();
      }
    }
    return l10n.abilityAbbreviation(slug);
  }).where((String label) => label.isNotEmpty);
  return labels.join(', ');
}

class _ClassStartingEquipment extends StatelessWidget {
  const _ClassStartingEquipment({
    required this.classDef,
    required this.equipmentDefinitions,
  });

  final ClassDef classDef;
  final Map<String, EquipmentDef> equipmentDefinitions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final List<StartingEquipmentLine> fixed =
        classDef.level1.startingEquipment;
    final List<LocalizedText> options =
        classDef.level1.startingEquipmentOptions;
    final bool hasFixed = fixed.isNotEmpty;
    final bool hasOptions = options.isNotEmpty;

    if (!hasFixed && !hasOptions) {
      return Text(l10n.startingEquipmentEmpty);
    }

    String formatLine(StartingEquipmentLine line) {
      final EquipmentDef? def = equipmentDefinitions[line.id];
      final String label;
      if (def == null) {
        label = line.id;
      } else {
        label = l10n.localizedCatalogLabel(def.name);
      }
      return l10n.startingEquipmentLine(label, line.qty);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.startingEquipmentTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        if (hasFixed) ...[
          const SizedBox(height: 4),
          Text(fixed.map(formatLine).join('\n')),
        ],
        if (hasOptions) ...[
          if (hasFixed) const SizedBox(height: 8),
          Text(
            l10n.startingEquipmentOptionsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            options.map(l10n.startingEquipmentOption).join('\n'),
          ),
        ],
      ],
    );
  }
}

bool _classHasPowerInfo(ClassDef def) {
  if (def.powerSource != null && def.powerSource!.trim().isNotEmpty) {
    return true;
  }
  final ClassPowerList? powerList = def.powerList;
  if (powerList == null) {
    return false;
  }
  return powerList.forceAllowed || powerList.techAllowed;
}
