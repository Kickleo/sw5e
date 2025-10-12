part of 'quick_create_page.dart';

class _BackgroundStep extends StatelessWidget {
  const _BackgroundStep({
    required this.backgrounds,
    required this.selectedBackground,
    required this.nameController,
    required this.onBackgroundChanged,
  });

  final List<String> backgrounds;
  final String? selectedBackground;
  final TextEditingController nameController;
  final ValueChanged<String?> onBackgroundChanged;

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
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom du personnage',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedBackground,
          decoration: const InputDecoration(
            labelText: 'Historique',
            border: OutlineInputBorder(),
          ),
          items: backgrounds
              .map(
                (id) => DropdownMenuItem(value: id, child: Text(_titleCase(id))),
              )
              .toList(),
          onChanged: onBackgroundChanged,
        ),
        const SizedBox(height: 24),
        const Text(
          'Pensez à vérifier votre équipement avant de finaliser la création.',
        ),
      ],
    );
  }
}
