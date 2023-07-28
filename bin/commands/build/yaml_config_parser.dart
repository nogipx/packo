import 'dart:io';

import 'package:packo/packo.dart';
import 'package:yaml/yaml.dart';

abstract class YamlSettingsParser {
  BuildSettings parseSettings(YamlMap data);
}

abstract class YamlKey {
  static const sectionBuild = 'packo_build';

  static const buildPlatform = 'buildPlatform';
  static const buildType = 'buildType';
  static const requiredEnv = 'requiredEnv';
  static const initialEnv = 'initialEnv';
  static const projectDirectory = 'projectDirectory';
  static const artifactsOutputsDirectory = 'artifactsOutputsDirectory';
  static const envFile = 'envFile';
  static const executable = 'flutterExecutable';
}

class YamlToBuildSettingsParser implements YamlSettingsParser {
  @override
  BuildSettings parseSettings(YamlMap yaml) {
    final data = {};
    if (yaml.containsKey(YamlKey.sectionBuild)) {
      data.addAll(yaml[YamlKey.sectionBuild] as Map);
    }

    final directory = Directory(data[YamlKey.projectDirectory] as String);
    final outputDirectory = data[YamlKey.artifactsOutputsDirectory] as String?;

    final neededEnv = data[YamlKey.requiredEnv] as YamlList?;
    final parsedInitialEnv = data[YamlKey.initialEnv] as YamlMap?;
    final initialEnv = parsedInitialEnv?.value.cast<String, String>() ?? {};
    final envFilePath = data[YamlKey.envFile] as String?;
    final executable = data[YamlKey.executable] as String?;

    final settings = BuildSettings(
      directory: directory,
      outputDirPath: outputDirectory,
      neededEnvKeys: neededEnv?.value.toSet().cast() ?? {},
      initialEnv: initialEnv,
      envFilePath: envFilePath,
      flutterExecutable: executable,
    );

    return settings;
  }
}
