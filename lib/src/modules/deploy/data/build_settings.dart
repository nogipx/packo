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
    String? envFilePath,
  }) {
    return BuildSettings(
      directory: directory ?? this.directory,
      platform: platform ?? this.platform,
      type: type ?? this.type,
      envFilePath: envFilePath ?? this.envFilePath,
      outputDirPath: outputDirPath,
      neededEnvKeys: neededEnvKeys,
      initialEnv: initialEnv,
    );
  }
}
