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

class BuildTransaction {
  final BuildSettings settings;
  final Set<EnvProperty> env;

  const BuildTransaction({
    required this.settings,
    this.env = const {},
  });
}

Future<void> buildApp({
  required BuildSettings settings,
  Map<String, EnvProperty> Function(Map<String, EnvProperty>)?
      transformProperties,
}) async {
  final transaction = BuildTransaction(
    settings: settings,
    env: {},
  );
  final neededProperties = settings.neededEnvKeys.map((e) {
    return EnvProperty(
      e,
      defaultValue: settings.initialEnv[e],
    );
  }).toSet();

  final collectEnvStep = StepCollectEnvProperties(
    sources: {
      if (settings.envFilePath != null)
        FileEnvPropertySource(
          envFilePath: settings.envFilePath!,
        ),
    },
  );

  final transformEnvStep = StepTransformEnvProperties(
    overrides: DeployUtils.fastPropertiesFromMap(settings.initialEnv),
    transformer: transformProperties,
  );

  final normalizeEnvStep = StepNormalizeEnvProperties(
    neededProperties: neededProperties,
  );

  final guardEnvStep = StepGuardEnvProperties(
    requiredProperties: neededProperties,
  );

  final runBuildStep = StepRunActualBuild(
    customOutputPath: settings.outputDirPath,
  );

  collectEnvStep.setNext(
    normalizeEnvStep
      ..setNext(
        transformEnvStep
          ..setNext(
            guardEnvStep
              ..setNext(
                runBuildStep,
              ),
          ),
      ),
  );

  await collectEnvStep.handle(transaction);
}
