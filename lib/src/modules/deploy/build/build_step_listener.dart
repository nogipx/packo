import 'package:cli_util/cli_logging.dart';
import 'package:packo/packo.dart';

class ConsolePrinterStepListener implements StepListener {
  final Logger logger;

  ConsolePrinterStepListener(this.logger);

  BuildStep? _lastStep;
  Progress? _lastProgress;

  @override
  void onStepChanged(BuildStep step, StepStatus status) {
    var message = '';
    final stepName = step.runtimeType.toString();

    if (status == StepStatus.error) {
      message = 'Step "$stepName" completed with error';
      logger.stderr(message);
      return;
    }

    if (step != _lastStep) {
      if (_lastStep == null) {
        logger.trace('First step');
      } else {
        logger.trace('Step changed');
      }
      _lastStep = step;

      if (_lastProgress != null) {
        message = 'Step "$stepName" completed"';

        _lastProgress!.finish(
          message: message,
          showTiming: true,
        );
        _lastProgress = null;
      }
    }

    if (status == StepStatus.inProgress) {
      message = 'Running step "$stepName"';
      _lastProgress = logger.progress(message);
      logger.trace('Set progress for $stepName');
    }
  }
}
