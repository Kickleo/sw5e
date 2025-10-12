part of '../quick_create_page.dart';

class _QuickCreateControls extends StatelessWidget {
  const _QuickCreateControls({
    required this.state,
    required this.onPrevious,
    required this.onNext,
    required this.onCreate,
  });

  final QuickCreateState state;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: state.canGoPrevious ? onPrevious : null,
                child: const Text('Précédent'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: state.currentStep == QuickCreateStep.background
                  ? FilledButton.icon(
                      onPressed: state.canCreate && !state.isCreating
                          ? onCreate
                          : null,
                      icon: state.isCreating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: const Text('Créer'),
                    )
                  : FilledButton(
                      onPressed: state.canGoNext ? onNext : null,
                      child: const Text('Suivant'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
