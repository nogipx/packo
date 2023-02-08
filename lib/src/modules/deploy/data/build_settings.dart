import 'dart:io';

import 'package:packo/packo.dart';

class BuildSettings {
  final Directory directory;
  final BuildPlatform platform;
  final BuildType type;
  final String? envFilePath;
  final String? outputDirPath;
  final Set<String> neededEnvKeys;
  final Map<String, String> initialEnv;

  const BuildSettings({
    required this.directory,
    this.platform = BuildPlatform.undefined,
    this.type = BuildType.undefined,
    this.envFilePath,
    this.outputDirPath,
    this.neededEnvKeys = const {},
    this.initialEnv = const {},
  });

  BuildSettings copyWith({
    Directory? directory,
    BuildPlatform? platform,
    BuildType? type,
  }) {
    return BuildSettings(
      directory: directory ?? this.directory,
      platform: platform ?? this.platform,
      type: type ?? this.type,
      envFilePath: envFilePath,
      outputDirPath: outputDirPath,
      neededEnvKeys: neededEnvKeys,
      initialEnv: initialEnv,
    );
  }

  Iterable<Exception> guard() {
    final guards = [
      _guard(
        test: () =>
            directory.path.isNotEmpty &&
            directory.existsSync() &&
            Package.of(directory) != null,
        errorMessage:
            'Project directory must be a valid path of flutter project.',
      ),
      _guard(
        test: () => platform != BuildPlatform.undefined,
        errorMessage: 'Build platform must be specified.',
      ),
      _guard(
        test: () => type != BuildType.undefined,
        errorMessage: 'Build type must be specified.',
      ),
    ];

    return guards.whereType<Exception>();
  }

  Exception? _guard({
    required bool Function() test,
    required String errorMessage,
  }) =>
      test() ? null : Exception(errorMessage);
}
