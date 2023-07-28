import 'package:packo/packo.dart';

class StepGuardBuildSettings implements BuildStep<BuildTransaction> {
  const StepGuardBuildSettings();

  @override
  FutureOr<BuildTransaction> handle(BuildTransaction data) {
    final guards = _guard(data.settings);
    if (guards.isNotEmpty) {
      final guardsString = guards.map((e) => e.toString()).join('\n- ');
      throw Exception(
        'There are some problems with your build: \n- $guardsString',
      );
    }

    return data;
  }

  Iterable<Exception> _guard(BuildSettings data) {
    final guards = [
      _exception(
        test: () =>
            data.directory.path.isNotEmpty &&
            data.directory.existsSync() &&
            Package.of(data.directory) != null,
        errorMessage:
            'Project directory must be a valid path of flutter project.',
      ),
      _exception(
        test: () => data.platform != BuildPlatform.undefined,
        errorMessage: 'Build platform must be specified.',
      ),
      _exception(
        test: () => data.type != BuildType.undefined,
        errorMessage: 'Build type must be specified.',
      ),
    ];

    return guards.whereType<Exception>();
  }

  Exception? _exception({
    required bool Function() test,
    required String errorMessage,
  }) =>
      test() ? null : Exception(errorMessage);
}
