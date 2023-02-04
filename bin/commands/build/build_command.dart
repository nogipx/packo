import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';
import 'package:yaml/yaml.dart';

abstract class YamlKey {
  static const buildPlatform = 'buildPlatform';
  static const buildType = 'buildType';
  static const requiredEnv = 'requiredEnv';
  static const initialEnv = 'initialEnv';
  static const projectDirectory = 'projectDirectory';
  static const artifactsOutputsDirectory = 'artifactsOutputsDirectory';
  static const envFile = 'envFile';
}

class BuildAppCommand extends Command {
  @override
  final String name = 'build';
  @override
  final String description = 'Build app';

  BuildAppCommand() {
    argParser
      ..addOption(
        'configFilePath',
        abbr: 'c',
        mandatory: true,
      )
      ..addOption(
        'buildPlatform',
        abbr: 'p',
        mandatory: true,
        allowed: BuildPlatform.values.map((e) => e.name),
      )
      ..addOption(
        'buildType',
        abbr: 't',
        defaultsTo: BuildType.release.name,
        allowed: BuildType.values.map((e) => e.name),
      )
      ..addOption(
        'envFile',
        abbr: 'e',
      );
  }

  @override
  Future<void> run() async {
    if (argResults == null) {
      printUsage();
      return;
    }
    final args = argResults!;

    if (args.wasParsed('configFilePath')) {
      final path = args['configFilePath']?.toString() ?? '';
      final yaml = _loadYaml(path);

      final platform =
          BuildPlatform.parse(args[YamlKey.buildPlatform] as String?);
      final type = BuildType.parse(args[YamlKey.buildType] as String?);
      if (platform == null) {
        throw ArgumentError.notNull(YamlKey.buildPlatform);
      }
      if (type == null) {
        throw ArgumentError.notNull(YamlKey.buildType);
      }

      final neededEnv = yaml[YamlKey.requiredEnv] as YamlList?;
      final parsedInitialEnv = yaml[YamlKey.initialEnv] as YamlMap?;
      final initialEnv = parsedInitialEnv?.value.cast<String, String>() ?? {};

      final settings = BuildSettings(
        directory: Directory(yaml[YamlKey.projectDirectory] as String),
        platform: platform,
        type: type,
        outputDirPath: yaml[YamlKey.artifactsOutputsDirectory] as String?,
        neededEnvKeys: neededEnv?.value.toSet().cast() ?? {},
        initialEnv: initialEnv,
        envFilePath: args[YamlKey.envFile] as String? ??
            yaml[YamlKey.envFile] as String?,
      );

      await buildApp(settings: settings);
    }
  }

  YamlMap _loadYaml(String? path) {
    if (path == null || path.isEmpty) {
      throw Exception('Invalid config file path.');
    }

    final file = File(path);
    if (!file.existsSync()) {
      throw Exception('Config file not exists.');
    }

    final yaml = loadYaml(file.readAsStringSync());
    return YamlMap.wrap(yaml as Map);
  }
}
