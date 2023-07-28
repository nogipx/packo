import 'dart:async';

import 'package:packo/packo.dart';

typedef StringEvaluator = String Function(String src);

abstract class BuildStep<T> {
  const BuildStep();

  FutureOr<T> handle(T data);
}

mixin VerboseStep {
  String get description => '';
  String get initMessage => '⚙️ Running $stepName';
  String get completeMessage => '';

  String get stepName => runtimeType.toString();
}

enum StepStatus { inProgress, completed, error }

abstract class StepListener {
  void onStepChanged(BuildStep step, StepStatus status, [Object? error]);
}
