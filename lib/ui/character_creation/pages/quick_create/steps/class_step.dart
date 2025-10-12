part of '../quick_create_page.dart';

class _ClassStep extends StatelessWidget {
  const _ClassStep({
    required this.classes,
    required this.selectedClass,
    required this.classDef,
    required this.isLoadingDetails,
    required this.onSelect,
    required this.onOpenPicker,
  });

  final List<String> classes;
  final String? selectedClass;
  final ClassDef? classDef;
  final bool isLoadingDetails;
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
                classDefData.name.fr.isNotEmpty
                    ? classDefData.name.fr
                    : classDefData.name.en,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('Dé de vie : d${classDefData.hitDie}'),
              const SizedBox(height: 12),
              Text(
                'Compétences : choisir ${classDefData.level1.proficiencies.skillsChoose} (étape suivante)',
              ),
              const SizedBox(height: 12),
              Text(
                'Équipement de départ :\n${classDefData.level1.startingEquipment.map((e) => '• ${e.id} ×${e.qty}').join('\n')}',
              ),
            ],
          ),
      ],
    );
  }
}
