import 'package:cli_util/cli_logging.dart';
import 'package:packo/packo.dart';
import 'package:packo/src/modules/deploy/steps/build/guard_build_settings.dart';

Future<void> buildApp({
  required BuildSettings settings,
}) async {
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

  final normalizeEnvStep = StepNormalizeEnvProperties(
    neededProperties: neededProperties,
  );

  final guardEnvStep = StepGuardEnvProperties(
    requiredProperties: neededProperties,
  );

  final buildCompositor = BuildCompositor()
    ..setNext(StepGuardBuildSettings())
    ..setNext(collectEnvStep)
    ..setNext(StepInjectSystemProperties())
    ..setNext(normalizeEnvStep)
    ..setNext(guardEnvStep)
    ..setNext(StepRunActualBuild())
    ..setNext(StepMoveArtifacts());

  await buildCompositor.run(
    settings: settings,
    listener: ConsolePrinterStepListener(
      Logger.verbose(ansi: Ansi(true)),
    ),
  );
}
