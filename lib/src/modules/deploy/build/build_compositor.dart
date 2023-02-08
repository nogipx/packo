import 'package:packo/packo.dart';

class BuildCompositor {
  final List<BuildStep<BuildTransaction>> _steps = [];
  List<BuildStep<BuildTransaction>> get steps => List.unmodifiable(_steps);

  void setNext(BuildStep<BuildTransaction> step) {
    _steps.add(step);
  }

  void printSequence() {
    final messages = _steps.map((step) {
      if (step is VerboseStep) {
        final verbose = step as VerboseStep;
        return verbose.description;
      }
      return step.runtimeType;
    });
    final result = messages.join('\n');
    print(result);
  }

  Future<void> run({
    required BuildSettings settings,
    StepListener? listener,
  }) async {
    var transaction = BuildTransaction(
      settings: settings,
      env: {},
    );

    for (final step in steps) {
      listener?.onStepChanged(step, StepStatus.inProgress);

      try {
        final updatedTransaction = await step.handle(transaction);
        listener?.onStepChanged(step, StepStatus.completed);
        transaction = updatedTransaction;
      } on Exception catch (error) {
        listener?.onStepChanged(step, StepStatus.error, error);
        rethrow;
      }
    }
  }
}
