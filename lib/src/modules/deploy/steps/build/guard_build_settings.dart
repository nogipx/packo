import 'package:packo/packo.dart';

class StepGuardBuildSettings implements BuildStep<BuildTransaction> {
  @override
  FutureOr<BuildTransaction> handle(BuildTransaction data) {
    final guards = data.settings.guard();
    if (guards.isNotEmpty) {
      final guardsString = guards.map((e) => e.toString()).join('\n- ');
      final exception = Exception(
        'There are some problems with your build: \n- $guardsString',
      );
      throw exception;
    }

    return data;
  }
}
