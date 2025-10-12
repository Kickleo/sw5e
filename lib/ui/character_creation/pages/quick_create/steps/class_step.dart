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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Classe',
                  border: OutlineInputBorder(),
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
              label: const Text('Détails'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoadingDetails)
          const Center(child: CircularProgressIndicator())
        else if (classDefData == null)
          const Text('Aucune classe sélectionnée.')
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
              Text('Dé de vie : d${classDefData.hitDie}'),
              const SizedBox(height: 12),
              Text(
                'Compétences : choisir ${classDefData.level1.proficiencies.skillsChoose} (étape suivante)',
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

  String _formatLine(StartingEquipmentLine line) {
    final EquipmentDef? def = equipmentDefinitions[line.id];
    final String label;
    if (def == null) {
      label = line.id;
    } else if (def.name.fr.isNotEmpty) {
      label = def.name.fr;
    } else {
      label = def.name.en;
    }
    return '• $label ×${line.qty}';
  }

  @override
  Widget build(BuildContext context) {
    final List<StartingEquipmentLine> fixed =
        classDef.level1.startingEquipment;
    final List<String> options = classDef.level1.startingEquipmentOptions;
    final bool hasFixed = fixed.isNotEmpty;
    final bool hasOptions = options.isNotEmpty;

    if (!hasFixed && !hasOptions) {
      return const Text(
        'Équipement de départ : cette classe ne propose pas de pack pré-défini.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Équipement de départ :',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        if (hasFixed) ...[
          const SizedBox(height: 4),
          Text(fixed.map(_formatLine).join('\n')),
        ],
        if (hasOptions) ...[
          if (hasFixed) const SizedBox(height: 8),
          const Text(
            'Options :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(options.map((option) => '• $option').join('\n')),
        ],
      ],
    );
  }
}
