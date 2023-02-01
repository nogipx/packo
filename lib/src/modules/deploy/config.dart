import 'dart:io';

import 'package:packo/packo.dart';

class BuildTransaction {
  final Directory directory;
  final BuildPlatform platform;
  final BuildType type;
  final Set<EnvProperty> env;

  const BuildTransaction({
    required this.directory,
    required this.platform,
    required this.type,
    this.env = const {},
  });
}

class BuildConfig {
  final Set<EnvProperty> environment;

  const BuildConfig({
    this.environment = const {},
  });

  Future<void> buildApp({
    required Directory appDirectory,
    required BuildPlatform platform,
    required BuildType type,
    String? envFilePath,
    String? outputDirPath,
    Set<EnvProperty> overrideProps = const {},
    Map<String, EnvProperty> Function(Map<String, EnvProperty>)?
        transformProperties,
  }) async {
    final transaction = BuildTransaction(
      directory: appDirectory,
      platform: platform,
      type: type,
      env: {},
    );

    final collectEnvStep = StepCollectEnvProperties(
      sources: {
        if (envFilePath != null)
          FileEnvPropertySource(
            envFilePath: envFilePath,
          ),
      },
    );

    final transformEnvStep = StepTransformEnvProperties(
      overrides: DeployUtils.fastMapProperties(overrideProps),
      transformer: transformProperties,
    );

    final normalizeEnvStep = StepNormalizeEnvProperties(
      neededProperties: environment,
    );

    final guardEnvStep = StepGuardEnvProperties(
      requiredProperties: environment,
    );

    final runBuildStep = StepRunActualBuild(
      customOutputPath: outputDirPath,
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
}
