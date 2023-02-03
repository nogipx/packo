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
    required this.platform,
    required this.type,
    this.envFilePath,
    this.outputDirPath,
    this.neededEnvKeys = const {},
    this.initialEnv = const {},
  });
}
