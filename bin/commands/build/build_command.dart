import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:packo/packo.dart';
import 'package:yaml/yaml.dart';

import 'yaml_config_parser.dart';

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
      ..addOption('envFile');
  }

  @override
  Future<void> run() async {
    if (argResults == null) {
      printUsage();
      return;
    }
    final args = argResults!;

    if (args.wasParsed('configFilePath')) {
      final platform = BuildPlatform.parse(
        args[YamlKey.buildPlatform] as String?,
      );
      final type = BuildType.parse(
        args[YamlKey.buildType] as String?,
      );

      final settings = await _parseConfigSettings(
        args['configFilePath'] as String?,
      );

      final argsEnvFile = args[YamlKey.envFile] as String?;

      await buildApp(
        settings: settings.copyWith(
          platform: platform != BuildPlatform.undefined ? platform : null,
          type: type != BuildType.undefined ? type : null,
          envFilePath: argsEnvFile,
        ),
      );
    }
  }

  Future<BuildSettings> _parseConfigSettings(String? path) async {
    final parser = YamlToBuildSettingsParser();
    final settings = parser.parseSettings(_loadYaml(path));
    return settings;
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
