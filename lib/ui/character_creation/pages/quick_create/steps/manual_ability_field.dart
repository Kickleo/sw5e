part of quick_create_page;

class _ManualAbilityField extends HookWidget {
  const _ManualAbilityField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  final int? initialValue;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(
      text: initialValue?.toString() ?? '',
    );
    final errorText = useState<String?>(null);

    useEffect(() {
      final newText = initialValue?.toString() ?? '';
      if (controller.text != newText) {
        controller.value = controller.value.copyWith(text: newText);
      }
      if (newText.isNotEmpty) {
        final value = int.tryParse(newText);
        if (value != null &&
            value >= AbilityScore.min &&
            value <= AbilityScore.max) {
          errorText.value = null;
        }
      }
      return null;
    }, [initialValue]);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Score',
        border: const OutlineInputBorder(),
        errorText: errorText.value,
      ),
      onChanged: (text) {
        final trimmed = text.trim();
        if (trimmed.isEmpty) {
          errorText.value = 'Requis';
          onChanged(null);
          return;
        }
        final value = int.tryParse(trimmed);
        if (value == null) {
          errorText.value = 'Entrez un nombre';
          onChanged(null);
          return;
        }
        if (value < AbilityScore.min || value > AbilityScore.max) {
          errorText.value =
              'Doit être entre ${AbilityScore.min} et ${AbilityScore.max}';
          onChanged(null);
          return;
        }
        errorText.value = null;
        onChanged(value);
      },
    );
  }
}
