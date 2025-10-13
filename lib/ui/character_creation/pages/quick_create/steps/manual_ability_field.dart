part of '../quick_create_page.dart';

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
    final l10n = context.l10n;

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
        labelText: l10n.abilityScoreLabel,
        border: const OutlineInputBorder(),
        errorText: errorText.value,
      ),
      onChanged: (text) {
        final trimmed = text.trim();
        if (trimmed.isEmpty) {
          errorText.value = l10n.manualScoreRequired;
          onChanged(null);
          return;
        }
        final value = int.tryParse(trimmed);
        if (value == null) {
          errorText.value = l10n.manualScoreNumberError;
          onChanged(null);
          return;
        }
        if (value < AbilityScore.min || value > AbilityScore.max) {
          errorText.value =
              l10n.manualScoreRangeError(AbilityScore.min, AbilityScore.max);
          onChanged(null);
          return;
        }
        errorText.value = null;
        onChanged(value);
      },
    );
  }
}
