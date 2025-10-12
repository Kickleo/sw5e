part of '../quick_create_page.dart';

class _ClassStep extends StatelessWidget {
  const _ClassStep({
    required this.classes,
    required this.selectedClass,
    required this.classDef,
    required this.isLoadingDetails,
    required this.equipmentDefinitions,
    required this.onSelect,
    required this.onOpenPicker,
  });

  final List<String> classes;
  final String? selectedClass;
  final ClassDef? classDef;
  final bool isLoadingDetails;
  final Map<String, EquipmentDef> equipmentDefinitions;
  final ValueChanged<String?> onSelect;
  final VoidCallback onOpenPicker;

  String _titleCase(String slug) => slug
      .split(RegExp(r'[-_]'))
      .map(
        (part) =>
            part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
      )
      .join(' ');

  String _localizedText(LocalizedText text) =>
      text.fr.isNotEmpty ? text.fr : text.en;

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
                _localizedText(classDefData.name),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (classDefData.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  _localizedText(classDefData.description!),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 8),
              Text('${l10n.hitDiceLabel} : d${classDefData.hitDie}'),
              const SizedBox(height: 12),
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
    final List<String> options = classDef.level1.startingEquipmentOptions;
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
      } else if (def.name.fr.isNotEmpty) {
        label = def.name.fr;
      } else {
        label = def.name.en;
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
